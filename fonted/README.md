# Fonted (Python Port)

This is a Python port of `shacky_t/foned90.pas` (chosen over `foned.pas` because it supports arbitrary filenames and save-as behavior).

## Requirements

- Python 3.10+
- `pygame`

```bash
pip install pygame
```

## Run

From repo root:

```bash
python fonted/fonted.py [path/to/file.fon] [--size N]
```

Examples:

```bash
python fonted/fonted.py shacky_t/prince.fon
python fonted/fonted.py new_sprite.fon --size 50
```

If file exists, it is loaded. If not, a blank grid is created.

## Controls

- Arrow keys: move cursor
- `Space` / `D`: plot pixel
- `E` / `Backspace`: erase pixel
- `C`: clear
- `I`: invert
- `S`: save to current file
- `F6`: save as (type filename, Enter)
- `Q` / `Esc`: quit
- Mouse left/right on grid: plot/erase

## File format

`.fon` files are plain text bitmaps with lines of `0` and `1`.
