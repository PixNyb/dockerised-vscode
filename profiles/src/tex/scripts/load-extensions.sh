#!/usr/bin/env bash

EXTENSION_LIST=${EXTENSION_LIST-}
extensions="James-Yu.latex-workshop"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST