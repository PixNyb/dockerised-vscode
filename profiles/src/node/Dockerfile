FROM pixnyb/%image% AS base

USER root

COPY bin/node/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc \
    && . ~/.nvm/nvm.sh \
    && nvm install node \
    && nvm use node \
    && npm install -g yarn

ENV PATH="./node_modules/.bin:${PATH}"

EXPOSE 80