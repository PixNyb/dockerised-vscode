#!/bin/bash

EXTENSION_LIST=${EXTENSION_LIST-}
EXTENSION_LIST_URL=${EXTENSION_LIST_URL-}

# Install extensions from the EXTENSION_LIST_URL environment variable. It can contain a list of urls separated by commas.
if [[ -n ${EXTENSION_LIST_URL-} ]]; then
	IFS=',' read -r -a urls <<<"${EXTENSION_LIST_URL}"
	for url in "${urls[@]}"; do
		while IFS= read -r extension; do
			# Append the extension to the list of extensions
			if [[ -n ${EXTENSION_LIST-} ]]; then
				EXTENSION_LIST="${EXTENSION_LIST},${extension}"
			else
				EXTENSION_LIST="${extension}"
			fi
		done < <(curl -sSL "${url}" || echo "Failed to download ${url}")
	done
fi

if [[ -n ${EXTENSION_LIST} ]]; then
	IFS=',' read -r -a extensions <<<"${EXTENSION_LIST}"
	for extension in "${extensions[@]}"; do
		code --install-extension "${extension}" --force || echo "Failed to install ${extension}"
	done
fi