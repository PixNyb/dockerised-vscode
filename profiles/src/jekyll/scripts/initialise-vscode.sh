#!/bin/bash

# Add extension to the list of extensions
extensions=(
	"christian-kohler.path-intellisense"
	"formulahendry.auto-close-tag"
	"formulahendry.auto-rename-tag"
	"sissel.shopify-liquid"
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

cd $PROJECT_FOLDER

# If possible, run the Jekyll server
if [[ -f "_config.yml" ]]; then
	bundle install
fi

echo "alias serve='JEKYLL_ENV=production bundle exec jekyll serve --host 0.0.0.0 --drafts'" >>~/.bashrc

echo "echo -e 'You are currently running a \033[1;36mJekyll\033[0m generic container.'" >>~/.bashrc
echo "echo -e 'Useful commands:'" >>~/.bashrc
echo "echo -e '  - \033[1;36mserve\033[0m: Run the Jekyll server'" >>~/.bashrc
