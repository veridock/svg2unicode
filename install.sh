#!/bin/bash
# install.sh - Instalator zależności dla svg2unicode

set -e  # Zatrzymaj przy pierwszym błędzie

echo "🔄 Instalacja zależności dla svg2unicode..."

# Funkcja sprawdzająca czy polecenie istnieje
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Funkcja instalująca pakiety
install_packages() {
    if command_exists apt-get; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y librsvg2-bin kitty imagemagick
    elif command_exists dnf; then
        # Fedora
        sudo dnf install -y librsvg2-tools kitty ImageMagick
    elif command_exists yum; then
        # CentOS/RHEL
        sudo yum install -y librsvg2-tools ImageMagick
        echo "⚠  Instalacja Kitty wymaga ręcznej konfiguracji na RHEL/CentOS"
        echo "   Zobacz: https://sw.kovidgoyal.net/kitty/binary.html"
    elif command_exists pacman; then
        # Arch Linux
        sudo pacman -S --needed --noconfirm librsvg kitty imagemagick
    else
        echo "❌ Nieznany menedżer pakietów. Zainstaluj ręcznie:"
        echo "   - librsvg (lub rsvg-convert)"
        echo "   - kitty (opcjonalnie, do wyświetlania obrazków)"
        echo "   - ImageMagick"
        exit 1
    fi
}

# Sprawdź i zainstaluj zależności
if ! command_exists rsvg-convert || ! command_exists convert || ! command_exists kitty; then
    echo "🔍 Wykrywam system..."
    install_packages
else
    echo "✅ Wszystkie wymagane narzędzia są już zainstalowane"
fi

# Instalacja dodatkowych narzędzi (opcjonalne)
echo "📦 Instalacja dodatkowych narzędzi..."
if ! command_exists chafa; then
    if command_exists cargo; then
        echo "📦 Instalacja chafa (do wyświetlania obrazków w terminalu)..."
        cargo install chafa
    else
        echo "ℹ  Zainstaluj 'chafa' dla lepszego podglądu obrazków:"
        echo "   cargo install chafa"
    fi
fi

# Ustawienie uprawnień do skryptów
echo "🔒 Ustawianie uprawnień..."
chmod +x scripts/*.sh

# Instalacja zależności Pythona (jeśli istnieje requirements.txt)
if [ -f "requirements.txt" ]; then
    echo "🐍 Instalacja zależności Pythona..."
    pip install -r requirements.txt
fi

echo "✨ Instalacja zakończona pomyślnie!"
echo "   Możesz teraz używać skryptów z katalogu scripts/"

exit 0
