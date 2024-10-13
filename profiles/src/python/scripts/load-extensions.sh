#!/bin/bash

extensions="ms-python.python,ms-python.debugpy,donjayamanne.python-environment-manager,kevinrose.vsc-python-indent,wholroyd.jinja,batisteo.vscode-django"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST