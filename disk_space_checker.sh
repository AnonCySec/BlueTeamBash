#!/bin/bash

# This script helps you monitor disk space for 

RED="\e[31m"
BLUE="\e[32m"
GREEN="\e[34m"

# Check to see if the user has sufficient permissions
if [ $EUID -ne 0 ]; then
	echo -e "${RED}This script must be run as root.\n"
	exit 1
fi

arg_check() {
	if [ $# -gt 0 ]; then
		echo -e "${RED}This script requires no argument.\n"
		echo -e "${GREEN}Example: sudo ./disk_space_checker.sh\n"
		exit 1
	elif [ $# -eq 0 ]; then
	figlet -f big "Disk Space Monitor"
	echo -e "Monitoring disk space usage...\n"
	sleep 2 
	fi
}

arg_check

THRESHOLD=80
CHECK_INTERVAL=60
LOG_FILE="$HOME/disk_usage_alert.log"
MOUNT_POINT="/"

# Function to check the disk usage for a specific mount point
check_disk_usage() {
	USAGE=$(df -h "$MOUNT_POINT" | awk 'NR == 2 {print $5}' | sed 's/%//')

	# Check if usage exceeds the threshold
	if [ "$USAGE" -ge "$THRESHOLD" ]; then
		ALERT_MESSAGE="Warning: Disk usage on ${MOUNT_POINT}% is at ${USAGE} on (Threshold: ${THRESHOLD}%) on $(hostname)!"
		echo "${RED}$ALERT_MESSAGE"
		echo "$(date '+%Y-%m-%d %H:%M:%S'): $ALERT_MESSAGE" >> "$LOG_FILE"

		# Display alert on the screen
		if command -v notify-send >/dev/null 2>&1; then
			notify-send -u critical "${RED}Disk space alert" "$ALERT_MESSAGE"
		else
			echo "$ALERT_MESSAGE" >&2
		fi
	fi
}

# Main loop to continuously monitor
while true; do
	check_disk_usage
	sleep "$CHECK_INTERVAL"
done
