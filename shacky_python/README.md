# Shacky Tale Python Port

Python/pygame port of the original Turbo Pascal game in `shacky_t/`.

## Requirements

- Python 3.10+
- `pygame`

Install dependency:

```bash
pip install pygame
```

## Run

From repository root:

```bash
python shacky_python/main.py
```

## Controls

- Move: arrow keys or numpad `8/4/6/2`
- Attack: `A` or `Space`, then direction key
- Map view: `M`
- Exit: `Esc`

## Notes

- Rendering is black/white to match Hercules-era look.
- Sprites are loaded from `shacky_t/*.fon`.
- If `shacky_t/map2.map` is missing, the port generates a fallback map with key story locations.
- Input buffering truncates repeated movement key storms and adds cooldown to smooth movement.
