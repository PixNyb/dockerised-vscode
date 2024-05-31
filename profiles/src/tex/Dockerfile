FROM pixnyb/%image% as base

USER root

RUN apt-get update && apt-get install -y \
    texlive-full \
    && sudo rm -rf /var/lib/apt/lists/*

USER vscode

RUN EXTENSION_LIST="mathematic.vscode-latex" /usr/local/bin/install-extensions.sh