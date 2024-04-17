#!/bin/bash
set -o pipefail -o nounset
: "${VSCODE_KEYRING_PASS:?Variable not set or empty}"

# Make sure permissions for all mounted directories are correct
USERNAME=$(whoami)
sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
sudo chown -R ${USERNAME}:${USERNAME} /etc/home

# Copy all files from /etc/home to the user's home directory if the /etc/home directory exists
if [[ -d /etc/home ]]; then
	cp -rf /etc/home/* ~
	cp -rf /etc/home/.[^.]* ~
fi

# Set git config to use environment variables.
# All of these variables can be set/overridden using the following naming convention:
# GIT_{CONFIG_NAME}_{CONFIG_KEY} where:
# - {CONFIG_NAME} is the name of the config file (e.g. GLOBAL, SYSTEM, LOCAL)
# - {CONFIG_KEY} is the key of the config value (e.g. USER_NAME, USER_EMAIL)
# For example, to set the global user.name config, you would set the GIT_GLOBAL_USER_NAME environment variable.

# Get all the environment variables that start with GIT_
env | grep -o '^GIT_[^=]\+' | while read -r git_config; do
	# Get the value of the environment variable
	git_config_value="${!git_config}"
	# Get the config name and key
	git_config_name=$(echo "${git_config}" | cut -d_ -f2 | tr '[:upper:]' '[:lower:]')
	git_config_key=$(echo "${git_config}" | cut -d_ -f3- | tr '[:upper:]' '[:lower:]' | tr '_' '.')
	# Set the git config
	git config --"${git_config_name}" "${git_config_key}" "${git_config_value}"
done

# Run a dbus session, which unlocks the gnome-keyring and runs the VS Code Server inside of it
dbus-run-session -- sh -c "(echo ${VSCODE_KEYRING_PASS} | gnome-keyring-daemon --unlock) \
    && /usr/local/bin/initialise-vscode.sh \
    && code serve-web \
        --disable-telemetry \
        --without-connection-token \
        --accept-server-license-terms \
        --host 0.0.0.0"
