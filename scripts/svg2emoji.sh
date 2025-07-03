#!/bin/bash
# svg-emoji.sh
# sudo dnf install librsvg2-tools kitty
svg_emoji() {
    local svg_file="$1"
    local size="${2:-20}"
    
    # Tymczasowa miniatura
    temp_thumb=$(mktemp --suffix=.png)
    rsvg-convert -w "$size" -h "$size" "$svg_file" > "$temp_thumb"
    
    # Wyświetlanie jako inline emoji
    kitty +kitten icat --align=left --place=1x1@0x0 "$temp_thumb"
    
    rm "$temp_thumb"
}

# Użycie
svg_emoji "examples/dashboard.svg" 16