FROM pixnyb/%image% as base

USER root

RUN apt-get update && apt-get install -y \
    apache2 \
    && sudo rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

RUN chmod 777 /var/www/html

ENV EXTENSION_LIST="christian-kohler.path-intellisense,formulahendry.auto-close-tag,formulahendry.auto-rename-tag"

USER vscode

EXPOSE 80