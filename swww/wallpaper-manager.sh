#!/bin/bash
# SWWW Wallpaper Management Functions
SWWW_DIR="$HOME/.config/swww"
CACHE_DIR="$SWWW_DIR/.cache"

# Ensure directories exist
mkdir -p "$SWWW_DIR"
mkdir -p "$CACHE_DIR"

# Function to check and start swww daemon
ensure_swww_daemon() {
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon &
        sleep 2
    fi
}

# Function to generate cached images
generate_cache() {
    local wallpaper_path="$1"
    local wallpaper_name=$(basename "$wallpaper_path")
    local cache_base="$CACHE_DIR/${wallpaper_name}"
    
    # Generate blurred versions - try magick first, then convert
    if command -v magick &> /dev/null; then
        magick "$wallpaper_path" -blur 0x20 "${cache_base}.blur" 2>/dev/null || cp "$wallpaper_path" "${cache_base}.blur"
        magick "$wallpaper_path" -blur 0x8 "${cache_base}.rofi" 2>/dev/null || cp "$wallpaper_path" "${cache_base}.rofi"
    elif command -v convert &> /dev/null; then
        convert "$wallpaper_path" -blur 0x20 "${cache_base}.blur" 2>/dev/null || cp "$wallpaper_path" "${cache_base}.blur"
        convert "$wallpaper_path" -blur 0x8 "${cache_base}.rofi" 2>/dev/null || cp "$wallpaper_path" "${cache_base}.rofi"
    else
        cp "$wallpaper_path" "${cache_base}.blur"
        cp "$wallpaper_path" "${cache_base}.rofi"
    fi
}

# Function to update control files
update_control_files() {
    local wallpaper_path="$1"
    local wallpaper_name=$(basename "$wallpaper_path")
    local cache_base="$CACHE_DIR/${wallpaper_name}"
    
    echo "1|Current|$wallpaper_path" > "$SWWW_DIR/wall.ctl"
    echo "$wallpaper_path" > "$SWWW_DIR/wall.set"
    echo "${cache_base}.blur" > "$SWWW_DIR/wall.blur"
    echo "${cache_base}.rofi" > "$SWWW_DIR/wall.rofi"
}

# Function to apply wallpaper
apply_wallpaper() {
    local wallpaper_path="$1"
    
    ensure_swww_daemon
    
    swww img "$wallpaper_path" \
        --transition-type grow \
        --transition-pos 0.854,0977 \
        --transition-duration 0.7 \
        --transition-fps 60 \
        --transition-bezier .43,1.19,1,.4 2>/dev/null
}

# Main function to set wallpaper with cache
set_wallpaper_with_cache() {
    local wallpaper_path="$1"
    
    if [ ! -f "$wallpaper_path" ]; then
        return 1
    fi
    
    echo "Setting wallpaper: $(basename "$wallpaper_path")"
    generate_cache "$wallpaper_path"
    update_control_files "$wallpaper_path"
    apply_wallpaper "$wallpaper_path"
    echo "Wallpaper set successfully!"
}

# Export functions
export -f ensure_swww_daemon
export -f generate_cache
export -f update_control_files
export -f apply_wallpaper
export -f set_wallpaper_with_cache