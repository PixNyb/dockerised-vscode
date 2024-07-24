#!/bin/bash
set -o pipefail -o nounset

# Make sure all the variables are set
REPO_URL=${REPO_URL-}
REPO_FOLDER=${REPO_FOLDER-}
GPG_SECRET_KEY=${GPG_SECRET_KEY-}
GPG_PASSPHRASE=${GPG_PASSPHRASE-}
GITHUB_TOKEN=${GITHUB_TOKEN-}
GH_TOKEN=${GH_TOKEN:-$GITHUB_TOKEN}
INIT_SCRIPT_URL=${INIT_SCRIPT_URL-}
EXTENSION_LIST=${EXTENSION_LIST-}
EXTENSION_LIST_URL=${EXTENSION_LIST_URL-}
SENDMAIL_HOST=${SENDMAIL_HOST:-localhost}
SENDMAIL_PORT=${SENDMAIL_PORT:-25}
HOSTNAME=$(hostname)
USERNAME=$(whoami)

# Make sure permissions for all mounted directories are correct
sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
sudo chown -R ${USERNAME}:${USERNAME} /etc/home

# Replace all invalid characters with _
EMAIL=$(echo "$HOSTNAME" | tr -cd '[:alnum:]_.-' | tr '[:upper:]' '[:lower:]')@roelc.dev

# Configure msmtp
sudo tee /etc/msmtprc << EOF > /dev/null
defaults
auth           off
tls            off
logfile        /var/log/msmtp.log

account        default
host           $SENDMAIL_HOST
port           $SENDMAIL_PORT
from           $EMAIL
EOF

# Create a binary for sendmail that ignores arguments that msmtprc doesn't support
sudo mv /usr/sbin/sendmail /usr/sbin/sendmail.bin
sudo tee /usr/sbin/sendmail << EOF > /dev/null
#!/bin/bash
# Remove the -bs option
ARGS=\$(echo "$@" | sed -e 's/-bs//g')
# Call msmtp with the modified arguments
/usr/sbin/sendmail.bin \$ARGS
EOF
sudo chmod +x /usr/sbin/sendmail 2>/dev/null

# Make the log file writable
sudo touch /var/log/msmtp.log
sudo chmod 777 /var/log/msmtp.log

# Copy all files from /etc/home to the user's home directory if the /etc/home directory exists
if [[ -d /etc/home ]]; then
	cp -rf /etc/home/* ~ 2>/dev/null
	cp -rf /etc/home/.[^.]* ~ 2>/dev/null
fi

# Start SSH
sudo service ssh start

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

# If the GITHUB_TOKEN or GH_TOKEN environment variables are set, run `gh auth setup-git` in order to allow for gh to authenticate git
if [[ -n ${GITHUB_TOKEN-} || -n ${GH_TOKEN-} ]]; then
	gh auth setup-git
fi

# Import the GPG key from the GPG_SECRET_KEY environment variable. If the GPG_PASSPHRASE environment variable is set, use it to unlock the GPG key.
if [[ -n ${GPG_SECRET_KEY-} ]]; then
	echo "${GPG_SECRET_KEY}" | base64 -d | gpg --batch --import
	if [[ -n ${GPG_PASSPHRASE-} ]]; then
		echo "${GPG_PASSPHRASE}" | gpg --batch --yes --passphrase-fd 0 --pinentry-mode loopback --output /dev/null --sign
	fi

	# Set the GPG_TTY environment variable to prevent pinentry from hanging
	export GPG_TTY=$(tty)

	# Set the default GPG key to the key imported
	default_key=$(gpg --list-secret-keys --keyid-format LONG)

	# Get the key ID of the default key
	default_key_id=$(echo "${default_key}" | grep -E "^sec" | awk '{print $2}' | awk -F'/' '{print $2}')

	# Check if the key is available in gh cli. If it's not added, add it.
	if [[ -n ${GITHUB_TOKEN-} || -n ${GH_TOKEN-} ]]; then
		gh_key=$(gh api /user/gpg_keys --paginate --jq ".[] | select(.key_id == \"${default_key_id}\")")
		if [[ -z ${gh_key} ]]; then
			# Get the key file
			key_file=$(mktemp)
			gpg --armor --export "${default_key_id}" >"${key_file}"

			# Add the key to GitHub
			gh gpg-key add "${key_file}" --title "GPG key for $(hostname)"
		fi
	fi

	# Set git config to verify commits with the default GPG key
	git config --global user.signingkey "${default_key_id}"
	git config --global commit.gpgsign true
fi

# If the container has the REPO_URL environment variable, clone it to $REPO_FOLDER/. Otherwise use the home folder
if [[ -n ${REPO_URL-} ]]; then
    repo_folder=${REPO_FOLDER:-~/}
    repo_folder=${repo_folder%/}
    project_name=$(basename "${REPO_URL}" .git)
    mkdir -p "${repo_folder}"
    git clone "${REPO_URL}" "${repo_folder}/${project_name}"
    export PROJECT_FOLDER="${repo_folder}/${project_name}"
    export PROJECT_NAME="${project_name}"

    # If the REPO_BRANCH environment variable is set, checkout that branch
    if [[ -n ${REPO_BRANCH-} ]]; then
        curdir=$(pwd)
        cd "${repo_folder}/${project_name}" || exit

        if git ls-remote --exit-code --heads "${REPO_URL}" "${REPO_BRANCH}" &>/dev/null; then
            git checkout "${REPO_BRANCH}"
        else
            git checkout -b "${REPO_BRANCH}"
        fi

        export PROJECT_BRANCH="${REPO_BRANCH}"
        cd "${curdir}" || exit
    fi
fi

source /usr/local/bin/load-extensions.sh
/usr/local/bin/initialise-vscode.sh

if [ -n "${INIT_SCRIPT_URL-}" ]; then
	curl -sSL "${INIT_SCRIPT_URL}" | bash;
fi

VSCODE_CLI_USE_FILE_KEYRING=1 VSCODE_CLI_DISABLE_KEYCHAIN_ENCRYPT=1 \
	code serve-web \
    	--disable-telemetry \
    	--without-connection-token \
    	--accept-server-license-terms \
    	--host 0.0.0.0 &

VS_CODE_PID=$!

# Wait for any file matching /tmp/code-*
while [ -z "$(ls /tmp/code-* 2>/dev/null)" ]; do
	curl http://localhost:8000 > /dev/null 2>&1
    sleep 1
done

sleep 3

# Install extensions
/usr/local/bin/install-extensions.sh

# Wait for VS Code server to end
wait $VS_CODE_PID
fg