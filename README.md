# Claude Code Container

Containerized Claude Code with `--dangerously-skip-permissions`. The container provides isolation while giving Claude full access to your project directory.

## Setup

```bash
# Build the image
make build
```

## Authentication

Docker containers don't have access to macOS Keychain where Claude stores OAuth tokens. Set up a long-lived token:

```bash
# 1. Generate token (requires Claude subscription)
claude setup-token

# 2. Save token to file (use -n to avoid newline)
echo -n "YOUR_TOKEN" > ~/.claude/.oauth_token
chmod 600 ~/.claude/.oauth_token
```

The token is automatically loaded on each container start.

**Alternative:** Set `CLAUDE_CODE_OAUTH_TOKEN` environment variable.

## Usage

```bash
# Run in a specific directory
./run-claude.sh /path/to/project

# Run in current directory
make run

# Pass arguments
./run-claude.sh . --print "explain this"

# Open bash shell in container
make shell
```

## Alias

Add to `~/.zshrc` or `~/.bashrc`:

```bash
alias claudec="$HOME/claude-code-container/run-claude.sh"
```

Then: `claudec /path/to/project`

## Make Commands

| Command        | Description              |
| -------------- | ------------------------ |
| `make build`   | Build the image          |
| `make rebuild` | Force rebuild (no cache) |
| `make run`     | Run in current directory |
| `make shell`   | Bash shell in container  |
| `make clean`   | Remove the image         |

## Included Tools

git, git-lfs, gh, openssh-client, vim, nano, curl, wget, python3, pip, uv, make, build-essential, pkg-config, tmux, htop, tree, jq, yq, ripgrep, fd, fzf, bat, less, file, procps, lsof, zip/unzip, rsync, docker-cli

## Customization

### MCP Servers

MCP servers using `npx`/`uvx` work out of the box. To pre-install for faster startup, add commands to `mcp-packages.txt`:

```
npm install -g @playwright/mcp
pip install mcp-server-fetch
```

Then rebuild: `make rebuild`

### Other npm packages

Edit the Dockerfile directly and rebuild.

## How It Works

-   Loads OAuth token from `~/.claude/.oauth_token` or `CLAUDE_CODE_OAUTH_TOKEN` env var
-   Mounts `~/.claude` and `~/.claude.json` for settings, history and credentials
-   Mounts `~/.config` (read-only) for statusline and other tool configs
-   Mounts your project directory at the same path as on host
-   Mounts Docker socket for container management
-   Runs as your UID/GID for correct file permissions
-   `--dangerously-skip-permissions` allows autonomous operation

## Mounted Paths

| Host Path              | Container Path         | Access | Description                |
| ---------------------- | ---------------------- | ------ | -------------------------- |
| `~/.claude/`           | `~/.claude/`           | rw     | Settings, history, token   |
| `~/.claude.json`       | `~/.claude.json`       | rw     | User preferences           |
| `~/.config/`           | `~/.config/`           | ro     | Statusline, tool configs   |
| `<project>`            | `<project>`            | rw     | Your working directory     |
| `/var/run/docker.sock` | `/var/run/docker.sock` | rw     | Docker-in-Docker support   |
