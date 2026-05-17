FROM ubuntu:24.04
LABEL maintainer="Roël Couwenberg <contact@roelc.me>"
LABEL org.opencontainers.image.title="Dockerised VSCode"
LABEL org.opencontainers.image.description="A Docker image for running Visual Studio Code with various dependencies."
LABEL org.opencontainers.image.url="https://roelc.me/en/resources/2024/05/26/dockerised-vscode"
LABEL org.opencontainers.image.source="https://github.com/pixnyb/dockerised-vscode"

# Delete the default 'ubuntu' user
RUN userdel -r ubuntu || true

ARG USERNAME=vscode
ARG DOCKER=true
ARG CODE_INSIDERS

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the necessary dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  # Core utilities
  apt-utils software-properties-common sudo jq gpg gnupg gnome-keyring wget curl ca-certificates locales \
  msmtp-mta bash-completion \
  # Dependencies
  libdrm2 libgbm1 libnspr4 libnss3 libxkbfile1 xdg-utils libvulkan1 \
  # Networking tools
  netcat-openbsd net-tools iputils-ping dnsutils \
  # Development tools
  git ssh build-essential python3-minimal unzip zip gh glab \
  # Text editors and utilities
  vim nano tree tmux silversearcher-ag ripgrep less mandoc \
  # System monitoring
  htop iotop iftop \
  # Security and debugging
  strace nmap tcpdump \
  # GUI and miscellaneous
  openbox rxvt-unicode qutebrowser \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8

ENV MAILER_DSN="sendmail://default?command=/usr/sbin/sendmail%20-t"
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Add the GitHub CLI GPG key and WakeMeOps repository
RUN mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && curl -sSL "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | sudo bash

# Set up ssh by disabling root login and enabling key-based authentication
RUN cat > /etc/ssh/sshd_config.d/hardened.conf <<EOF
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
X11UseLocalhost yes
PrintMotd no
PrintLastLog no
TCPKeepAlive yes
PermitUserEnvironment yes
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

# Install Docker using https://get.docker.com
RUN if [ "$DOCKER" = "true" ]; then \
  curl -fsSL https://get.docker.com -o get-docker.sh && \
  sh get-docker.sh && \
  rm get-docker.sh; \
  fi

# Add the user to the sudoers file without password
RUN useradd -m -s /bin/bash ${USERNAME} && \
  echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
  chmod 0440 /etc/sudoers.d/${USERNAME} && \
  usermod -aG docker ${USERNAME}

# Install Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
  install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
  rm -f packages.microsoft.gpg && \
  apt-get install apt-transport-https -y && \
  apt-get update && \
  apt-get install code${CODE_INSIDERS:+-insiders} -y && \
  apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# If CODE_INSIDERS is set, link the code-insiders binary to code
RUN if [ -n "${CODE_INSIDERS}" ]; then ln -s /usr/bin/code-insiders /usr/bin/code; echo "Installed Visual Studio Code Insiders"; fi

# Setup turbovnc
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | \
  gpg --dearmor >/etc/apt/trusted.gpg.d/TurboVNC.gpg \
  && wget -q -O /etc/apt/sources.list.d/turbovnc.list \
  https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list \
  && apt-get update && apt-get install -y --no-install-recommends \
  turbovnc \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Include binaries
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Create Visual Studio Code directories and link them
RUN mkdir -p /home/${USERNAME}/.vscode${CODE_INSIDERS:+-insiders} /home/${USERNAME}/.vscode-server${CODE_INSIDERS:+-insiders} \
  && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.vscode${CODE_INSIDERS:+-insiders} /home/${USERNAME}/.vscode-server${CODE_INSIDERS:+-insiders}

# Setup a /etc/home directory for the user
RUN mkdir -p /etc/home

# Setup a /home/${USERNAME}/.local/bin directory for the user
RUN mkdir -p /home/${USERNAME}/.local/bin \
  && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

USER ${USERNAME}
ENV USER=${USERNAME}

# Add the /home/${USERNAME}/.local/bin directory to the PATH
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

COPY .gitignore .gitmessage .gitconfig /home/${USERNAME}

WORKDIR /home/${USERNAME}

ENTRYPOINT [ "/usr/local/bin/start-vscode.sh" ]

HEALTHCHECK --interval=15s --timeout=5s --start-period=15m --retries=30 \
  CMD [ "/usr/local/bin/healthcheck-vscode.sh" ]

EXPOSE 8000 22 5900