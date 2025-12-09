FROM node:22-bookworm-slim

# Install development environment
RUN apt-get update && apt-get install -y \
    # Version control
    git \
    git-lfs \
    openssh-client \
    # Editors
    vim \
    nano \
    # Network tools
    curl \
    wget \
    # Build essentials
    build-essential \
    make \
    pkg-config \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    # Shell utilities
    tmux \
    htop \
    tree \
    jq \
    yq \
    ripgrep \
    fd-find \
    fzf \
    bat \
    zip \
    unzip \
    rsync \
    less \
    file \
    procps \
    lsof \
    sudo \
    # For Docker CLI install
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI from official Docker repo
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Create symlinks for tools with different names on Debian
RUN ln -sf /usr/bin/batcat /usr/local/bin/bat && \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Install uv (fast Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    mv /root/.local/bin/uvx /usr/local/bin/uvx

# Pre-install statusline plugin
RUN npm install -g ccstatusline@latest

# Install MCP servers from config file
COPY mcp-packages.txt /tmp/mcp-packages.txt
RUN grep -v '^#' /tmp/mcp-packages.txt | grep -v '^$' | while read -r cmd; do \
        eval "$cmd"; \
    done && rm /tmp/mcp-packages.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
