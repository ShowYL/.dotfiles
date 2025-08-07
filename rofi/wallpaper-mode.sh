#!/bin/bash

# Wallpaper mode for rofi
WALLPAPER_DIR="$HOME/Pictures/wallpaper"
SWWW_DIR="$HOME/.config/swww"
CACHE_DIR="$SWWW_DIR/.cache"

# Ensure directories exist
mkdir -p "$SWWW_DIR"
mkdir -p "$CACHE_DIR"

# Source swww functions
source "$SWWW_DIR/wallpaper-manager.sh" 2>/dev/null || {
    echo "Error: wallpaper-manager.sh not found"
    exit 1
}

# Function to list wallpapers
list_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo " No wallpaper directory found"
        echo " Create $WALLPAPER_DIR and add images"
        return
    fi
    
    # Find all image files
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | sort | while read -r wallpaper; do
        name=$(basename "$wallpaper" | sed 's/\.[^.]*$//')
        
        # Check if this is the current wallpaper
        current_wall=""
        if [ -f "$SWWW_DIR/wall.set" ]; then
            current_wall=$(cat "$SWWW_DIR/wall.set")
        fi
        
        if [ "$wallpaper" = "$current_wall" ]; then
            echo "󰸉 $name (current)"
        else
            echo "󰸉 $name"
        fi
    done
    
    # If no wallpapers found, show message
    if [ $(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | wc -l) -eq 0 ]; then
        echo " No images found in $WALLPAPER_DIR"
    fi
}

# Function to handle selection
handle_selection() {
    local selection="$1"
    
    # Remove the emoji and " (current)" suffix to get clean name
    local clean_name=$(echo "$selection" | sed 's/^󰸉 //' | sed 's/ (current)$//')
    
    if [[ "$clean_name" == *"No wallpaper directory found"* ]] || [[ "$clean_name" == *"Create "* ]] || [[ "$clean_name" == *"No images found"* ]]; then
        # Open file manager to wallpaper directory or Pictures
        mkdir -p "$WALLPAPER_DIR"
        if command -v nautilus &> /dev/null; then
            nautilus "$WALLPAPER_DIR" 2>/dev/null &
        elif command -v dolphin &> /dev/null; then
            dolphin "$WALLPAPER_DIR" 2>/dev/null &
        elif command -v thunar &> /dev/null; then
            thunar "$WALLPAPER_DIR" 2>/dev/null &
        fi
        return
    fi
    
    # Find the wallpaper file
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | while read -r wallpaper; do
        name_no_ext=$(basename "$wallpaper" | sed 's/\.[^.]*$//')
        if [ "$name_no_ext" = "$clean_name" ]; then
            # Set the wallpaper
            set_wallpaper_with_cache "$wallpaper"
            
            # Send notification
            if command -v notify-send &> /dev/null; then
                notify-send "󰸉 Wallpaper Changed" "Set to: $clean_name" -t 3000 -i "$wallpaper"
            fi
            break
        fi
    done
}

# Main script
if [ "$1" = "--list" ]; then
    list_wallpapers
elif [ -n "$1" ]; then
    handle_selection "$1"
else
    echo "Usage: $0 --list | <selection>"
fi