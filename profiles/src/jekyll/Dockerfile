FROM pixnyb/%image% AS base

USER root

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    autoconf \
    bison \
    build-essential \
    libyaml-dev \
    libreadline-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm-dev \
    && rm -rf /var/lib/apt/lists/*

COPY bin/jekyll/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

# COPY templates/jekyll/* /etc/templates

ENV PATH="/home/vscode/.rbenv/bin:/home/vscode/.rbenv/shims:$PATH"

USER vscode

RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash