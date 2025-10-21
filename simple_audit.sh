#!/bin/bash

# This script performs basic checks for common security misconfiguration

LOG_FILE="$HOME/security_audit_$(date +"%Y-%m-%d_%H%M%S").log"
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
NC="\e[0m"

# Utility function
log_and_echo() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_and_echo "{RED}[FAIL]${NC} This script must be run as root. Exiting!\n"
    exit 1
  fi
}

# Security Checks
check_suid_sgid() {
  log_and_echo "\n============================================"
  log_and_echo "        Checking fo SIUD/SGID files"
  log_and_echo "============================================="

  # Find SUID/SGID files, excluding common and expected ones
  find / -type f \( -perm -4000 -o -perm -2000\) 2>/dev/null | while read -r file; do
      if ! grep -q -E "(passwd|mount|umount|su|sudo|gpasswd)" <<< "$file"; then
      log_and_echo "${BLUE}[WARN]${NC} Found potentially insecure SUID/SGID file: $file"
      fi
  done
  log_and_echo "${GREEN}[INFO]${NC} SUID/SGID file check complete."
}

check_insecure_permissions() {
  log_and_echo "\n============================================"
  log_and_echo "  Checking for world-writable directories"
  log_and_echo "============================================="

  # Find world-writable files and directories in sensitive locations
  find / \( -path "/proc" -o -path "/sys" \) -prune -o -perm -o=w -la 2>/dev/null | while read -r item; do
      log_and_echo "${RED}[WARN]${NC} Found world-writable item: $item"
  done
  log_and_echo "${GREEN}[INFO]${NC} Premission check complete."
}

check_ssh_config() {
  log_and_echo "\n========================================="
  log_and_echo "    Checking SSH Configuration"
  log_and_echo "=========================================="
  SSHD_CONFIG="/etc/ssh/sshd_config"
  if [ ! -f "$SSHD_CONFIG" ]; then
    log_and_echo "${RED}[warn]${NC} $SSHD_CONFIG not found."
    return
  fi

  # Check for insecure SSH settings
  grep -E '^(PermitRootLogin|PasswordAuthentication)' "$SSHD_CONFIG" | grep -v 'prohibit-password' | while read -r settings; do
      if echo "$setting" | grep -q 'yes'; then
        log_and_echo "${RED}[FAIL]${NC} Insecure SSH settings found: $setting. Should be set to 'no'."
      else
        log_and_echo "${GREEN}[PASS]${NC} Secure SSH settings found: $setting."
      fi
  done
  log_and_echo "${GREEN}[INFO]${NC} SSH configuration check complete."
}

check_package_updates() {
  log_and_echo "\n==============================================="
  log_and_echo "      Checking for system updates"
  log_and_echo "==============================================="
  if command -v apt-get &>/dev/null; then
    log_and_echo "${GREEN}[INFO]${NC} Running apt-get and checking for upgradable packages..."
    if apt-get update -qq >/dev/null && apt-get --just-print upgrade | grep -q 'Inst'; then
      log_and_echo "${RED}[FAIL]${NC} System updates available. Please run 'apt-get upgrade'."
    else
      log_and_echo "${GREEN}[PASS]${NC} No system updates found."
    fi
  elif command -v dnf &>/dev/null; then
    log_and_echo "${GREEN}[INFO]${NC} Checking for dnf updates..."
    if dnf check-update &>/dev/null; then
      log_and_echo "${RED}[FAIL]${NC} System updates availabel. Please run 'dnf update'."
    else
      log_and_echo "${GREEN}[PASS]${NC} No system updates found."
    fi
  else
    log_and_echo "${RED}[WARN]${NC} Package manager nor recognized. Cannot check for updates."
  fi
}

main() {
  check_root
  log_and_echo "Starting security audit on $(hostname) at $(date)"
  log_and_echo "Results are being logged to $LOG_FILE"

  check_suid_sgid
  check_insecure_permissions
  check_ssh_config
  check_package_updates

  log_and_echo "\n==================================================================="
  log_and_echo "           Security audit finished"
  log_and_echo "==================================================================="
}

main "$@"
