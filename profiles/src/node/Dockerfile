FROM pixnyb/%image% as base

USER root

COPY bin/node/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

# COPY templates/php/* /etc/templates

USER vscode

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc \
    && . ~/.nvm/nvm.sh \
    && nvm install node \
    && nvm use node \
    && npm install -g yarn

ENV INITIAL_EXTENSIONS="christian-kohler.npm-intellisense,christian-kohler.path-intellisense,dbaeumer.vscode-eslint,esbenp.prettier-vscode,formulahendry.auto-close-tag,formulahendry.auto-rename-tag"

# Check if EXTENSION_LIST is already set and append the new extensions if it is
RUN if [ -n "${EXTENSION_LIST}" ]; then \
    EXTENSION_LIST="${EXTENSION_LIST},${INITIAL_EXTENSIONS}"; \
    else \
    EXTENSION_LIST="${INITIAL_EXTENSIONS}"; \
    fi

EXPOSE 80