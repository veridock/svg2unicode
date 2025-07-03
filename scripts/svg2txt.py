#!/usr/bin/env python3
"""
svg2txt - Convert SVG to text-based art for terminal display

Usage:
    ./svg2txt.py input.svg [width] [--charset=CHARSET]

Examples:
    ./svg2txt.py example.svg 64
    ./svg2txt.py example.svg 80 --charset=blocks
    ./svg2txt.py example.svg 100 --charset=shades
    ./svg2txt.py example.svg 120 --charset=ascii

Character sets:
    blocks: ░▒▓█ (best for simple graphics)
    shades: .:-=+*#%@ (smooth gradients)
    ascii: .,:;+*?%S#@ (standard ASCII art)
"""

import argparse
import os
import sys
from io import BytesIO

try:
    from PIL import Image, ImageEnhance, ImageOps
except ImportError:
    print("Error: PIL (Pillow) is required. Install with:")
    print("    pip install --user Pillow")
    sys.exit(1)

def get_absolute_path(relative_path):
    """Convert relative path to absolute path."""
    if os.path.isabs(relative_path):
        return relative_path
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), relative_path)

def load_svg_as_image(svg_path, width=64):
    """Convert SVG to a PIL Image with the specified width."""
    try:
        # Convert to absolute path
        abs_svg_path = get_absolute_path(svg_path)
        
        if not os.path.exists(abs_svg_path):
            raise FileNotFoundError(f"SVG file not found: {abs_svg_path}")
            
        # First try using cairosvg for better SVG rendering
        try:
            import cairosvg
            with open(abs_svg_path, 'rb') as f:
                # Calculate height to maintain aspect ratio
                try:
                    img = Image.open(abs_svg_path)
                    aspect_ratio = img.height / img.width
                    height = int(width * aspect_ratio)
                except Exception as e:
                    # If we can't open with PIL, use default aspect ratio
                    print(f"Warning: Could not determine aspect ratio: {e}")
                    height = width // 2
                
                # Generate PNG data from SVG
                png_data = cairosvg.svg2png(
                    file_obj=f,
                    output_width=width,
                    output_height=height
                )
                return Image.open(BytesIO(png_data)).convert('L')  # Convert to grayscale
                
        except ImportError:
            print("Note: cairosvg not found. Using basic SVG rendering. Install with:")
            print("    pip install --user cairosvg")
            
            # Fallback to PIL's basic SVG renderer
            img = Image.open(svg_path)
            aspect_ratio = img.height / img.width
            height = int(width * aspect_ratio)
            return img.convert('L').resize((width, height), Image.Resampling.LANCZOS)
            
    except Exception as e:
        print(f"Error loading SVG: {e}")
        sys.exit(1)

def get_character_set(name='shades'):
    """Return a character set for ASCII art."""
    charsets = {
        'blocks': ' ░▒▓█',
        'shades': ' .:-=+*#%@',
        'ascii': ' .,:;+*?%S#@',
        'detailed': ' .\'\"^:;Il!i><~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$',
        'minimal': ' .:-=+*#%@@',
    }
    return charsets.get(name.lower(), charsets['shades'])

def image_to_text(image, width=64, charset='shades'):
    """Convert a PIL Image to ASCII art.
    
    Args:
        image: PIL Image object
        width: Width of output in characters
        charset: Name of character set to use
        
    Returns:
        str: ASCII art representation of the image
    """
    # Get the character set
    chars = get_character_set(charset)
    
    # Calculate height to maintain aspect ratio (terminal chars are ~2x taller than wide)
    aspect_ratio = image.height / image.width
    height = int(width * aspect_ratio * 0.5)
    if height < 1:
        height = 1
    
    # Convert to grayscale if needed
    if image.mode != 'L':
        image = image.convert('L')
    
    # Enhance contrast
    image = ImageEnhance.Contrast(image).enhance(1.5)
    
    # Resize using high-quality downsampling
    image = image.resize((width, height), Image.Resampling.LANCZOS)
    
    # Normalize brightness and contrast
    image = ImageOps.autocontrast(image, cutoff=1)
    
    # Get pixel data
    pixels = list(image.getdata())
    
    # Build the ASCII art
    ascii_art = []
    for y in range(height):
        line = []
        for x in range(width):
            # Get pixel value (0-255)
            pixel = pixels[y * width + x]
            # Map to character (invert because terminal backgrounds are usually dark)
            char_idx = int((255 - pixel) * (len(chars) - 1) / 255)
            char_idx = max(0, min(len(chars) - 1, char_idx))
            line.append(chars[char_idx])
        ascii_art.append(''.join(line))
    
    return '\n'.join(ascii_art)

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='Convert SVG to text art')
    parser.add_argument('input', help='Input SVG file')
    parser.add_argument('width', type=int, nargs='?', default=64,
                      help='Width of output in characters (default: 64)')
    parser.add_argument('--charset', default='shades',
                      choices=['blocks', 'shades', 'ascii', 'detailed', 'minimal'],
                      help='Character set to use (default: shades)')
    parser.add_argument('--no-border', action='store_true',
                      help='Disable the border around the output')
    return parser.parse_args()

def main():
    args = parse_arguments()
    
    try:
        # Load and convert the SVG
        image = load_svg_as_image(args.input, args.width)
        
        # Convert to ASCII art
        ascii_art = image_to_text(image, args.width, args.charset)
        
        # Add border if requested
        if not args.no_border:
            border = "─" * (args.width + 2)
            print(f"┌{border}┐")
            for line in ascii_art.split('\n'):
                print(f"│ {line} │")
            print(f"└{border}┘")
        else:
            print(ascii_art)
            
        # Print character set info
        if not args.no_border:
            print(f"\nCharacter set: {get_character_set(args.charset)!r}")
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
