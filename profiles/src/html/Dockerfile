FROM pixnyb/%image% as base

USER root

RUN apt-get update && apt-get install -y \
    apache2 \
    && sudo rm -rf /var/lib/apt/lists/*

RUN sed -i "s|</VirtualHost>|    <Directory /var/www/html>\n        SetEnvIf X-Forwarded-Proto "https" HTTPS=on\n        Options Indexes FollowSymLinks\n        AllowOverride All\n        Require all granted\n    </Directory>\n</VirtualHost>|g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s|export APACHE_RUN_USER=www-data|export APACHE_RUN_USER=$USER|g" /etc/apache2/envvars
RUN sed -i "s|export APACHE_RUN_GROUP=www-data|export APACHE_RUN_GROUP=$USER|g" /etc/apache2/envvars
RUN a2enmod rewrite

COPY bin/html/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

RUN chmod 777 /var/www/html

USER vscode

EXPOSE 80