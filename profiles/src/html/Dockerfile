FROM pixnyb/%image% as base

USER root

RUN apt-get update && apt-get install -y \
    apache2 \
    && sudo rm -rf /var/lib/apt/lists/*

RUN sed -i "s|</VirtualHost>|    <Directory /var/www/html>\n        Options Indexes FollowSymLinks\n        AllowOverride All\n        Require all granted\n    </Directory>\n</VirtualHost>|g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s|export APACHE_RUN_USER=www-data|export APACHE_RUN_USER=$USER|g" /etc/apache2/envvars
RUN sed -i "s|export APACHE_RUN_GROUP=www-data|export APACHE_RUN_GROUP=$USER|g" /etc/apache2/envvars
RUN a2enmod rewrite

COPY bin/html/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

RUN chmod 777 /var/www/html

USER vscode

ENV INITIAL_EXTENSIONS="christian-kohler.path-intellisense,formulahendry.auto-close-tag,formulahendry.auto-rename-tag"

# Check if EXTENSION_LIST is already set and append the new extensions if it is
RUN if [ -n "${EXTENSION_LIST}" ]; then \
    EXTENSION_LIST="${EXTENSION_LIST},${INITIAL_EXTENSIONS}"; \
    else \
    EXTENSION_LIST="${INITIAL_EXTENSIONS}"; \
    fi

EXPOSE 80