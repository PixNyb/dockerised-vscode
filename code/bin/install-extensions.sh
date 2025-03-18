#!/usr/bin/env bash

EXTENSION_LIST=${EXTENSION_LIST-}
EXTENSION_LIST_URL=${EXTENSION_LIST_URL-}

# Get the web cli
CODE_SERVER_PATH=$(ps -u $USER -o args | grep /bin/code-server | grep -v grep | awk '{print $2}')

# Install extensions from the EXTENSION_LIST_URL environment variable. It can contain a list of urls separated by commas.
if [[ -n ${EXTENSION_LIST_URL} ]]; then
	IFS=',' read -r -a urls <<<"${EXTENSION_LIST_URL}"
	for url in "${urls[@]}"; do
		while IFS= read -r extension; do
			# Append the extension to the list of extensions
			EXTENSION_LIST="${EXTENSION_LIST:+${EXTENSION_LIST},}${extension}"
		done < <(curl -sSL "${url}" || echo "Failed to download ${url}")
	done
fi

if [[ -n ${EXTENSION_LIST} ]]; then
	IFS=',' read -r -a extensions <<<"${EXTENSION_LIST}"
	for extension in "${extensions[@]}"; do
		# Install the extension
		code --install-extension "${extension}" --force || echo "Failed to install ${extension}" &
		$CODE_SERVER_PATH --install-extension "${extension}" --force || echo "Failed to install ${extension}" &
		wait
	done
fi