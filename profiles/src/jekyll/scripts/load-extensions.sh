#!/usr/bin/env bash

EXTENSION_LIST=${EXTENSION_LIST-}
extensions="christian-kohler.path-intellisense,formulahendry.auto-close-tag,formulahendry.auto-rename-tag,sissel.shopify-liquid"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST