#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

sudo dockerd &

echo "echo -e 'You are currently running a \033[1;36mCloud\033[0m generic container.'" >>~/.bashrc
