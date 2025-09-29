#!/bin/bash

# Log size monitor checks the size of important log files

RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"

# Check if the script is run with sufficient privileges
if [ $EUID -ne 0 ]; then
	echo -e "${RED}This script must be run as root.\n"
	exit 1
fi

# Check for a given argument
if [ $# -ge 1 ]; then
	echo -e "${RED}This script requires no argument.\n"
	echo -e "${RED}Example: sudo ./log_size_check.sh"
	exit 1
elif [ $# -eq 0 ]; then
	figlet -f slant "Locg Size Monitor"
	echo -e "${BLUE}Checking for large log files...\n"
	sleep 2
fi

# Define a list of files to monitor and their size threshhold in bytese
declare -a LOG_FILES=(
	"/var/log/syslog:50000000"   # 50 MB for system log
	"/var/log/auth.log:20000000" # 20 MB for authentication log
       	"/var/log/apache2/error.log:10000000"  # 10 MB for Apache error log
	)

# Set the directory for alert files	
ALERT_DIR="$HOME/alerts"

# Check to see if the directory exist, create one if it doesn't
if [[ ! -d "$HOME/alerts" ]]; then
	mkdir -p "$ALERT_DIR"
fi

# Get the current time for the alert file
TIMESTAMP=$(date +"%Y-%m-%d_%h%m%s")
ALERT_FILE="$ALERT_DIR/log_size_aleert_$TIMESTAMP.txt"

# Loop though the list of logs
for entry in "${LOG_FILES[@]}"; do
	IFS=":" read -r LOG_PATH MAX_SIZE <<< "$entry"

	# Check if the log files exist
	if [[ -f "$LOG_PATH" ]]; then
		# Get the current size in bytes
		CURRENT_SIZE=$(stat -c%s "$LOG_PATH")

		# Compare current size to the maximum allowed size
		if [[ "$CURRENT_SIZE" -gt "$MAX_SIZE" ]]; then
			echo -e "${RED}Alert: Log files exceeded threshold!" >> "$ALERT_FILE"
			echo -e "${BLUE}Timestamp: $TIMESTAMP" >> "$ALERT_FILE"
			echo -e "${GREEN}File: $LOG_PATH" >> "$ALERT_FILE"
			echo -e "${RED}Current Size: $CURRENT_SIZE bytes" >> "$ALERT_FILE"
			echo -e "${RED}Size Threshold: $MAX_SIZE bytes" >> "$ALERT_FILE"
			echo -e "${BLUE}---------------------------------" >> "$ALERT_FILE"
		fi
	fi
done

# If an alert was created, prit out summary
if [ -f "$ALERT_FILE" ]; then
	echo -e "Alert file created: $ALERT_FILE"
else
	echo -e "${GREEN}No log files exceeded the size threshold"
	# Clean up after an empty alert if nothing was written
	rm --force "$ALERT_FILE"
fi

