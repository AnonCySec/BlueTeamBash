#!/bin/bash

# This script monitors for unusual or unauthorized network connections

# Path to the list of hosts
WHITELIST_FILE="$HOME/.trusted_hosts"

# Path to the generated alert file
ALERT_DIR="$HOME/network_alerts"
LOG_FILE="$ALERT_DIR/network_monitor.log"

# Function to check if an IP or domain is the whitelist
is_whitelisted() {
	local host="$1"
	grep -qE "^$hosts$" "$WHITELIST_FILE"
}

# Function to resolve a hostname to an IP address
resolve() {
	local host="$1"
	dig +short "$host" | head -n 1
}

# Function to perfomr a reverse DNS lookup
reverse_looup() {
	local ip="$1"
	dig +short -x "$ip" | sed 's/\.$//'
}

# Ensure the alert directory and log file exist
mkdir -p "$ALERT_DIR"
touch "$LOG_FILE"

# The main monitoring loop
while true; do
	# Get a list of all active TCP connections with 'ss'
	ss -tn state established | awk 'NR>1 {print $5}' | while read connection; do
	REMOTE_HOST=$(echo "$connection" | cut -d ':' -f 1)
	REMOTE_HOST=$(echo "$connection" | cut -d ':' -f 2)
	
	# Skip local connection
	if [[ "$REMOTE_HOST" == "127.0.0.1" || "$REMOTE_HOST" == "[::1]" ]]; then
		continue
	fi

	# Skip connections to private IP ranges
	if [[ "$REMOTE_HOST" =~ ^(10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.|192\.168\.) ]]; then
		continue
	fi

	# Check if the IP is in the whitelist
	if ! is_whitelisted "$REMOTE_HOST"; then
		# Attempt a reverse DNS lookup to get the hostname
		REVERSE_HOST=$(reverse_lookup "$REMOTE_HOST")

		# Check if the resolved hostname is in the whitelist
		if [[ -n "$REMOTE_HOST" ]] && is_whitelisted "$REVERSE_HOST"; then
			continue
		fi

		# Generate the alert
		TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
		ALERT_MESSAGE="[ALERT] Detected unusual connection: $REMOTE_HOST:$REMOTE_PORT"
		ALERT_FILE="$ALERT_DIR/alert_$TIMESTAMP.log"

		# Log the alert and create the file
		echo "$TIMESTAMP: $ALERT_MESSAGE" >> "$LOG_FILE"
		echo "--- Network Connection Alert ---" > "$ALERT_FILE"
		echo "Timestamp: $TIMESTAMP" >> "$ALERT_FILE"
		echo "Source: $(hostname)" >> "$ALERT_FILE"
		echo "Connection: $REMOTE_HOST:$REMOTE_PORT" >> "$ALERT_FILE"
		echo "---" >> "$ALERT_FILE"
		echo "Full connection details (from ss):" >> "$ALERT_FILE"
		ss -tnp | grep "$REMOTE_HOST:$REMOTE_PORT" >> "$ALERT_FILE"
		echo "---" >> "$ALERT_FILE"

		# Optional: Add process information
		PROCESS_PID=$(ss -tnp | grep "$REMOTE_HOST:$REMOTE_PORT" | awk -F 'pid=' '{print $2}' | cut -d ',' -f 1)
		if [[ -n "PROCESS_PID" ]]; then
			echo "Associated Process:" >> "$ALERT_FILE"
			ps -fp "PROCESS_PID" >> "$ALERT_FILE"
			echo "---" >> "$ALERT_FILE"
		fi

		echo "Alert file created: $ALERT_FILE"
	fi
done

# Wait before checking again
sleep 30 

done
