FROM pixnyb/%image% as base

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

RUN export HOME="/home/vscode" \
    && git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build \
    && $HOME/.rbenv/plugins/ruby-build/install.sh \
    && echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc \
    && export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH" \
    && RUBY_VERSION=$(rbenv install -l | grep -v - | tail -1) \
    && rbenv install $RUBY_VERSION \
    && rbenv global $RUBY_VERSION \
    && rbenv rehash \
    && gem install jekyll bundler

ENV PATH="/home/vscode/.rbenv/bin:/home/vscode/.rbenv/shims:$PATH"

COPY bin/jekyll/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

# COPY templates/jekyll/* /etc/templates

USER vscode

ENV INITIAL_EXTENSIONS="christian-kohler.path-intellisense,formulahendry.auto-close-tag,formulahendry.auto-rename-tag,sissel.shopify-liquid"

# Check if EXTENSION_LIST is already set and append the new extensions if it is
RUN if [ -n "${EXTENSION_LIST}" ]; then \
    EXTENSION_LIST="${EXTENSION_LIST},${INITIAL_EXTENSIONS}"; \
    else \
    EXTENSION_LIST="${INITIAL_EXTENSIONS}"; \
    fi \
    && export EXTENSION_LIST

# Set EXTENSION_LIST as a global environment variable
ENV EXTENSION_LIST=${EXTENSION_LIST}