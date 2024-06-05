#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Add extension to the list of extensions
extensions=(
	"bmewburn.vscode-intelephense-client"
	"porifa.laravel-intelephense"
	"xdebug.php-debug"
	"devsense.profiler-php-vscode"
	"devsense.composer-php-vscode"
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

# Link apache to $PROJECT_FOLDER
sudo rm -rf /var/www/html
sudo ln -s "${PROJECT_FOLDER}" /var/www/html

# Start Apache
sudo service apache2 start

echo "echo -e 'You are currently running a \033[1;36mPHP\033[0m generic container.'" >>~/.bashrc

# Set up the PHP project
cd "${PROJECT_FOLDER}" || exit

# If the project contains a composer-lock.json file, install the dependencies
if [[ -f composer.lock ]]; then
	composer install -n &
fi
