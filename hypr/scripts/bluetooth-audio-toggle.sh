#!/bin/bash

# Bluetooth Audio Profile Toggle Script
# Toggles between high-quality audio (A2DP) and microphone mode (Headset)

CARD_NAME="bluez_card.80_99_E7_B1_8E_3B"
A2DP_PROFILE="a2dp-sink"
HEADSET_PROFILE="headset-head-unit"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get current profile
get_current_profile() {
    pactl list cards | grep -A 20 "$CARD_NAME" | grep "Active Profile:" | sed 's/.*Active Profile: //'
}

# Function to notify user
notify() {
    if command -v notify-send &> /dev/null; then
        notify-send "Bluetooth Audio" "$1"
    fi
    echo -e "$2$1$NC"
}

# Check if card exists
if ! pactl list cards | grep -q "$CARD_NAME"; then
    notify "❌ WH-1000XM4 not found or not connected" "$RED"
    exit 1
fi

# Get current profile
current_profile=$(get_current_profile)

# Toggle profile
case "$current_profile" in
    "$A2DP_PROFILE")
        echo "Switching to Headset mode (microphone enabled)..."
        pactl set-card-profile "$CARD_NAME" "$HEADSET_PROFILE"
        if [ $? -eq 0 ]; then
            notify "🎤 Headset mode enabled (microphone ON, audio quality reduced)" "$YELLOW"
        else
            notify "❌ Failed to switch to headset mode" "$RED"
            exit 1
        fi
        ;;
    "$HEADSET_PROFILE")
        echo "Switching to High-Quality Audio mode..."
        pactl set-card-profile "$CARD_NAME" "$A2DP_PROFILE"
        if [ $? -eq 0 ]; then
            notify "🎵 High-quality audio enabled (microphone OFF)" "$GREEN"
        else
            notify "❌ Failed to switch to A2DP mode" "$RED"
            exit 1
        fi
        ;;
    *)
        notify "⚠️ Unknown profile: $current_profile" "$YELLOW"
        echo "Available profiles:"
        pactl list cards | grep -A 30 "$CARD_NAME" | grep -E "^\s+[a-z].*:" | sed 's/^\s*/  - /'
        ;;
esac

# Show current status
echo ""
echo "Current profile: $(get_current_profile)"
pactl list sources short | grep bluez_input && echo "✓ Microphone available" || echo "✗ Microphone not available"
