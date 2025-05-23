#!/usr/bin/env bash

EXTENSION_LIST=${EXTENSION_LIST-}
extensions="golang.go,hashicorp.terraform,ms-kubernetes-tools.vscode-kubernetes-tools,ms-azuretools.vscode-containers,ms-kubernetes-tools.vscode-aks-tools,redhat.vscode-openshift-connector,ms-kubernetes-tools.kind-vscode,inercia.vscode-k3d,gardener.vscode-gardener-tools"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST