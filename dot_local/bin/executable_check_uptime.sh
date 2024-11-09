#!/bin/bash

# Get the current uptime in days
UPTIME_DAYS=$(awk '{print int($1 / 86400)}' /proc/uptime)

# Set the threshold for uptime warning
UPTIME_THRESHOLD=60

# Check if the uptime is greater than the threshold
if [ "$UPTIME_DAYS" -gt "$UPTIME_THRESHOLD" ]; then
    # Set the color to red for the warning message
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    # Display the warning message
    echo -e "${RED}Warning: System uptime is ${UPTIME_DAYS} days, which is above ${UPTIME_THRESHOLD} days threshold.${NC}"
fi

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    # Display a reboot warning
    echo -e "${RED}Warning: A system reboot is required for patching.${NC}"
fi

echo ""

