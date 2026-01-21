# Dev container with Debian, Homebrew, mise, and developer tools
FROM debian:bookworm-slim

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    sudo \
    locales \
    procps \
    file \
    # For Homebrew
    ruby \
    # For xcompose and clipboard
    xclip \
    xsel \
    # For Playwright browsers
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    libatspi2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

# Install Homebrew
ENV HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew \
    HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar \
    HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
ENV PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}"

# Install mise (runtime version manager)
RUN brew install mise \
    && echo 'eval "$(mise activate bash)"' >> ~/.bashrc

# Install core CLI tools via Homebrew
RUN brew install \
    ripgrep \
    fzf \
    fd \
    yazi \
    tmux \
    stow \
    neovim \
    zoxide \
    eza \
    jq \
    lsof \
    starship \
    node@20

# Add node to PATH and install Claude Code
ENV PATH="${HOMEBREW_PREFIX}/opt/node@20/bin:${PATH}"
RUN npm install -g @anthropic-ai/claude-code

# Install zsh and oh-my-zsh
RUN brew install zsh \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc \
    && echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Install zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install TPM (Tmux Plugin Manager)
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Set zsh as default shell for user
RUN sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh dev
ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh

# Set up XCompose directory
RUN mkdir -p ~/.config

# Create workspace directory
RUN sudo mkdir -p /workspaces && sudo chown dev:dev /workspaces
WORKDIR /workspaces

# Default to zsh
CMD ["/home/linuxbrew/.linuxbrew/bin/zsh"]
