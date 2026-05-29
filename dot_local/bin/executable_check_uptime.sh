#!/bin/bash

# Set the threshold for uptime warning
UPTIME_THRESHOLD=60

# Detect OS and get uptime in days
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Get uptime in days on Linux
    UPTIME_DAYS=$(awk '{print int($1 / 86400)}' /proc/uptime)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Get uptime in days on macOS
    UPTIME_SECONDS=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
    CURRENT_TIME=$(date +%s)
    UPTIME_DAYS=$(( (CURRENT_TIME - UPTIME_SECONDS) / 86400 ))
else
    echo "Unsupported OS"
    exit 1
fi

# Check if the uptime is greater than the threshold
if [ "$UPTIME_DAYS" -gt "$UPTIME_THRESHOLD" ]; then
    # Set the color to red for the warning message
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    # Display the warning message
    echo -e "${RED}Warning: System uptime is ${UPTIME_DAYS} days, which is above ${UPTIME_THRESHOLD} days threshold.${NC}"
fi

# Check if a reboot is required (Linux-only)
if [[ "$OSTYPE" == "linux-gnu"* && -f /var/run/reboot-required ]]; then
    # Display a reboot warning
    echo -e "${RED}Warning: A system reboot is required for patching.${NC}"
fi

echo ""

