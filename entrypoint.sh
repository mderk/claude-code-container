#!/bin/bash
set -e

USER_ID=${HOST_UID:-1000}
GROUP_ID=${HOST_GID:-1000}
USER_HOME=${HOST_HOME:-/home/claude}

# Create user with matching UID/GID and same HOME as host
groupadd -g "$GROUP_ID" -o claude 2>/dev/null || true
useradd -u "$USER_ID" -g "$GROUP_ID" -o -M -d "$USER_HOME" -s /bin/bash claude 2>/dev/null || true
mkdir -p "$USER_HOME"
chown "$USER_ID:$GROUP_ID" "$USER_HOME"

# Give user access to Docker socket if mounted
if [ -S /var/run/docker.sock ]; then
    DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
    groupadd -g "$DOCKER_GID" -o docker 2>/dev/null || true
    usermod -aG docker claude 2>/dev/null || true
fi

# Allow claude user to use sudo
echo "claude ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/claude

# Run Claude from host installation
CLAUDE_BIN="$USER_HOME/.claude/local/node_modules/.bin/claude"

exec sudo -u claude HOME="$USER_HOME" "$CLAUDE_BIN" --dangerously-skip-permissions "$@"
