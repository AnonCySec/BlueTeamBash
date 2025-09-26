#!/bin/bash

# This script will check for failed login attempts 

RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"

intro=$(echo -e "\t${GREEN}Log Checker")
message="Checking for failed login attempts...\n"

# Check if the script is run with sufficient privileges
if [ $EUID -ne 0 ]; then
	echo -e "${RED}This script must be run as root.\n"
	exit 1
fi

# Check for a given argument
if [ $# -eq 1 ]; then
	echo -e "${RED}This scrpt requires no argument\n"
	echo -e "${RED}Exmaple: sudo ./log_checker.sh\n"
	exit 1
elif [ $# -eq 0 ]; then
	echo -e $intro
	echo -e $message
	sleep 2
fi

# Determine the right log file based on the system
if [[ -f /var/log/auth.log ]]; then
	LOGFILE="/var/log/auth.log"
elif [[ -f /var/log/secure ]]; then
	LOGFILE="/var/log/secure"
else
	echo -e "${RED}No log file found /var/log/auth.log or /var/log/secure"
	exit 1
fi

ALERT_LOG="failed_login_$(date Y%m%d%_H%M%S%).log"

echo -e "[*] Monitoring failed login attempts in $LOGFILE ..."
echo -e "[*] Loggin alerts to $ALERT_LOG"
echo "------------------------------------------------"

# Ensure the alert log file exists


# Monitor the log in real time
tail -F "$LOGFILE" | while read line; do
if echo "$line" | grep -q "Failes password"; then
	TIMESTAMP=$(echo "$line" | awk '{print $1, $2, $3}')
	USER=$(echo "$line" | grep -oP "for \K\S+(?= from)")
	IP=$(echo "$line" | grep -oP "from \K[\d\.]+")

	echo -e "${RED}[!] Failed login detected - $TIMESTAMP | User: $USER | IP: $IP"
	echo -e "$TIMESTAMP - Failed login for user $USER from IP $IP" >> "$ALERT_LOG"
fi
done
