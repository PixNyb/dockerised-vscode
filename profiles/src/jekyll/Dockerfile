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

RUN git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build \
    && $HOME/.rbenv/plugins/ruby-build/install.sh \
    && echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc \
    && export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH" \
    && RUBY_VERSION=$(rbenv install -l | grep -v - | tail -1) \
    && rbenv install $RUBY_VERSION \
    && rbenv global $RUBY_VERSION \
    && rbenv rehash \
    && gem install jekyll bundler