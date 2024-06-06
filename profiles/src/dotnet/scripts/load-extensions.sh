#!/bin/bash

extensions="ms-dotnettools.csdevkit,ms-dotnettools.csharp,ms-dotnettools.dotnet-interactive-vscode,ms-dotnettools.vscode-dotnet-runtime,ionide.ionide-fsharp"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST