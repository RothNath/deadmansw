#!/bin/bash

# Configuration path
CONFIG_PATH="/etc/dmsw/dmsw.conf"

# Extract configurations
ENABLED=$(grep "ENABLED" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
MONITORED_USER=$(grep "MONITORED_USER" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_MINUTES=$(grep "TIME_MINUTES" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_HOURS=$(grep "TIME_HOURS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_DAYS=$(grep "TIME_DAYS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_WEEKS=$(grep "TIME_WEEKS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
TIME_MONTHS=$(grep "TIME_MONTHS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
NOTIFICATION_CMD=$(grep "NOTIFICATION_CMD" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')
SHRED_OPTS=$(grep "SHRED_OPTS" $CONFIG_PATH | cut -d'=' -f2 | tr -d '"')  

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

# Check if service is enabled then start the Shredding Logic
if [ "$ENABLED" = "yes" ]; then
    if [ "$time_difference" -ge "$INACTIVITY_SECONDS" ]; then
        # Logging for shredding start
        echo "$(date) - INFO: Inactivity threshold met, starting file shredding." >> /var/log/dmsw.log

        # Shredding Logic
        for target in "${targets[@]}"; do
            echo "$(date) - INFO: Checking target: $target" >> /var/log/dmsw.log
            if [ -e "$target" ]; then
                # Check if target is a directory
                if [ -d "$target" ]; then
                    find "$target" -type f -exec shred $SHRED_OPTS {} \; && rm -rf "$target" # Use SHRED_OPTS for directories
                    if [ $? -eq 0 ]; then
                        echo "$(date) - INFO: Successfully shredded directory: $target" >> /var/log/dmsw.log
                    else
                        echo "$(date) - WARN: Failed to shred directory: $target" >> /var/log/dmsw.log
                    fi
                else
                    shred $SHRED_OPTS "$target" && rm -f "$target" # Use SHRED_OPTS for files
                    if [ $? -eq 0 ]; then
                        echo "$(date) - INFO: Successfully shredded file: $target" >> /var/log/dmsw.log
                    else
                        echo "$(date) - WARN: Failed to shred file: $target" >> /var/log/dmsw.log
                    fi
                fi
            else
                echo "$(date) - WARN: Target not found: $target" >> /var/log/dmsw.log
            fi
        done
        echo "$(date) - INFO: Shredding complete." >> /var/log/dmsw.log
    else
        # Log inactivity check every 24 hours
        if [[ $((time_difference / 86400)) -ge 1 ]]; then
            echo "$(date) - User $MONITORED_USER has been inactive for $((time_difference / 86400)) days." >> /var/log/dmsw.log
        fi

        # Output time remaining for helper script
        hours=$((time_difference / 3600))
        mins=$(((time_difference % 3600) / 60))
        secs=$((time_difference % 60))
        echo "Time remaining until shredding: $hours hours, $mins minutes, $secs seconds."
    fi
fi  
while true; do
    # Perform inactivity check and shredding logic
    # ... (existing code within the if blocks)

    sleep 300  # Sleep for 5 minutes (300 seconds)
done
