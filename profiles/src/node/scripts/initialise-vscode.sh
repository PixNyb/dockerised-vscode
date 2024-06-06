#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Set up the HTML project
cd $PROJECT_FOLDER

if [ -d "$HOME/.nvm/.git" ]; then
	if [ -f .nvmrc ]; then
		NODE_VERSION=$(cat .nvmrc)
		source "$NVM_DIR/nvm.sh"
		nvm install "$NODE_VERSION"
		nvm use "$NODE_VERSION"
	fi

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
