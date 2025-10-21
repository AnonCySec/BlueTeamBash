# BlueTeamBash
I this repo I wrote a few basic Bash scripts for beginners who are interested in learning Bash scripting for defensive security. This should help you develop your Blue Team bash skills along with thinking outside the box.

# System and Security Monitoring

Log Checker
Usage: sudo ./log_checker.sh
This script will check the /var/log directory for log files indicating a potential unwanted login to your system.

Log Size Monitor
Usage: sudo ./log_size_monitor.sh
This script will monitor the size of the logfiles, if a log file exceeds the maximum allowed size it will generate an alert indicating a potential attack or incident.

Disk Space Monitor
Usage: sudo ./disk_size_monitor.sh
This script monitors disk space. If the disk space exceeds the threashold then you should get a screen alert alog with a log file with the alert, indicating a potential attack. You can run this tool in the background or as a cronj job.

Network Connection Monito
Usage: ./network_connection_monitor.sh
This script monitors suspicious network conection by comparing active connections against a list of known, trusted hosts.

Simple Audit
Usage: sudo ./simple_audit.sh
This script checks a Linux systyem for potential missconfigurations, and creates a log file to the user's home directory.

# Credential Harvesting and System Info

System Information
Usage: ./system_info.sh
This script helps you gather system info for privilege escalation and more. The point is for you to enhance your bash scripting techniques as you add or customize more commands to the script.

Ping Sweeper
Usage: ./ping_sweep.sh
Do a full ping sweep of your current subnet to find live hosts so you can pivot during a penetration test.

File Searcher
Usage: ./file_searcher.sh
This script searches for interesting files in a Linux system. Feel free to customize the script to enhance your bash scripting skills.

Database Files
Usage: ./database_files.sh
This script searches a Linux system for database files, potentially finding credentials or other relevant info.
