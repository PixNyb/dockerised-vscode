#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

extensions="christian-kohler.path-intellisense,formulahendry.auto-close-tag,formulahendry.auto-rename-tag"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST

# Link apache to $PROJECT_FOLDER
sudo rm -rf /var/www/html
sudo ln -s "${PROJECT_FOLDER}" /var/www/html

# Start Apache
sudo service apache2 start

# Set up the HTML project
cd $PROJECT_FOLDER

echo "echo -e 'You are currently running a \033[1;36mHTML\033[0m generic container.'" >>~/.bashrc
