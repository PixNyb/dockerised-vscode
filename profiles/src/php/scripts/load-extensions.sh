#!/bin/bash

extensions="bmewburn.vscode-intelephense-client,porifa.laravel-intelephense,xdebug.php-debug,devsense.profiler-php-vscode,devsense.composer-php-vscode"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST