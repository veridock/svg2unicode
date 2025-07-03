#!/bin/bash
# svg2emoji-chafa.sh

svg_emoji() {
    local svg_file="$1"
    local size="${2:-16}"
    
    if [[ ! -f "$svg_file" ]]; then
        echo "❓"
        return 1
    fi
    
    local temp_thumb=$(mktemp --suffix=.png)
    
    # Konwersja SVG do PNG
    if command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w "$size" -h "$size" "$svg_file" > "$temp_thumb"
    elif command -v convert &> /dev/null; then
        convert "$svg_file" -resize "${size}x${size}" "$temp_thumb"
    else
        echo "Brak narzędzi do konwersji SVG"
        rm "$temp_thumb"
        return 1
    fi
    
    # Wyświetlanie jako ASCII art
    if command -v chafa &> /dev/null; then
        chafa --size="${size}x${size}" --format=symbols "$temp_thumb" | tr -d '\n'
    else
        echo -n "[$(basename "$svg_file" .svg)]"
    fi
    
    rm "$temp_thumb"
}

# Instalacja chafa jeśli nie ma
if ! command -v chafa &> /dev/null; then
    echo "Instalowanie chafa..."
    if command -v apt &> /dev/null; then
        sudo apt install chafa
    elif command -v dnf &> /dev/null; then
        sudo dnf install chafa
    elif command -v pacman &> /dev/null; then
        sudo pacman -S chafa
    fi
fi

svg_emoji "$1" "$2"