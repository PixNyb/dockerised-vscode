#!/usr/bin/env bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

cd $PROJECT_FOLDER

if [ -d "$HOME/.nvm/.git" ]; then
	. "$HOME/.nvm/nvm.sh"

	if [ -f .nvmrc ]; then
		NODE_VERSION=$(cat .nvmrc)
		source "$NVM_DIR/nvm.sh"
		nvm install "$NODE_VERSION"
		nvm use "$NODE_VERSION"
	fi

	if [[ -f package-lock.json ]]; then
		npm install &
	fi

	if [[ -f yarn.lock ]]; then
		npm install -g yarn && yarn install &
	fi
fi
