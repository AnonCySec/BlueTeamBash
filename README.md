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

Network COnnection Monitor
Usage: ./network_connection_monitor.sh
This script monitors suspicious network conection by comparing active connections against a list of known, trusted hosts.
