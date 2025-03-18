#!/usr/bin/env bash

extensions="James-Yu.latex-workshop"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST