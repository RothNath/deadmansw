#!/bin/bash

# Configuration path
CONFIG_PATH="/etc/deadmansw/deadmansw.conf"

# Extract configurations
...
ENABLED=$(grep "ENABLED" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
...

# Check if the service is enabled
if [ "$ENABLED" != "no" ]; then
    echo "Deadman's Switch is currently disabled. Exiting."
    exit 0
fi

# Extract configurations
MONITORED_USER=$(grep "MONITORED_USER" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_MINUTES=$(grep "TIME_MINUTES" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_HOURS=$(grep "TIME_HOURS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_DAYS=$(grep "TIME_DAYS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_WEEKS=$(grep "TIME_WEEKS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_MONTHS=$(grep "TIME_MONTHS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')

# Convert all times to seconds for comparison
INACTIVITY_SECONDS=$(( 
    "$TIME_MINUTES" * 60 +
    "$TIME_HOURS" * 3600 +
    "$TIME_DAYS" * 86400 +
    "$TIME_WEEKS" * 604800 +
    "$TIME_MONTHS" * 2592000 
))

# Extract targets
mapfile -t targets < <(grep "TARGET_" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')

# Get the last modification time of the user's home directory
last_modification=$(ls -ld --time-style=+'%Y-%m-%d %H:%M:%S' /home/$MONITORED_USER | awk '{print $6,$7}')
last_login_timestamp=$(date --date="$last_modification" +%s)
current_timestamp=$(date +%s)

# Calculate difference
time_difference=$((current_timestamp - last_login_timestamp))
echo "Inactivity threshold in seconds: $INACTIVITY_SECONDS"
echo "Time difference since last login in seconds: $time_difference"

if [ "$time_difference" -ge "$INACTIVITY_SECONDS" ]; then
    # Shredding logic
    for target in "${targets[@]}"; do
        echo "Checking target: $target"
        if [ -e "$target" ]; then
            # Check if target is a directory
            if [ -d "$target" ]; then
                find "$target" -type f -exec shred {} \; && rm -rf "$target"
                if [ $? -eq 0 ]; then
                    echo "Shredded directory: $target"
                else
                    echo "Failed to shred directory: $target"
                fi
            else
                shred "$target" && rm -f "$target"
                if [ $? -eq 0 ]; then
                    echo "Shredded: $target"
                else
                    echo "Failed to shred: $target"
                fi
            fi
        else
            echo "Target not found: $target"
        fi
    done
    echo "Shredding complete."
else
    hours=$((time_difference / 3600))
    mins=$(((time_difference % 3600) / 60))
    secs=$((time_difference % 60))
    echo "Time elapsed since last login: $hours hours, $mins minutes, $secs seconds."
    time_remaining=$((INACTIVITY_SECONDS - time_difference))
    remaining_hours=$((time_remaining / 3600))
    remaining_mins=$(((time_remaining % 3600) / 60))
    remaining_secs=$((time_remaining % 60))
    echo "Time remaining until shredding: $remaining_hours hours, $remaining_mins minutes, $remaining_secs seconds."
fi
