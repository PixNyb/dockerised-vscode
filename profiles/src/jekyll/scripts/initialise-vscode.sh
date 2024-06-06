#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

extensions="christian-kohler.path-intellisense,formulahendry.auto-close-tag,formulahendry.auto-rename-tag,sissel.shopify-liquid"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST

cd $PROJECT_FOLDER

# If possible, run the Jekyll server
if [[ -f "_config.yml" ]]; then
	bundle install
fi

echo "alias serve='JEKYLL_ENV=production bundle exec jekyll serve --host 0.0.0.0 --drafts'" >>~/.bashrc

echo "echo -e 'You are currently running a \033[1;36mJekyll\033[0m generic container.'" >>~/.bashrc
echo "echo -e 'Useful commands:'" >>~/.bashrc
echo "echo -e '  - \033[1;36mserve\033[0m: Run the Jekyll server'" >>~/.bashrc
