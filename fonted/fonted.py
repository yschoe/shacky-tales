#!/usr/bin/env python3
"""FON editor ported from foned90.pas.

Features preserved from original:
- editable NxN bitmap (1/0 text .fon format)
- load existing .fon
- plot/erase/clear/invert
- save and save-as
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import sys

import pygame

MAX_SIZE = 50
MIN_SIZE = 1
DEFAULT_SIZE = 50

WHITE = (245, 245, 245)
BLACK = (20, 20, 20)
GRAY = (150, 150, 150)
LIGHT = (225, 225, 225)
RED = (200, 40, 40)
GREEN = (20, 150, 20)
BLUE = (60, 90, 180)


@dataclass
class EditorState:
    file_path: Path
    size: int
    pixels: list[list[int]]
    cur_x: int = 0
    cur_y: int = 0
    dirty: bool = False
    save_as_mode: bool = False
    save_as_text: str = ""
    status: str = ""


def clamp_size(size: int) -> int:
    return max(MIN_SIZE, min(MAX_SIZE, size))


def infer_size(lines: list[str], fallback: int) -> int:
    if not lines:
        return fallback
    width = max((len(line.rstrip("\n\r")) for line in lines), default=0)
    height = len(lines)
    inferred = max(width, height)
    return clamp_size(inferred if inferred > 0 else fallback)


def load_fon(path: Path, requested_size: int | None) -> tuple[int, list[list[int]]]:
    if path.exists():
        raw_lines = path.read_text(encoding="ascii", errors="ignore").splitlines()
        size = clamp_size(requested_size) if requested_size is not None else infer_size(raw_lines, DEFAULT_SIZE)
        px = [[0 for _ in range(size)] for _ in range(size)]
        for y in range(min(size, len(raw_lines))):
            row = raw_lines[y]
            for x in range(min(size, len(row))):
                px[y][x] = 1 if row[x] == "1" else 0
        return size, px

    size = clamp_size(requested_size if requested_size is not None else DEFAULT_SIZE)
    return size, [[0 for _ in range(size)] for _ in range(size)]


def save_fon(path: Path, pixels: list[list[int]], size: int) -> None:
    lines = []
    for y in range(size):
        lines.append("".join("1" if pixels[y][x] else "0" for x in range(size)))
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def make_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="FON editor (ported from foned90.pas)")
    p.add_argument("file", nargs="?", default="blank.fon", help="Input/output .fon file")
    p.add_argument("--size", type=int, default=None, help="Grid size (1..50); inferred from file by default")
    return p


def draw_grid(screen: pygame.Surface, state: EditorState, left: int, top: int, cell: int) -> None:
    size = state.size
    grid_px = size * cell
    pygame.draw.rect(screen, WHITE, (left, top, grid_px, grid_px))

    for y in range(size):
        for x in range(size):
            if state.pixels[y][x]:
                pygame.draw.rect(screen, BLACK, (left + x * cell, top + y * cell, cell, cell))

    for i in range(size + 1):
        color = GRAY if i % 5 == 0 else LIGHT
        pygame.draw.line(screen, color, (left + i * cell, top), (left + i * cell, top + grid_px), 1)
        pygame.draw.line(screen, color, (left, top + i * cell), (left + grid_px, top + i * cell), 1)

    pygame.draw.rect(screen, BLACK, (left, top, grid_px, grid_px), 2)
    pygame.draw.rect(
        screen,
        RED,
        (left + state.cur_x * cell, top + state.cur_y * cell, cell, cell),
        2,
    )


def draw_preview(screen: pygame.Surface, state: EditorState, left: int, top: int) -> None:
    scale = 4
    size = state.size
    w = size * scale
    h = size * scale
    pygame.draw.rect(screen, WHITE, (left, top, w, h))
    for y in range(size):
        for x in range(size):
            if state.pixels[y][x]:
                pygame.draw.rect(screen, BLACK, (left + x * scale, top + y * scale, scale, scale))
    pygame.draw.rect(screen, BLACK, (left, top, w, h), 2)


def draw_help(screen: pygame.Surface, font: pygame.font.Font, state: EditorState, left: int, top: int) -> None:
    lines = [
        "FON Editor (port of foned90.pas)",
        f"File: {state.file_path}",
        f"Grid: {state.size}x{state.size}",
        "Arrows: Move cursor",
        "Space/D: Plot pixel",
        "E/Backspace: Erase pixel",
        "C: Clear all",
        "I: Invert",
        "S: Save",
        "F6: Save As",
        "Q or Esc: Quit",
        "Mouse left/right: plot/erase",
    ]
    y = top
    for line in lines:
        txt = font.render(line, True, BLACK)
        screen.blit(txt, (left, y))
        y += 20

    status_color = GREEN if not state.dirty else BLUE
    status = state.status or ("Modified" if state.dirty else "Ready")
    screen.blit(font.render(status, True, status_color), (left, y + 8))


def draw_save_as_overlay(screen: pygame.Surface, font: pygame.font.Font, state: EditorState, w: int, h: int) -> None:
    overlay = pygame.Surface((w, h), pygame.SRCALPHA)
    overlay.fill((0, 0, 0, 120))
    screen.blit(overlay, (0, 0))

    box_w, box_h = min(760, w - 40), 130
    box_x = (w - box_w) // 2
    box_y = (h - box_h) // 2

    pygame.draw.rect(screen, WHITE, (box_x, box_y, box_w, box_h))
    pygame.draw.rect(screen, BLACK, (box_x, box_y, box_w, box_h), 2)

    t1 = font.render("Save As: type filename and press Enter", True, BLACK)
    t2 = font.render("Esc to cancel", True, BLACK)
    t3 = font.render(state.save_as_text + "_", True, BLUE)
    screen.blit(t1, (box_x + 16, box_y + 16))
    screen.blit(t2, (box_x + 16, box_y + 40))
    screen.blit(t3, (box_x + 16, box_y + 78))


def run_editor(initial_file: Path, requested_size: int | None) -> int:
    size, pixels = load_fon(initial_file, requested_size)
    state = EditorState(file_path=initial_file, size=size, pixels=pixels, status="Loaded")

    pygame.init()
    pygame.display.set_caption("Font Editor")
    font = pygame.font.SysFont("Courier New", 20)

    cell = max(10, min(18, 760 // state.size))
    grid_px = state.size * cell
    left, top = 26, 26
    right_panel_x = left + grid_px + 24
    preview_x = right_panel_x
    preview_y = top

    width = max(980, right_panel_x + state.size * 4 + 260)
    height = max(560, top + grid_px + 40)

    screen = pygame.display.set_mode((width, height))
    clock = pygame.time.Clock()

    def set_pixel(x: int, y: int, value: int) -> None:
        if state.pixels[y][x] != value:
            state.pixels[y][x] = value
            state.dirty = True

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
                continue

            if state.save_as_mode:
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE:
                        state.save_as_mode = False
                        state.save_as_text = ""
                        state.status = "Save As cancelled"
                    elif event.key == pygame.K_BACKSPACE:
                        state.save_as_text = state.save_as_text[:-1]
                    elif event.key in (pygame.K_RETURN, pygame.K_KP_ENTER):
                        typed = state.save_as_text.strip()
                        if typed:
                            state.file_path = Path(typed)
                            save_fon(state.file_path, state.pixels, state.size)
                            state.dirty = False
                            state.status = f"Saved: {state.file_path}"
                        else:
                            state.status = "Save As needs a filename"
                        state.save_as_mode = False
                        state.save_as_text = ""
                    elif event.unicode and event.unicode.isprintable():
                        if len(state.save_as_text) < 180:
                            state.save_as_text += event.unicode
                continue

            if event.type == pygame.KEYDOWN:
                if event.key in (pygame.K_q, pygame.K_ESCAPE):
                    running = False
                elif event.key == pygame.K_LEFT:
                    state.cur_x = max(0, state.cur_x - 1)
                elif event.key == pygame.K_RIGHT:
                    state.cur_x = min(state.size - 1, state.cur_x + 1)
                elif event.key == pygame.K_UP:
                    state.cur_y = max(0, state.cur_y - 1)
                elif event.key == pygame.K_DOWN:
                    state.cur_y = min(state.size - 1, state.cur_y + 1)
                elif event.key in (pygame.K_SPACE, pygame.K_d):
                    set_pixel(state.cur_x, state.cur_y, 1)
                elif event.key in (pygame.K_e, pygame.K_BACKSPACE):
                    set_pixel(state.cur_x, state.cur_y, 0)
                elif event.key == pygame.K_c:
                    for yy in range(state.size):
                        for xx in range(state.size):
                            state.pixels[yy][xx] = 0
                    state.dirty = True
                    state.status = "Cleared"
                elif event.key == pygame.K_i:
                    for yy in range(state.size):
                        for xx in range(state.size):
                            state.pixels[yy][xx] = 0 if state.pixels[yy][xx] else 1
                    state.dirty = True
                    state.status = "Inverted"
                elif event.key == pygame.K_s:
                    save_fon(state.file_path, state.pixels, state.size)
                    state.dirty = False
                    state.status = f"Saved: {state.file_path}"
                elif event.key == pygame.K_F6:
                    state.save_as_mode = True
                    state.save_as_text = str(state.file_path)
                    state.status = ""

            elif event.type == pygame.MOUSEBUTTONDOWN:
                mx, my = event.pos
                if left <= mx < left + grid_px and top <= my < top + grid_px:
                    gx = (mx - left) // cell
                    gy = (my - top) // cell
                    state.cur_x, state.cur_y = gx, gy
                    if event.button == 1:
                        set_pixel(gx, gy, 1)
                    elif event.button == 3:
                        set_pixel(gx, gy, 0)

        screen.fill((235, 235, 235))
        draw_grid(screen, state, left, top, cell)
        draw_preview(screen, state, preview_x, preview_y)
        draw_help(screen, font, state, right_panel_x, preview_y + state.size * 4 + 16)

        if state.save_as_mode:
            draw_save_as_overlay(screen, font, state, width, height)

        pygame.display.flip()
        clock.tick(60)

    pygame.quit()

    if state.dirty:
        print("Warning: unsaved changes")
    return 0


def main(argv: list[str] | None = None) -> int:
    args = make_parser().parse_args(argv)
    requested_size = None
    if args.size is not None:
        requested_size = clamp_size(args.size)

    return run_editor(Path(args.file), requested_size)


if __name__ == "__main__":
    raise SystemExit(main())
