#!/bin/bash

# This script searches for interesting files in a Linux system

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"

figlet -f small "File Searcher"
echo -e "${GREEN}Searching for interesting files...\n"
sleep 2

# Loop to search for the files
for file in $(echo ".conf .config .cnf"); do
  echo -e "\nFile extension: " $file; find / -name *$file 2>/dev/null | grep -v "lib\|fonts\|share\|core"
done
