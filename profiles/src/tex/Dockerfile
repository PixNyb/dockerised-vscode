FROM pixnyb/%image% AS base

USER root

RUN apt-get update && apt-get install -y \
    texlive-full \
    && sudo rm -rf /var/lib/apt/lists/*

COPY bin/tex/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

# COPY templates/tex/* /etc/templates

USER vscode
