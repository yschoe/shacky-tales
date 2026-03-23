#!/usr/bin/env python3
"""Shacky Tale Python port (black/white), based on original Turbo Pascal gameplay."""

from __future__ import annotations

import random
import sys
import time
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

import pygame

# Grid and rendering constants (match original layout proportions)
MAP_W = 72
MAP_H = 36
VIEW_W = 11
VIEW_H = 5
TILE = 50
SCREEN_W = 720
SCREEN_H = 348
VIEW_ORIGIN = (30, 20)
PLAYER_VIEW_CELL = (5, 2)
FPS = 60
MOVE_COOLDOWN_MS = 110
ACTION_COOLDOWN_MS = 70
INPUT_BUFFER_MAX = 3
WORLD_TICK_MS = 240
MAX_HP_LOSS_PER_WORLD_TICK = 1
SPAWN_COOLDOWN_MS = 1200
SPAWN_WAVE_CHANCE = 0.45
SPAWN_PER_TYPE_CHANCE = 0.55

# HUD bars (0..480)
HP_UPRATE = 50
EXP_RATE = 24
MAX_BAR = 480

WHITE = (240, 240, 240)
BLACK = (0, 0, 0)


@dataclass
class Monster:
    who: str
    x: int
    y: int
    hits: int


ASSET_ALIASES = {
    "mount.fon": "rock.fon",
    "house.fon": "tomb.fon",
    "lgswd.fon": "shswd.fon",
    "map.fon": "blank.fon",
}

SPRITE_FILES = {
    "player_r": "prince.fon",
    "player_l": "pr2.fon",
    "player_u": "pru.fon",
    "player_d": "prd.fon",
    "princess": "princess.fon",
    "skeleton": "skeleton.fon",
    "fox": "fox.fon",
    "bat": "bat.fon",
    "slime": "slime.fon",
    "mount": "mount.fon",
    "tree": "tree.fon",
    "water": "water.fon",
    "blank": "blank.fon",
    "anya": "anya.fon",
    "choco": "choco.fon",
    "tomb": "tomb.fon",
    "shoem": "shoem.fon",
    "cave": "cave.fon",
    "vend": "vend.fon",
    "house": "house.fon",
    "shswd": "shswd.fon",
    "lgswd": "lgswd.fon",
    "saber": "saber.fon",
    "anhome": "anhome.fon",
    "shoes": "shoes.fon",
    "wall": "wall.fon",
    "gem": "gem.fon",
    "caveend": "caveend.fon",
    "smash": "smash.fon",
    "heart": "heart.fon",
    "smack": "smack.fon",
}

TILE_TO_SPRITE = {
    "0": "blank",
    "1": "tree",
    "2": "mount",
    "3": "water",
    "f": "fox",
    "s": "skeleton",
    "b": "bat",
    "S": "slime",
    "c": "cave",
    "C": "caveend",
    "h": "house",
    "v": "vend",
    "w": "wall",
    "A": "anhome",
}

MESSAGES = {
    0: [
        "The old grave watch man says:",
        "Please save us from the fire-breath dragon.",
        "Go to wizardess Anya for help.",
        "Before you go you must..zzz.",
        "He fell asleep before he gave you the clue!",
    ],
    1: [
        "Look! You discovered something.",
        "You see it is a chocolate.",
        "You put it in your pocket.",
        "YUMMY",
    ],
    2: [
        "Anya: I know you've come to ask help.",
        "But I won't speak until you bring me chocolate.",
        "Come back with one.",
    ],
    3: [
        "Anya: Ah! Good!",
        "Take this jewel and buy magic shoes.",
        "Use them to get into the cave.",
        "Good luck!",
    ],
    4: [
        "Shoe merchant: You need Anya's jewel.",
        "Come back when you have it.",
    ],
    5: [
        "Shoe merchant: You've got the jewel.",
        "Here are winged shoes.",
        "Beware of creatures in the cave.",
    ],
    6: [
        "Princess: Well, you're here at last.",
        "In the cave, find ULTIMARR and the way to DARR.",
        "End of stage 1.",
    ],
}


class InputBuffer:
    """Queue with duplicate suppression and truncation for movement-heavy keys."""

    def __init__(self, maxlen: int = INPUT_BUFFER_MAX) -> None:
        self._queue: deque[str] = deque(maxlen=maxlen)
        self._last_key = ""
        self._last_ts = 0

    def push(self, action: str, now_ms: int) -> None:
        # Truncate repeat storms: identical action inside short window is ignored.
        if action == self._last_key and now_ms - self._last_ts < 90:
            return

        # Keep only newest movement intent when queue is crowded.
        if action.startswith("move_"):
            for i in range(len(self._queue) - 1, -1, -1):
                if self._queue[i].startswith("move_"):
                    del self._queue[i]
                    break

        self._queue.append(action)
        self._last_key = action
        self._last_ts = now_ms

    def pop(self) -> str | None:
        if not self._queue:
            return None
        return self._queue.popleft()

    def clear(self) -> None:
        self._queue.clear()


class Game:
    def __init__(self) -> None:
        pygame.init()
        pygame.display.set_caption("Shacky Tale (Python)")
        self.screen = pygame.display.set_mode((SCREEN_W, SCREEN_H))
        self.clock = pygame.time.Clock()
        self.font = pygame.font.SysFont("Courier New", 16)
        self.small = pygame.font.SysFont("Courier New", 13)
        self.big = pygame.font.SysFont("Courier New", 28, bold=True)

        self.base_dir = Path(__file__).resolve().parent
        self.asset_dir = (self.base_dir / "../shacky_t").resolve()

        self.sprites = self._load_sprites()
        self.map_data = self._load_or_generate_map()

        self.player_x = 8
        self.player_y = 30
        self.player_facing = "r"

        self.hp = 200
        self.exp = 0
        self.killed = 0

        self.choco_num = 0
        self.shoes_num = 0
        self.gem_num = 0
        self.mes_num = 0
        self.special_positions = self._find_special_positions()

        self.monsters: List[Monster] = []
        self.break_game = False
        self.victory = False

        self.buffer = InputBuffer()
        self.pending_attack = False
        self.last_move_ms = 0
        self.last_action_ms = 0
        self.last_world_tick_ms = 0
        self.last_spawn_ms = 0
        self.message_lines: List[str] = []

    def _fon_path(self, name: str) -> Path:
        path = self.asset_dir / name
        if path.exists():
            return path
        alias = ASSET_ALIASES.get(name)
        if alias and (self.asset_dir / alias).exists():
            return self.asset_dir / alias
        return self.asset_dir / "blank.fon"

    def _load_fon(self, name: str) -> pygame.Surface:
        surf = pygame.Surface((TILE, TILE))
        surf.fill(BLACK)
        path = self._fon_path(name)
        try:
            lines = path.read_text(encoding="ascii", errors="ignore").splitlines()
        except OSError:
            lines = []
        for y in range(min(TILE, len(lines))):
            row = lines[y]
            for x in range(min(TILE, len(row))):
                if row[x] == "1":
                    surf.set_at((x, y), WHITE)
        return surf.convert()

    def _load_sprites(self) -> Dict[str, pygame.Surface]:
        sprites: Dict[str, pygame.Surface] = {}
        for key, filename in SPRITE_FILES.items():
            sprites[key] = self._load_fon(filename)
        return sprites

    def _load_or_generate_map(self) -> List[List[str]]:
        candidate_paths = [
            self.base_dir / "map2.map",
            self.asset_dir / "map2.map",
        ]
        for map_path in candidate_paths:
            if map_path.exists():
                lines = map_path.read_text(encoding="ascii", errors="ignore").splitlines()
                lines = [line[:MAP_W].ljust(MAP_W, "0") for line in lines[:MAP_H]]
                while len(lines) < MAP_H:
                    lines.append("0" * MAP_W)
                return [[c for c in row] for row in lines]

        # Fallback handcrafted map when no map file is present.
        grid = [["1" for _ in range(MAP_W)] for _ in range(MAP_H)]
        for y in range(MAP_H):
            for x in range(MAP_W):
                if x in (0, MAP_W - 1) or y in (0, MAP_H - 1):
                    grid[y][x] = "2"
                elif (x + 2 * y) % 17 == 0:
                    grid[y][x] = "2"

        # Carve trails.
        for x in range(2, MAP_W - 2):
            grid[30][x] = "0"
        for y in range(6, MAP_H - 2):
            grid[y][8] = "0"
        for y in range(4, MAP_H - 3):
            grid[y][58] = "0"
        for x in range(8, 59):
            grid[10][x] = "0"

        # Large water with island.
        cx, cy, rx, ry = 53, 16, 14, 9
        for y in range(2, MAP_H - 2):
            for x in range(2, MAP_W - 2):
                if ((x - cx) * (x - cx)) / (rx * rx) + ((y - cy) * (y - cy)) / (ry * ry) <= 1.0:
                    grid[y][x] = "3"
        icx, icy, irx, iry = 55, 16, 4, 3
        for y in range(icy - iry - 1, icy + iry + 2):
            for x in range(icx - irx - 1, icx + irx + 2):
                if 0 <= x < MAP_W and 0 <= y < MAP_H:
                    if ((x - icx) * (x - icx)) / (irx * irx) + ((y - icy) * (y - icy)) / (iry * iry) <= 1.0:
                        grid[y][x] = "0"

        # Story points.
        grid[31][14] = "c"   # chocolate cave
        grid[8][18] = "h"    # tomb
        grid[17][5] = "v"    # shoe maker (opposite side)
        grid[16][55] = "A"   # goddess on island
        grid[16][58] = "C"   # stage-end cave marker on island

        return grid

    def _find_special_positions(self) -> Dict[str, Tuple[int, int]]:
        found: Dict[str, Tuple[int, int]] = {}
        for y in range(MAP_H):
            for x in range(MAP_W):
                ch = self.map_data[y][x]
                if ch in {"c", "h", "A", "v", "C"} and ch not in found:
                    found[ch] = (x, y)
        return found

    def wrap(self, x: int, y: int) -> Tuple[int, int]:
        return x % MAP_W, y % MAP_H

    def tile(self, x: int, y: int) -> str:
        x, y = self.wrap(x, y)
        return self.map_data[y][x]

    def set_tile(self, x: int, y: int, val: str) -> None:
        x, y = self.wrap(x, y)
        self.map_data[y][x] = val

    def level(self, who: str) -> int:
        return {"f": 1, "s": 2, "b": 3, "S": 4}.get(who, 1)

    def draw_frame(self) -> None:
        self.screen.fill(BLACK)
        pygame.draw.rect(self.screen, WHITE, (0, 0, SCREEN_W - 1, SCREEN_H - 1), 1)
        pygame.draw.rect(self.screen, WHITE, (29, 19, 551, 251), 1)
        pygame.draw.rect(self.screen, WHITE, (100, 280, 481, 20), 1)
        pygame.draw.rect(self.screen, WHITE, (100, 310, 481, 20), 1)
        pygame.draw.rect(self.screen, WHITE, (590, 70, 120, 200), 1)
        pygame.draw.rect(self.screen, WHITE, (589, 279, 52, 52), 1)
        pygame.draw.rect(self.screen, WHITE, (654, 279, 52, 52), 1)

        self.blit_text("H.P.", 30, 282)
        self.blit_text("EXP.", 30, 312)
        self.blit_text("MESSAGES", 604, 75)
        self.blit_text("WEAPON", 592, 272)
        self.blit_text("ITEMS", 660, 272)
        self.blit_text("Shacky Tale", 600, 8, big=True)

    def blit_text(self, text: str, x: int, y: int, big: bool = False) -> None:
        surf = (self.big if big else self.font).render(text, True, WHITE)
        self.screen.blit(surf, (x, y))

    def draw_bars(self) -> None:
        hp_len = max(0, min(MAX_BAR, self.hp))
        exp_len = max(0, min(MAX_BAR, self.exp))
        if hp_len > 0:
            pygame.draw.rect(self.screen, WHITE, (101, 281, hp_len, 18))
        if exp_len > 0:
            pygame.draw.rect(self.screen, WHITE, (101, 311, exp_len, 18))

    def draw_inventory(self) -> None:
        weapon = "lgswd" if self.gem_num else "shswd"
        self.screen.blit(self.sprites[weapon], (590, 280))
        if self.shoes_num:
            self.screen.blit(self.sprites["shoes"], (655, 280))
        elif self.gem_num:
            self.screen.blit(self.sprites["gem"], (655, 280))
        elif self.choco_num:
            self.screen.blit(self.sprites["choco"], (655, 280))

    def draw_map_window(self) -> None:
        ox, oy = VIEW_ORIGIN
        for vy in range(VIEW_H):
            for vx in range(VIEW_W):
                wx = self.player_x + vx - PLAYER_VIEW_CELL[0]
                wy = self.player_y + vy - PLAYER_VIEW_CELL[1]
                ch = self.tile(wx, wy)
                sprite = self.sprites[TILE_TO_SPRITE.get(ch, "blank")]
                if (vx, vy) != PLAYER_VIEW_CELL:
                    self.screen.blit(sprite, (ox + vx * TILE, oy + vy * TILE))

        player_sprite = {
            "r": "player_r",
            "l": "player_l",
            "u": "player_u",
            "d": "player_d",
        }[self.player_facing]
        px = ox + PLAYER_VIEW_CELL[0] * TILE
        py = oy + PLAYER_VIEW_CELL[1] * TILE
        self.screen.blit(self.sprites[player_sprite], (px, py))

    def draw_message_box(self) -> None:
        pygame.draw.rect(self.screen, BLACK, (591, 71, 118, 198))
        self.blit_text("MESSAGES", 604, 75)
        y = 100
        for line in self.message_lines[:10]:
            surf = self.small.render(line[:19], True, WHITE)
            self.screen.blit(surf, (595, y))
            y += 16

    def update_exp(self) -> None:
        self.exp = self.killed * EXP_RATE
        if self.exp > MAX_BAR - EXP_RATE:
            self.exp = 0
            self.killed = 0
            self.hp = min(MAX_BAR, self.hp + HP_UPRATE)

    def attack(self, direction: str) -> None:
        dx, dy = {"n": (0, -1), "s": (0, 1), "w": (-1, 0), "e": (1, 0)}[direction]
        tx, ty = self.wrap(self.player_x + dx, self.player_y + dy)
        hit_idx = None
        for idx, m in enumerate(self.monsters):
            if m.x == tx and m.y == ty:
                hit_idx = idx
                break

        if hit_idx is None:
            return

        self.monsters[hit_idx].hits -= 1
        if self.monsters[hit_idx].hits <= 0:
            dead = self.monsters.pop(hit_idx)
            self.set_tile(dead.x, dead.y, "0")
            self.killed += 1
        self.update_exp()

    def spawn_monsters(self) -> None:
        if len(self.monsters) >= 100:
            return
        if len(self.monsters) >= 6 and not self.not_near():
            return
        now = pygame.time.get_ticks()
        if now - self.last_spawn_ms < SPAWN_COOLDOWN_MS:
            return
        if random.random() > SPAWN_WAVE_CHANCE:
            self.last_spawn_ms = now
            return
        for who in ("f", "s", "b", "S"):
            if random.random() < SPAWN_PER_TYPE_CHANCE:
                self._appear_monster(who)
        self.last_spawn_ms = now

    def _monster_region_ok(self, who: str, x: int, y: int) -> bool:
        right_water_band = x >= int(MAP_W * 0.58) and 6 <= y <= int(MAP_H * 0.72)
        north_mountains = y <= int(MAP_H * 0.38)
        west_forest = x <= int(MAP_W * 0.40)
        deep_east = x >= int(MAP_W * 0.62) and y >= int(MAP_H * 0.45)

        if who == "f":
            return west_forest or not north_mountains
        if who == "s":
            return north_mountains
        if who == "b":
            return right_water_band
        if who == "S":
            return deep_east
        return True

    def _visible_world_positions(self) -> set[Tuple[int, int]]:
        visible: set[Tuple[int, int]] = set()
        for vy in range(VIEW_H):
            for vx in range(VIEW_W):
                wx, wy = self.wrap(
                    self.player_x + vx - PLAYER_VIEW_CELL[0],
                    self.player_y + vy - PLAYER_VIEW_CELL[1],
                )
                visible.add((wx, wy))
        return visible

    def cull_offscreen_monsters(self) -> None:
        visible = self._visible_world_positions()
        kept: List[Monster] = []
        for m in self.monsters:
            if (m.x, m.y) in visible:
                kept.append(m)
            else:
                self.set_tile(m.x, m.y, "0")
        self.monsters = kept

    def not_near(self) -> bool:
        if not self.monsters:
            return True
        for m in self.monsters:
            d = abs(m.x - self.player_x) + abs(m.y - self.player_y)
            if d <= 13:
                return False
        return True

    def _appear_monster(self, who: str) -> None:
        for _ in range(10):
            choice = random.randint(0, 3)
            if choice == 0:
                tx = self.player_x - 1
                ty = self.player_y + random.randint(0, 3)
            elif choice == 1:
                tx = self.player_x + random.randint(0, 9)
                ty = self.player_y - 1
            elif choice == 2:
                tx = self.player_x + 10
                ty = self.player_y + random.randint(0, 3)
            else:
                tx = self.player_x + random.randint(0, 9)
                ty = self.player_y + 4
            tx, ty = self.wrap(tx, ty)

            if self.tile(tx, ty) == "0" and self._monster_region_ok(who, tx, ty):
                self.monsters.append(Monster(who=who, x=tx, y=ty, hits=self.level(who)))
                self.set_tile(tx, ty, who)
                return

    def move_monsters(self) -> None:
        for m in self.monsters:
            dx = (self.player_x > m.x) - (self.player_x < m.x)
            dy = (self.player_y > m.y) - (self.player_y < m.y)

            # Weighted randomness: usually chase the player, sometimes sidestep to avoid sticky clumps.
            chase = self.wrap(m.x + dx, m.y + dy)
            horiz = self.wrap(m.x + dx, m.y)
            vert = self.wrap(m.x, m.y + dy)
            sidesteps = [
                self.wrap(m.x + 1, m.y),
                self.wrap(m.x - 1, m.y),
                self.wrap(m.x, m.y + 1),
                self.wrap(m.x, m.y - 1),
            ]

            candidates = [chase, horiz, vert]
            if random.random() < 0.45:
                random.shuffle(candidates)
            else:
                random.shuffle(sidesteps)
                candidates.extend(sidesteps[:2])

            moved = False
            for nx, ny in candidates:
                if (nx, ny) == (self.player_x, self.player_y):
                    continue
                if self.tile(nx, ny) == "0":
                    self.set_tile(m.x, m.y, "0")
                    m.x, m.y = nx, ny
                    self.set_tile(m.x, m.y, m.who)
                    moved = True
                    break

            if moved:
                continue

            # If fully blocked, attempt a random local move as a final unsticking step.
            random.shuffle(sidesteps)
            for nx, ny in sidesteps:
                if (nx, ny) != (self.player_x, self.player_y) and self.tile(nx, ny) == "0":
                    self.set_tile(m.x, m.y, "0")
                    m.x, m.y = nx, ny
                    self.set_tile(m.x, m.y, m.who)
                    break

    def monster_attack(self) -> None:
        damage = 0
        for m in self.monsters:
            if abs(m.x - self.player_x) <= 1 and abs(m.y - self.player_y) <= 1:
                damage += 1
        if damage > 0:
            self.hp -= min(damage, MAX_HP_LOSS_PER_WORLD_TICK)
            if self.hp <= 0:
                self.break_game = True
                return

    def can_step_on(self, tile: str) -> bool:
        return tile in {"0", "C", "h", "c", "A", "v", "s"} or (tile == "3" and self.shoes_num == 1)

    def try_move(self, dx: int, dy: int, facing: str) -> None:
        tx, ty = self.wrap(self.player_x + dx, self.player_y + dy)
        self.player_facing = facing
        if self.can_step_on(self.tile(tx, ty)):
            self.player_x, self.player_y = tx, ty

    def check_message(self) -> None:
        self.message_lines = []
        any_message = False

        pos = (self.player_x, self.player_y)
        cave = self.special_positions.get("c")
        tomb = self.special_positions.get("h")
        goddess = self.special_positions.get("A")
        shoemaker = self.special_positions.get("v")
        cave_end = self.special_positions.get("C")

        if cave and pos == cave:
            self.mes_num = 1
            self.choco_num = 1
            any_message = True
        elif tomb and pos == tomb:
            self.mes_num = 0
            any_message = True
        elif goddess and pos == goddess:
            any_message = True
            if self.choco_num == 0:
                self.mes_num = 2
            else:
                self.mes_num = 3
                self.gem_num = 1
        elif shoemaker and pos == shoemaker:
            any_message = True
            if self.choco_num == 1 or self.gem_num == 1:
                self.mes_num = 5
                self.shoes_num = 1
            else:
                self.mes_num = 4
        elif cave_end and pos == cave_end:
            any_message = True
            self.mes_num = 6

        if any_message:
            self.message_lines = MESSAGES.get(self.mes_num, [])
            if self.mes_num == 6:
                self.victory = True
                self.break_game = True

    def full_map_view(self) -> None:
        scale = 5
        mini = pygame.Surface((MAP_W * scale, MAP_H * scale))
        mini.fill(BLACK)
        color = {
            "0": WHITE,
            "1": WHITE,
            "2": WHITE,
            "3": WHITE,
            "c": WHITE,
            "C": WHITE,
            "h": WHITE,
            "v": WHITE,
            "A": WHITE,
            "w": WHITE,
            "f": WHITE,
            "s": WHITE,
            "b": WHITE,
            "S": WHITE,
        }
        for y in range(MAP_H):
            for x in range(MAP_W):
                ch = self.map_data[y][x]
                if ch in color:
                    pygame.draw.rect(mini, color[ch], (x * scale, y * scale, scale, scale), 1 if ch != "0" else 0)
        pygame.draw.rect(mini, BLACK, (self.player_x * scale, self.player_y * scale, scale, scale))
        pygame.draw.rect(mini, WHITE, (self.player_x * scale, self.player_y * scale, scale, scale), 1)

        self.screen.fill(BLACK)
        self.screen.blit(mini, (30, 20))
        self.blit_text("MAP VIEW - press any key", 590, 90)
        pygame.display.flip()

        waiting = True
        while waiting:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    sys.exit(0)
                if event.type in (pygame.KEYDOWN, pygame.MOUSEBUTTONDOWN):
                    waiting = False
            self.clock.tick(30)

    def handle_event(self, event: pygame.event.Event) -> None:
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit(0)
        if event.type != pygame.KEYDOWN:
            return

        key = event.key
        now = pygame.time.get_ticks()
        if key == pygame.K_ESCAPE:
            self.break_game = True
            return

        if self.pending_attack:
            mapping = {
                pygame.K_UP: "atk_n",
                pygame.K_KP8: "atk_n",
                pygame.K_LEFT: "atk_w",
                pygame.K_KP4: "atk_w",
                pygame.K_DOWN: "atk_s",
                pygame.K_KP2: "atk_s",
                pygame.K_RIGHT: "atk_e",
                pygame.K_KP6: "atk_e",
            }
            action = mapping.get(key)
            self.pending_attack = False
            if action:
                self.buffer.push(action, now)
            return

        mapping = {
            pygame.K_UP: "move_u",
            pygame.K_KP8: "move_u",
            pygame.K_LEFT: "move_l",
            pygame.K_KP4: "move_l",
            pygame.K_DOWN: "move_d",
            pygame.K_KP2: "move_d",
            pygame.K_RIGHT: "move_r",
            pygame.K_KP6: "move_r",
            pygame.K_m: "view_map",
            pygame.K_SPACE: "attack_mode",
            pygame.K_a: "attack_mode",
        }
        action = mapping.get(key)
        if action:
            self.buffer.push(action, now)

    def process_action(self, action: str) -> bool:
        now = pygame.time.get_ticks()

        if action.startswith("move_") and now - self.last_move_ms < MOVE_COOLDOWN_MS:
            return False
        if action.startswith("atk_") and now - self.last_action_ms < ACTION_COOLDOWN_MS:
            return False

        if action == "move_u":
            self.try_move(0, -1, "u")
            self.last_move_ms = now
        elif action == "move_l":
            self.try_move(-1, 0, "l")
            self.last_move_ms = now
        elif action == "move_r":
            self.try_move(1, 0, "r")
            self.last_move_ms = now
        elif action == "move_d":
            self.try_move(0, 1, "d")
            self.last_move_ms = now
        elif action == "attack_mode":
            self.pending_attack = True
        elif action == "atk_n":
            self.player_facing = "u"
            self.attack("n")
            self.last_action_ms = now
        elif action == "atk_w":
            self.player_facing = "l"
            self.attack("w")
            self.last_action_ms = now
        elif action == "atk_s":
            self.player_facing = "d"
            self.attack("s")
            self.last_action_ms = now
        elif action == "atk_e":
            self.player_facing = "r"
            self.attack("e")
            self.last_action_ms = now
        elif action == "view_map":
            self.full_map_view()
        else:
            return False

        self.check_message()
        self.cull_offscreen_monsters()
        return True

    def update_world_when_idle(self) -> None:
        self.spawn_monsters()
        self.move_monsters()
        self.cull_offscreen_monsters()
        self.monster_attack()

    def draw(self) -> None:
        self.draw_frame()
        self.draw_map_window()
        self.draw_bars()
        self.draw_inventory()
        self.draw_message_box()
        coord = f"({self.player_x + 1},{self.player_y + 1})"
        self.blit_text(coord, 590, 34)
        if self.pending_attack:
            self.blit_text("Attack: choose dir", 593, 252)
        pygame.display.flip()

    def wait_for_any_key(self) -> bool:
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return False
                if event.type == pygame.KEYDOWN:
                    return True
            self.clock.tick(30)

    def splash_screen(self) -> bool:
        self.screen.fill(BLACK)
        pygame.draw.rect(self.screen, WHITE, (40, 15, 560, 76), 1)
        self.blit_text("Shacky Tale", 185, 35, big=True)
        self.screen.blit(self.sprites["princess"], (190, 170))
        self.screen.blit(self.sprites["player_l"], (320, 170))
        self.screen.blit(self.sprites["heart"], (255, 120))
        self.blit_text("PATIENCE! Loading characters...", 160, 300)
        self.blit_text("Press any key to continue", 210, 322)
        pygame.display.flip()
        return self.wait_for_any_key()

    def characters_screen(self) -> bool:
        self.screen.fill(BLACK)
        pygame.draw.rect(self.screen, WHITE, (35, 30, 630, 50), 1)
        self.blit_text("Characters", 250, 43, big=True)
        self.screen.blit(self.sprites["princess"], (90, 90))
        self.blit_text("princess", 155, 120)
        self.screen.blit(self.sprites["player_l"], (300, 90))
        self.blit_text("shacky", 365, 120)

        self.blit_text("MONSTERS", 90, 170)
        self.screen.blit(self.sprites["skeleton"], (90, 190))
        self.screen.blit(self.sprites["fox"], (145, 190))
        self.screen.blit(self.sprites["bat"], (200, 190))
        self.screen.blit(self.sprites["slime"], (255, 190))

        self.blit_text("OTHERS", 90, 265)
        self.screen.blit(self.sprites["anya"], (90, 285))
        self.screen.blit(self.sprites["tomb"], (145, 285))
        self.screen.blit(self.sprites["shoem"], (200, 285))
        self.blit_text("Press any key to start game", 350, 302)
        pygame.display.flip()
        return self.wait_for_any_key()

    def ending_screen(self) -> None:
        self.screen.fill(BLACK)
        if self.victory:
            self.blit_text("CONGRATULATIONS!", 220, 90, big=True)
            lines = ["Thank you...", "smack! smack!", "End of Stage 1"]
        elif self.hp <= 0:
            self.blit_text("YOU ARE DEAD!", 240, 90, big=True)
            lines = ["Rest in peace.", "May God bless you."]
        else:
            self.blit_text("GAME OVER", 270, 90, big=True)
            lines = ["Session ended."]

        y = 150
        for line in lines:
            self.blit_text(line, 240, y)
            y += 24
        self.blit_text("Press any key to quit", 220, 300)
        pygame.display.flip()

        waiting = True
        while waiting:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    waiting = False
                elif event.type == pygame.KEYDOWN:
                    waiting = False
            self.clock.tick(30)

    def run(self) -> None:
        if not self.splash_screen():
            pygame.quit()
            return
        if not self.characters_screen():
            pygame.quit()
            return

        self.check_message()
        while not self.break_game:
            had_action = False
            for event in pygame.event.get():
                self.handle_event(event)

            action = self.buffer.pop()
            if action:
                had_action = self.process_action(action)

            now = pygame.time.get_ticks()
            if (not had_action) and (now - self.last_world_tick_ms >= WORLD_TICK_MS):
                self.update_world_when_idle()
                self.last_world_tick_ms = now

            self.draw()
            self.clock.tick(FPS)

        self.ending_screen()
        pygame.quit()


def main() -> None:
    random.seed(int(time.time()))
    game = Game()
    game.run()


if __name__ == "__main__":
    main()
