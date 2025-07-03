# svg2unicode

Tiny CLI & Python library that renders SVG files directly in your terminal.

- **Raster mode** – full-width Unicode block mosaic.
- **Glyph mode**  – single-character Braille icon (`-g | --glyph`).
- Pure-Python implementation using **CairoSVG** and **Pillow**.

---

## Installation
```bash
# clone repo and install editable
git clone https://github.com/veridock/svg2unicode.git
cd svg2unicode
pip install -e .
```

## Quick start
```bash
# Full-width Unicode art (80 chars wide)
python -m svg2unicode.cli examples/pong-game.svg -w 80

# Single Braille glyph
python -m svg2unicode.cli examples/pong-game.svg --glyph
```

Example output:
```
⣿
```

---

## CLI options
| flag            | description                   | default |
|-----------------|-------------------------------|---------|
| `-w, --width N` | output width in characters    | 80      |
| `-g, --glyph`   | emit single Braille glyph     | off     |

---

## Examples

```bash
# Render a dashboard SVG as Unicode art (default width)
python -m svg2unicode.cli examples/dashboard.svg

# Render a simple chart SVG as Braille glyph
python -m svg2unicode.cli examples/simple-chart.svg --glyph
```

---

## Configuration

You can configure svg2unicode using command-line flags or environment variables:

```bash
export SVG2UNICODE_WIDTH=100
export SVG2UNICODE_HEIGHT=30
```

---

## Development

- Python 3.8+
- [Poetry](https://python-poetry.org/) for publishing
- [pytest](https://pytest.org/) for testing

Recommended workflow:
```bash
# (in project root)
make install-deps   # install dependencies
make test           # run tests
make lint           # run linter
make format         # auto-format code
```

To publish to PyPI:
```bash
poetry version patch  # bump version
poetry publish --build
```


## SVG → Unicode (1-char glyph)

> Wymagania: [ImageMagick](https://imagemagick.org/) (`magick`) + skrypt `scripts/svg2uchar`.

### Pełny proces krok-po-kroku
```bash
# 1) Zmniejsz SVG do 16×16 px (PNG)
magick convert examples/pong-game.svg -background none -resize 16x16 examples/pong-game.png

# 2) Zamień PNG na pojedynczy znak Braille
./scripts/svg2uchar examples/pong-game.png   # ⇒ ⣿
```

### Szybka ścieżka (SVG bezpośrednio)
```bash
./scripts/svg2uchar examples/pong-game.svg   # ⇒ ⣿
```

Skrypt automatycznie próbuje dopasować wzór pikseli 4×8 do 8-punktowego znaku Braille (zakres U+2800–U+28FF). Dzięki temu otrzymujesz jedną „ikonę” szeroką na jeden znak, gotową do wstawienia do promptu, tabeli lub listy.
---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.