#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Create a new Python virtual environment
python3 -m venv $PROJECT_FOLDER/.venv

# Activate the virtual environment
source $PROJECT_FOLDER/.venv/bin/activate

echo "echo -e 'You are currently running a \033[1;31mPython\033[0m generic container.'" >>~/.bashrc
echo "echo -e 'Included scripts:'" >>~/.bashrc
echo "echo -e '  - \033[1;34mactivate\033[0m: Activate a Python virtual environment'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: activate [-p <path>] (default path: $PROJECT_FOLDER/.venv)'" >>~/.bashrc
