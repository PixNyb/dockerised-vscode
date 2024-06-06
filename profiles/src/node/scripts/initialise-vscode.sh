#!/bin/bash

# Add extension to the list of extensions
extensions=(
	"christian-kohler.npm-intellisense"
	"christian-kohler.path-intellisense"
	"dbaeumer.vscode-eslint"
	"esbenp.prettier-vscode"
	"formulahendry.auto-close-tag"
	"formulahendry.auto-rename-tag"
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Set up the HTML project
cd $PROJECT_FOLDER

# If nvm is installed and .nvmrc exists, install the required node version
if [[ -f .nvmrc && -s "$NVM_DIR/nvm.sh" ]]; then
	NODE_VERSION=$(cat .nvmrc)
	source "$NVM_DIR/nvm.sh"
	nvm install "$NODE_VERSION"
	nvm use "$NODE_VERSION"

	# If the project contains a package-lock.json file, install the dependencies
	if [[ -f package-lock.json ]]; then
		npm install &
	fi

	# If the project contains a yarn.lock file, install the dependencies
	if [[ -f yarn.lock ]]; then
		npm install -g yarn && yarn install &
	fi
fi

echo "echo -e 'You are currently running a \033[1;36mNode.js\033[0m generic container.'" >>~/.bashrc
