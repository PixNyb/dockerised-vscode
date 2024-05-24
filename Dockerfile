# Although generally not recommended, ubuntu's latest tag refers to the latest LTS release.
FROM ubuntu:latest
LABEL maintainer="Roël Couwenberg <contact@roelc.me>"

ARG USERNAME=vscode
ARG CODE_INSIDERS=

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-utils software-properties-common sudo jq \
  libdrm2 libgbm1 libnspr4 libnss3 libxkbfile1 xdg-utils libvulkan1 \
  gnupg gnome-keyring wget curl python3-minimal ca-certificates \
  git ssh build-essential \
  unzip zip vim \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Add the GitHub CLI GPG key
RUN mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install other dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  gh \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Set up ssh by disabling root login and enabling key-based authentication
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
  && sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config \
  && sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config \
  && sed -i 's/#UsePAM yes/UsePAM yes/' /etc/ssh/sshd_config \
  && sed -i 's/#X11Forwarding yes/X11Forwarding yes/' /etc/ssh/sshd_config \
  && sed -i 's/#X11UseLocalhost yes/X11UseLocalhost yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PrintMotd yes/PrintMotd no/' /etc/ssh/sshd_config \
  && sed -i 's/#PrintLastLog yes/PrintLastLog no/' /etc/ssh/sshd_config \
  && sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment yes/' /etc/ssh/sshd_config \
  && sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/' /etc/ssh/sshd_config \
  && sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/' /etc/ssh/sshd_config

# Install Docker using https://get.docker.com
RUN wget -qO- https://get.docker.com | sh

# Add the user to the sudoers file without password
RUN useradd -m -s /bin/bash ${USERNAME} && \
  echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
  chmod 0440 /etc/sudoers.d/${USERNAME} && \
  usermod -aG docker ${USERNAME}

# Install Visual Studio Code
RUN sudo apt-get install wget gpg -y && \
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
  rm -f packages.microsoft.gpg && \
  sudo apt install apt-transport-https -y && \
  sudo apt update && \
  sudo apt install code${CODE_INSIDERS:+-insiders} -y && \
  sudo apt autoremove -y && sudo apt clean -y && sudo rm -rf /var/lib/apt/lists/*

# Include binaries
COPY binaries/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Create Visual Studio Code directories and link them
RUN mkdir -p /home/${USERNAME}/.vscode-server \
  && ln -s /home/${USERNAME}/.vscode-server /home/${USERNAME}/.vscode \
  && mkdir -p /home/${USERNAME}/.vscode-server-insiders \
  && ln -s /home/${USERNAME}/.vscode-server-insiders /home/${USERNAME}/.vscode-insiders \
  && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.vscode-server /home/${USERNAME}/.vscode-server-insiders

# Setup a /etc/home directory for the user
RUN sudo mkdir -p /etc/home \
  && sudo chown -R ${USERNAME}:${USERNAME} /etc/home

# Setup a /home/${USERNAME}/.local/bin directory for the user
RUN sudo -u ${USERNAME} mkdir -p /home/${USERNAME}/.local/bin \
  && sudo -u ${USERNAME} chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local/bin

USER ${USERNAME}

# Add the /home/${USERNAME}/.local/bin directory to the PATH
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

COPY git/.gitignore /home/${USERNAME}/.gitignore
COPY git/.gitmessage /home/${USERNAME}/.gitmessage

# Setup Git configuration
COPY git/* /home/${USERNAME}/
RUN git config --global commit.template ~/.gitmessage \
  && git config --global init.defaultBranch main \
  && git config --global pull.rebase true \
  && git config --global push.autoSetupRemote true \
  && git config --global rebase.autoStash true \
  && git config --global core.editor "vim" \
  && git config --global core.excludesfile ~/.gitignore

WORKDIR /home/${USERNAME}

ENTRYPOINT [ "/usr/local/bin/start-vscode.sh" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=15 CMD [ "/usr/local/bin/healthcheck-vscode.sh" ]

EXPOSE 8000 22