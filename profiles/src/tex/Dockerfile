FROM pixnyb/%image% as base

USER root

RUN apt-get update && apt-get install -y \
    texlive-full \
    && sudo rm -rf /var/lib/apt/lists/*

COPY bin/tex/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

# COPY templates/tex/* /etc/templates

USER vscode

ENV INITIAL_EXTENSIONS="mathematic.vscode-latex"

# Check if EXTENSION_LIST is already set and append the new extensions if it is
RUN if [ -n "${EXTENSION_LIST}" ]; then \
    EXTENSION_LIST="${EXTENSION_LIST},${INITIAL_EXTENSIONS}"; \
    else \
    EXTENSION_LIST="${INITIAL_EXTENSIONS}"; \
    fi \
    && export EXTENSION_LIST

# Set EXTENSION_LIST as a global environment variable
ENV EXTENSION_LIST=${EXTENSION_LIST}

# Set EXTENSION_LIST as a global environment variable
ENV EXTENSION_LIST=${EXTENSION_LIST}
