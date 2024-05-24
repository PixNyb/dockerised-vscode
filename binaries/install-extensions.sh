#!/bin/bash

EXTENSION_LIST=${EXTENSION_LIST:-}

if [[ -n ${EXTENSION_LIST} ]]; then
    IFS=',' read -r -a extensions <<<"${EXTENSION_LIST}"
    for extension in "${extensions[@]}"; do
        code --install-extension "${extension}" --force || echo "Failed to install ${extension}" &
    done
fi

exit 0;