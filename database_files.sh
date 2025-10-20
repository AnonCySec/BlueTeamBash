#!/bin/bash

# This script will search a Linux system for database files

BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"

figlet -f small "Database File Searcher"
echo -e "${GREE}Searching for database files...\n"
sleep 2

FILES_FOUND="$HOME/db_files.txt"

# Loop to search for files
for file in $(echo ".sql .db .*db .db*"); do
  SEARCH=$(echo -e "\nDB File extension: " $file; find / -name *$file 2>/dev/null | grep -v "doc\|lib\|headers\|share\|man")
  if [[ -n "$SEARCH" ]]; then
    echo "$SEARCH" > "$FILES_FOUND"
    echo -e "${GREEN}\nDatabase files found, saved to a file called db_files.txt in your home directory.\n"
    exit 0
  else
    echo -e "${RED}No database files found in this system."
    exit 1
  fi
done
