# Claude Code Container

Containerized Claude Code with `--dangerously-skip-permissions`. The container provides isolation while giving Claude full access to your project directory.

## Setup

```bash
# Build the image
make build
```

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

-   Mounts `~/.claude` and `~/.claude.json` for settings and credentials
-   Mounts `~/.config` (read-only) for statusline and other tool configs
-   Mounts your project directory at the same path as on host
-   Mounts Docker socket for container management
-   Runs as your UID/GID for correct file permissions
-   `--dangerously-skip-permissions` allows autonomous operation

## Mounted Paths

| Host Path              | Container Path         | Access |
| ---------------------- | ---------------------- | ------ |
| `~/.claude/`           | `~/.claude/`           | rw     |
| `~/.claude.json`       | `~/.claude.json`       | rw     |
| `~/.config/`           | `~/.config/`           | ro     |
| `<project>`            | `<project>`            | rw     |
| `/var/run/docker.sock` | `/var/run/docker.sock` | rw     |
