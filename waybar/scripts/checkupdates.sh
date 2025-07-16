#!/bin/bash

# Use sudo. The sudoers file allows this specific command to run without a password.
updates=$(sudo /usr/bin/dnf upgrade --assumeno -yq | grep -E 'x86_64$|i686$|noarch$|aarch64$')

# Count how many actual package lines were found.
update_count=$(echo "$updates" | grep -c '..*')

alt="has-updates"
tooltip="No pending updates." # Default tooltip when count is 0

if [ "$update_count" -eq 0 ]; then
    alt="updated"
else
    # Format the list of packages for the tooltip.
    # We only need the package name (first column) and version (second column).
    formatted_updates=$(echo "$updates" | awk '{print $1, $2}')
    tooltip=$(echo "$formatted_updates" | sed ':a;N;$!ba;s/\n/\\n/g')
fi

# Output the JSON for Waybar
echo "{ \"text\": \"$update_count\", \"tooltip\": \"$tooltip\", \"alt\": \"$alt\" }"