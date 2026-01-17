FROM ubuntu:noble

SHELL ["/bin/bash", "-c"]

# ================================
# apt
# ================================
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt update && \
    apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo \
    build-essential \
    make \
    locales \
    unzip \
    git \
    libncurses6 \
    libncurses-dev \
    binutils \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-13-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-13-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
    openssl \
    libssl-dev \
    inotify-tools \
    jq \
    uidmap \
    kmod \
    iptables \
    docker.io \
    docker-compose-v2 \
    socat \
    screen \
    docker-buildx \
    openssh-client

# ================================
# User
# ================================
RUN echo 'lemo ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/lemo
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /lemo lemo
USER lemo:lemo
WORKDIR /lemo

# ================================
# Setup Swift
# ================================
WORKDIR /swiftly
RUN NONINTERACTIVE=1 curl -O "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz" && \
    tar zxf "swiftly-$(uname -m).tar.gz" && \
    ./swiftly init --quiet-shell-followup && \
    . ${SWIFTLY_HOME_DIR:-~/.local/share/swiftly}/env.sh && \
    hash -r && \
    echo "source ${SWIFTLY_HOME_DIR:-~/.local/share/swiftly}/env.sh" >> /lemo/.bashrc && \
    rm -f "swiftly-$(uname -m).tar.gz"

# ================================
# Homebrew
# ================================
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo >> /lemo/.bashrc
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /lemo/.bashrc
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
RUN brew install \
    codex \
    deno \
    git \
    gemini-cli \
    neovim \
    swift-format \
    swift-protobuf \
    tree \
    && brew cleanup -s && rm -rf $(brew --cache)

# ================================
# PATH
# ================================
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# ================================
# Alias
# ================================
RUN echo 'alias codex-force="codex --yolo"' >> ~/.bashrc
RUN echo 'alias vi="nvim"' >> ~/.bashrc

WORKDIR /lemo/workspace

# ================================
# Permission
# ================================
RUN sudo chown -R lemo:lemo /swiftly
RUN sudo chown -R lemo:lemo /lemo/workspace