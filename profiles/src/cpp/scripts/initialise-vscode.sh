#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# If the project contains a vcpkg.json file, install the dependencies
if [[ -f vcpkg.json ]]; then
    vcpkg install --triplet x64-linux 
fi

echo "echo -e 'You are currently running a \033[1;36mC++\033[0m generic container.'" >>~/.bashrc
