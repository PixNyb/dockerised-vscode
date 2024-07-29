#!/bin/bash

extensions="ms-vscode.cpptools,llvm-vs-code-extensions.vscode-clangd,ms-vscode.cmake-tools"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST