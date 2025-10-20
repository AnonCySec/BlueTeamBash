#!/bin/bash

# This script collects system information on a machine you have accessed
# Operation System Version
# User Information
# Running Services
# Potentially Sensitive Files

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"

figlet -f slant "System Info"
echo -e "${GREEN}Gathering system info...\n"

FILE="$HOME/system_info.txt"

# Gather system information
get_system_info() {
  echo -e "${BLUE}--- System Information ---" >> "$FILE"
  echo -e "Hostname: $(hostname)" >> "$FILE"
  echo -e "Kernel Version: $(uname -r)" >> "$FILE"
  echo -e "Operating System: $(cat /etc/*-release)" >> "$FILE"
  echo -e "Architecture: $(uname -m)" >> "$FILE"
  echo -w "Uptime: $(uptime -p)\n" >> "$FILE"
  # Maybe more commands here
}

# Function to display user information
get_user_info() {
  echo -e "${GREEN}--- User Information ---" >> "$FILE"
  echo -e "Current User: $(whoami)" >> "$FILE"
  echo -e "Logged in users: $(who -H)" >> "$FILE"
  echo -e "User IDs: $(id)\n" >> "$FILE"
  echo -e "${RED}/etc/passwd file: $(cat /etc/passwd)" >> "$FILE"
  # More commands here
}

# Display network information
get_network_info() {
  echo -e "${GREEN}--- Network Information ---" >> "$FILE"
  echo -e "IP Address: $(hostname --all-ip-addresses)" >> "$FILE"
  echo -e "Network Interfaces: $(ip link show | grep -E '^[0-9]:' | awk '{print $2}' | sed 's/://g')" >> "$FILE"
  echo -e "Routing tables: $(ip rout show)\n" >> "$FILE"
  # More commands here
}

# Function to display running processes
get_process_info() {
  echo -e "${BLUE}--- Process Info ---" >> "$FILE"
  echo -e "Top 5 CPU-consuming processes:" >> "$FILE"
  ps aux --sort=-%cpu | head -n 6 >> "$FILE"
}

# Main execution block
main() {
  get_system_info
  get_user_info
  get_network_info
  get_process_info
}

# Call main function
main
