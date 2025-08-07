#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper"
SWWW_DIR="$HOME/.config/swww"
CACHE_DIR="$SWWW_DIR/.cache"
PREVIEW_DIR="$SWWW_DIR/.previews"

# Ensure directories exist
mkdir -p "$WALLPAPER_DIR" "$SWWW_DIR" "$CACHE_DIR" "$PREVIEW_DIR"

# Function to get preview (generate only if doesn't exist)
get_preview() {
    local wallpaper_path="$1"
    local wallpaper_name=$(basename "$wallpaper_path")
    local preview_path="$PREVIEW_DIR/${wallpaper_name}.preview.png"
    
    # If preview already exists, return it immediately
    if [ -f "$preview_path" ]; then
        echo "$preview_path"
        return
    fi
    
    # Generate preview in background
    (
        if command -v magick &> /dev/null; then
            magick "$wallpaper_path" -strip -resize 64x64^ -gravity center -extent 64x64 -quality 60 "$preview_path" 2>/dev/null
        elif command -v convert &> /dev/null; then
            convert "$wallpaper_path" -strip -resize 64x64^ -gravity center -extent 64x64 -quality 60 "$preview_path" 2>/dev/null
        else
            cp "$wallpaper_path" "$preview_path"
        fi
    ) &
    
    # Return placeholder immediately
    echo "/usr/share/icons/hicolor/scalable/mimetypes/image-x-generic.svg"
}

# Function to update rofi backgrounds (use cache if available)
update_rofi_backgrounds() {
    local wallpaper_path="$1"
    local wallpaper_name=$(basename "$wallpaper_path")
    local blur_cache="$CACHE_DIR/${wallpaper_name}.blur.jpg"
    local rofi_cache="$CACHE_DIR/${wallpaper_name}.rofi.png"  # Changed to PNG for max quality
    
    # If both cache files exist, just link them (instant)
    if [ -f "$blur_cache" ] && [ -f "$rofi_cache" ]; then
        ln -sf "$blur_cache" "$SWWW_DIR/wall.blur"
        ln -sf "$rofi_cache" "$SWWW_DIR/wall.rofi"
        return
    fi
    
    # Generate cache files (only if missing)
    (
        if command -v magick &> /dev/null; then
            # Generate blur for main background (keep current quality)
            if [ ! -f "$blur_cache" ]; then
                magick "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x20 -quality 75 "$blur_cache" 2>/dev/null
            fi
            
            if [ ! -f "$rofi_cache" ]; then
                magick "$wallpaper_path" \
                    -resize 1920x1080^ \
                    -gravity center \
                    -extent 1920x1080 \
                    -blur 0x3 \
                    -unsharp 0x1+1.0+0.02 \
                    -quality 100 \
                    "$rofi_cache" 2>/dev/null
            fi
        elif command -v convert &> /dev/null; then
            if [ ! -f "$blur_cache" ]; then
                convert "$wallpaper_path" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x20 -quality 75 "$blur_cache" 2>/dev/null
            fi
            if [ ! -f "$rofi_cache" ]; then
                convert "$wallpaper_path" \
                    -resize 1920x1080^ \
                    -gravity center \
                    -extent 1920x1080 \
                    -blur 0x3 \
                    -unsharp 0x1+1.0+0.02 \
                    -quality 100 \
                    "$rofi_cache" 2>/dev/null
            fi
        else
            # Fallback: just copy
            [ ! -f "$blur_cache" ] && cp "$wallpaper_path" "$blur_cache"
            [ ! -f "$rofi_cache" ] && cp "$wallpaper_path" "$rofi_cache"
        fi
        
        # Link the cache files
        ln -sf "$blur_cache" "$SWWW_DIR/wall.blur"
        ln -sf "$rofi_cache" "$SWWW_DIR/wall.rofi"
    ) &
}

# Function to set wallpaper
set_wallpaper() {
    local wallpaper_path="$1"
    
    # Update rofi backgrounds (using cache if available)
    update_rofi_backgrounds "$wallpaper_path"
    
    # Save current wallpaper
    echo "$wallpaper_path" > "$SWWW_DIR/current_wallpaper"
    
    # Start swww daemon if not running
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon &
        sleep 1
    fi
    
    # Set the wallpaper
    swww img "$wallpaper_path" \
        --transition-type grow \
        --transition-pos 0.854,0.977\
        --transition-duration 0.7 \
        --transition-fps 60 \
        --transition-bezier .43,1.19,1,.4 2>/dev/null &
    
    # Notification with wallpaper preview
    if command -v notify-send &> /dev/null; then
        notify-send "󰸉 Wallpaper Changed" "$(basename "$wallpaper_path")" \
            -t 3000 \
            -i "$wallpaper_path" &
    fi

}

# Function to regenerate current wallpaper backgrounds
regenerate_current_wallpaper() {
    if [ -f "$SWWW_DIR/current_wallpaper" ]; then
        local current_wallpaper=$(cat "$SWWW_DIR/current_wallpaper")
        if [ -f "$current_wallpaper" ]; then
            # Force regeneration by removing cache first
            local wallpaper_name=$(basename "$current_wallpaper")
            rm -f "$CACHE_DIR/${wallpaper_name}.blur.jpg" "$CACHE_DIR/${wallpaper_name}.rofi.jpg"
            
            # Regenerate backgrounds
            update_rofi_backgrounds "$current_wallpaper"
            
            if command -v notify-send &> /dev/null; then
                notify-send "󰚃 Cache Cleared" "Regenerating current wallpaper backgrounds..." -t 2000 &
            fi
        fi
    fi
}

# Function to list all wallpapers
list_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo -e " Open wallpaper folder\x00icon\x1ffolder"
        return
    fi
    
    # Get current wallpaper
    local current_wallpaper=""
    if [ -f "$SWWW_DIR/current_wallpaper" ]; then
        current_wallpaper=$(cat "$SWWW_DIR/current_wallpaper")
    fi
    
    # List all wallpapers
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null | sort | while read -r wallpaper; do
        local name=$(basename "$wallpaper" | sed 's/\.[^.]*$//')
        local preview_icon=$(get_preview "$wallpaper")
        
        if [ "$wallpaper" = "$current_wallpaper" ]; then
            echo -e "$name ⭐\x00icon\x1f$preview_icon"
        else
            echo -e "$name\x00icon\x1f$preview_icon"
        fi
    done
    
    # Management options
    echo -e " Open folder\x00icon\x1ffolder"
    echo -e "󰚃 Clear cache\x00icon\x1fedit-clear"
}

# Main logic
case "${1:-}" in
    "")
        # List mode
        list_wallpapers
        ;;
        
    " Open folder"*)
        # Close rofi first, then open file manager
        pkill rofi 2>/dev/null
        sleep 0.2
        
        # Open file manager in background
        (
            if command -v xdg-open &> /dev/null; then
                xdg-open "$WALLPAPER_DIR" 2>/dev/null
            elif command -v nautilus &> /dev/null; then
                nautilus "$WALLPAPER_DIR" 2>/dev/null
            elif command -v dolphin &> /dev/null; then
                dolphin "$WALLPAPER_DIR" 2>/dev/null
            elif command -v thunar &> /dev/null; then
                thunar "$WALLPAPER_DIR" 2>/dev/null
            fi
        ) &
        ;;
        
    "󰚃 Clear cache"*)
        # Clear all caches
        rm -rf "$PREVIEW_DIR"/* "$CACHE_DIR"/*
        mkdir -p "$PREVIEW_DIR" "$CACHE_DIR"
        
        # Regenerate current wallpaper backgrounds
        regenerate_current_wallpaper
        
        # Don't restart rofi, just show notification
        if command -v notify-send &> /dev/null; then
            notify-send "󰚃 Cache Cleared" "All cache cleared and current wallpaper regenerated!" -t 3000 &
        fi
        ;;
        
    *)
        # Wallpaper selection
        clean_name=$(echo "$1" | sed 's/ ⭐$//')
        
        # Find and set wallpaper
        find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null | while read -r wallpaper; do
            name_no_ext=$(basename "$wallpaper" | sed 's/\.[^.]*$//')
            if [ "$name_no_ext" = "$clean_name" ]; then
                set_wallpaper "$wallpaper"
                break
            fi
        done
        ;;
esac