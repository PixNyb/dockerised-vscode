#!/bin/bash

extensions="christian-kohler.npm-intellisense,christian-kohler.path-intellisense,dbaeumer.vscode-eslint,esbenp.prettier-vscode,formulahendry.auto-close-tag,formulahendry.auto-rename-tag"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST