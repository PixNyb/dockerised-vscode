#!/bin/bash

extensions="vscjava.vscode-java-debug,vscjava.vscode-java-test,vscjava.vscode-maven,vscjava.vscode-gradle,redhat.java,vscjava.vscode-spring-initializr,dgileadi.java-decompiler"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST