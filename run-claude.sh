#!/bin/bash
set -e

IMAGE_NAME="claude-code-runner"

if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo "Error: Image '$IMAGE_NAME' not found. Run 'make build' first."
    exit 1
fi

WORK_DIR="${1:-.}"
WORK_DIR="$(cd "$WORK_DIR" && pwd)"
shift 2>/dev/null || true

# Load token from file if not set in environment
TOKEN_FILE="$HOME/.claude/.oauth_token"
if [[ -z "$CLAUDE_CODE_OAUTH_TOKEN" && -f "$TOKEN_FILE" ]]; then
    CLAUDE_CODE_OAUTH_TOKEN="$(tr -d '\n\r' < "$TOKEN_FILE")"
fi

echo "Running Claude Code in: $WORK_DIR"

docker run -it --rm \
    --stop-timeout 30 \
    -v "$WORK_DIR:$WORK_DIR" \
    -w "$WORK_DIR" \
    -v "$HOME/.claude:$HOME/.claude" \
    -v "$HOME/.claude.json:$HOME/.claude.json" \
    -v "$HOME/.config:$HOME/.config:ro" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    -e HOST_HOME="$HOME" \
    -e DOCKER_HOST="unix:///var/run/docker.sock" \
    ${CLAUDE_CODE_OAUTH_TOKEN:+-e CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN"} \
    "$IMAGE_NAME" "$@"
