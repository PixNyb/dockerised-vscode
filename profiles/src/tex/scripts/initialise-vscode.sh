#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Set up the Tex project
cd $PROJECT_FOLDER

echo "echo -e 'You are currently running a \033[1;31mTex\033[0m generic container.'" >>~/.bashrc