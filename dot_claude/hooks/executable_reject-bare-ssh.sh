#!/bin/bash
# reject-bare-ssh.sh
# Blocks SSH commands that run docker compose, systemctl, or similar
# service commands without first cd-ing to a working directory.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check commands that start with ssh
if ! echo "$COMMAND" | grep -qE '^\s*ssh\s'; then
  exit 0
fi

# Check if the SSH command contains a service command without a preceding cd
# Extract the remote command portion (everything inside quotes after the host)
REMOTE_CMD=$(echo "$COMMAND" | grep -oE '"[^"]*"' | tail -1 | tr -d '"')

if [ -z "$REMOTE_CMD" ]; then
  exit 0
fi

# List of commands that require a working directory
SERVICE_PATTERNS="docker compose|docker-compose|systemctl|make |npm |yarn |pnpm |cargo |go build|go run|python |pip "

if echo "$REMOTE_CMD" | grep -qE "$SERVICE_PATTERNS"; then
  # Check if the remote command starts with cd
  if ! echo "$REMOTE_CMD" | grep -qE '^\s*cd\s'; then
    echo "BLOCKED: SSH command runs a service command without 'cd <directory> &&' first. Remote shells start in ~, which is never correct. Use: ssh <host> \"cd /path/to/project && <command>\"" >&2
    exit 2
  fi
fi

exit 0
