#!/usr/bin/env bash

extensions="bmewburn.vscode-intelephense-client,porifa.laravel-intelephense,adrianhumphreys.silverstripe,xdebug.php-debug,devsense.profiler-php-vscode,devsense.composer-php-vscode"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST