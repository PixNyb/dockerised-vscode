#!/usr/bin/env bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

if [[ -f vcpkg.json ]]; then
    vcpkg install --triplet x64-linux
fi
