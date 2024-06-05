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
    && sudo rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/rbenv/rbenv.git /home/vscode/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git /home/vscode/.rbenv/plugins/ruby-build \
    && /home/vscode/.rbenv/plugins/ruby-build/install.sh

RUN echo 'eval "$(rbenv init -)"' >>/home/vscode/.bashrc

ENV PATH="/home/vscode/.rbenv/bin:/home/vscode/.rbenv/shims:$PATH"

RUN source /home/vscode/.bashrc \
    && RUBY_VERSION=$(rbenv install -l | grep -v - | tail -1) \
    && rbenv install $RUBY_VERSION \
    && rbenv global $RUBY_VERSION

RUN gem install jekyll bundler

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
