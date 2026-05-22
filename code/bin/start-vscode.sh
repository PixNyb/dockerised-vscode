#!/usr/bin/env bash

set -o pipefail -o nounset

read_file_env() {
    for var in $(env | grep -o '^[^=]*_FILE'); do
        file_var_name="${var%_FILE}"
        if [[ -n ${!var} && -f ${!var} ]]; then
            export "${file_var_name}"="$(<"${!var}")"
        fi
    done
}

check_docker_socket() {
	echo "- Checking docker socket..."
    if [ -S /var/run/docker.sock ]; then
		echo "- Docker socket found..."
        DOCKER_GROUP=$(stat -c '%G' /var/run/docker.sock)
        if ! groups "$(whoami)" | grep -q "\b${DOCKER_GROUP}\b"; then
            sudo usermod -aG "$DOCKER_GROUP" "$(whoami)"
            newgrp "$DOCKER_GROUP" <<EOF
            $(cat "$0")
EOF
            exit

			echo "- User added to docker group..."
        fi
    fi
}

enable_vnc() {
	echo "- Checking VNC..."
	if [[ -n ${ENABLE_VNC-} ]]; then
		/usr/local/bin/start-vnc.sh
	fi
}

configure_msmtp() {
	echo "- Configuring msmtp..."
    EMAIL=$(echo "$(hostname)" | tr -cd '[:alnum:]_.-' | tr '[:upper:]' '[:lower:]')@mail.dev
    sudo tee /etc/msmtprc << EOF
defaults
auth           off
tls            off
logfile        /var/log/msmtp.log

account        default
host           ${SENDMAIL_HOST:-localhost}
port           ${SENDMAIL_PORT:-25}
from           $EMAIL
EOF
    sudo touch /var/log/msmtp.log
    sudo chmod 777 /var/log/msmtp.log

	echo "- Configuring mail..."
	sudo tee /etc/mail.rc << EOF
set sendmail="/usr/bin/msmtp"
EOF

	if [[ -n ${SENDMAIL_USER-} ]]; then
		sudo tee -a /etc/msmtprc << EOF
user           ${SENDMAIL_USER}
password       ${SENDMAIL_PASSWORD}
EOF
	fi

	echo "- Mail configured..."
}

copy_home_files() {
    if [[ -d /etc/home ]]; then
		echo "- Copying home files..."
        cp -rf /etc/home/* ~ 2>/dev/null || true
        cp -rf /etc/home/.[^.]* ~ 2>/dev/null || true
        if [[ -d ~/.ssh ]]; then
			echo "- Setting permissions on ssh files..."
            chmod 700 ~/.ssh
            chmod 600 ~/.ssh/*
            chmod 644 ~/.ssh/*.pub
            chmod 644 ~/.ssh/known_hosts
            chmod 600 ~/.ssh/config
            chmod 600 ~/.ssh/authorized_keys
        fi

        if [[ -d ~/.gnupg ]]; then
            echo "- Setting permissions on gpg files..."
            chmod 700 ~/.gnupg
            chmod 600 ~/.gnupg/*
        fi

        if [[ -f ~/.gitconfig ]]; then
            echo "- Setting permissions on gitconfig..."
            chmod 600 ~/.gitconfig
        fi

        if [[ -f ~/.msmtprc ]]; then
            echo "- Setting permissions on msmtprc..."
            chmod 600 ~/.msmtprc
        fi

        if [[ -f ~/.netrc ]]; then
            echo "- Setting permissions on netrc..."
            chmod 600 ~/.netrc
        fi

        sudo chown -R "$(id -u)":"$(id -g)" ~

		echo "- Home files copied..."
    fi
}

setup_github_auth() {
    if [[ -n ${GH_TOKEN-} ]]; then
		echo "- Setting up github auth..."
        gh auth setup-git
    fi
}

setup_gitlab_auth() {
	if [[ -n ${GITLAB_TOKEN-} ]]; then
		echo "- Setting up gitlab auth..."
		git config --global credential.'https://gitlab.com'.helper '!/usr/bin/glab auth git-credential'
    fi
}

import_gpg_key() {
    if [[ -n ${GPG_SECRET_KEY-} ]]; then
		echo "- Importing gpg key..."
        if ! echo "${GPG_SECRET_KEY}" | base64 -d | gpg --batch --import; then
            echo "- Failed to import GPG key. Please check the GPG_SECRET_KEY environment variable."
            return 1
        fi

		if [[ $? -ne 0 ]]; then
			echo "- Failed to import gpg key..."
		fi

		if [[ -n ${GPG_PASSPHRASE-} ]]; then
            echo "${GPG_PASSPHRASE}" | gpg --batch --yes --passphrase-fd 0 --pinentry-mode loopback --output /dev/null --sign
			if [[ $? -ne 0 ]]; then
				echo "- Failed to import gpg key..."
			fi

			echo "- Gpg key imported..."
        fi

		export GPG_TTY=$(tty)
		echo "export GPG_TTY=$(tty)" >>~/.bashrc

		default_key=$(gpg --list-secret-keys --keyid-format LONG)
        default_key_id=$(echo "${default_key}" | grep -E "^sec" | awk '{print $2}' | awk -F'/' '{print $2}')

		if [[ -n ${GITHUB_TOKEN-} ]]; then
            gh_key=$(gh api /user/gpg_keys --paginate --jq ".[] | select(.key_id == \"${default_key_id}\")")
            if [[ -z ${gh_key} ]]; then
				echo "Adding gpg key to github..."

                key_file=$(mktemp)
                gpg --armor --export "${default_key_id}" >"${key_file}"
                gh gpg-key add "${key_file}" --title "GPG key for $(hostname)"

				if [[ $? -ne 0 ]]; then
					echo "- Failed to add gpg key to github..."
				else
					echo "- Gpg key added to github..."
				fi
            fi
        fi

        git config --global user.signingkey "${default_key_id}"
        git config --global commit.gpgsign true

		echo "- Gpg key configured and commit signing enabled..."
    fi
}

clone_repo() {
    if [[ -n ${REPO_URL-} ]]; then
		echo "- Cloning repo..."
        repo_folder=${REPO_FOLDER:-~/}
        repo_folder=${repo_folder%/}
        project_name=$(basename "${REPO_URL}" .git)

        mkdir -p "${repo_folder}"
        if ! git clone "${REPO_URL}" "${repo_folder}/${project_name}"; then
            echo "- Failed to clone repo. Please check the REPO_URL environment variable."
            return 1
        fi

		if [[ $? -ne 0 ]]; then
			echo "- Failed to clone repo..."
		fi

		export PROJECT_FOLDER="${repo_folder}/${project_name}"
        export PROJECT_NAME="${project_name}"

		if [[ -n ${REPO_BRANCH-} ]]; then
            curdir=$(pwd)
            cd "${repo_folder}/${project_name}"

			if git ls-remote --exit-code --heads "${REPO_URL}" "${REPO_BRANCH}" &>/dev/null; then
                git checkout "${REPO_BRANCH}"
            else
                git checkout -b "${REPO_BRANCH}"
            fi

			echo "- Repo cloned and checked out to branch ${REPO_BRANCH}..."

			if [[ -n ${REPO_SCRIPT_FILE-} ]]; then
				echo "- Running post-clone script..."

                repo_script_path=$(realpath "${REPO_SCRIPT_FILE}")
                repo_path=$(realpath "${repo_folder}/${project_name}")

                if [[ "${repo_script_path}" != "${repo_path}"* ]]; then
                    echo "! The script file is outside of the repo folder. Please check the REPO_SCRIPT_FILE environment variable."
                    echo "! The script file must be inside the repo folder for security reasons."
                    echo "! Skipping running the post-clone script..."
				else
                    source "./${REPO_SCRIPT_FILE}"
				    echo "- Post-clone script ran..."
                fi
            fi

			export PROJECT_BRANCH="${REPO_BRANCH}"
            cd "${curdir}"
        fi
    fi
}

set_git_config() {
	echo "- Setting global git config..."

    env | grep -o '^GIT_[^=]\+' | while read -r git_config; do
        git_config_value="${!git_config}"
        git_config_name=$(echo "${git_config}" | cut -d_ -f2 | tr '[:upper:]' '[:lower:]')
        git_config_key=$(echo "${git_config}" | cut -d_ -f3- | tr '[:upper:]' '[:lower:]' | tr '_' '.')

        echo "Processing ${git_config_name} git config ${git_config_key}=${git_config_value}"

        if [[ "${git_config_name}" != "local" ]]; then
            echo "Setting ${git_config_name} git config ${git_config_key}=${git_config_value}"
            if ! git config --"${git_config_name}" "${git_config_key}" "${git_config_value}"; then
                echo "! Error setting ${git_config_name} git config ${git_config_key}=${git_config_value}"
            fi
        fi
    done

    echo "- Global git config set..."
}

set_local_git_config() {
    if [[ -z ${PROJECT_FOLDER-} ]]; then
        echo "- No project folder found, skipping local git config..."
    else
        echo "- Setting local git config..."

        curdir=$(pwd)
        cd "${PROJECT_FOLDER}"

        env | grep -o '^GIT_LOCAL_[^=]\+' | while read -r git_config; do
            git_config_value="${!git_config}"
            git_config_key=$(echo "${git_config}" | cut -d_ -f3- | tr '[:upper:]' '[:lower:]' | tr '_' '.')

            echo "Setting local git config ${git_config_key} ${git_config_value}"
            git config --local "${git_config_key}" "${git_config_value}"
        done

        cd "${curdir}"

        echo "- Local git config set..."
    fi
}

start_vscode() {
	echo "- Starting VS Code..."
    local additional_args=""

    # If the PROJECT_FOLDER is available, set the '--default-folder' to it
    local additional_args=""
    if [[ -n ${PROJECT_FOLDER-} ]]; then
        additional_args="--default-folder ${PROJECT_FOLDER}"
    fi

    # If a workspace is explicitly provided, use it; otherwise, use the first one in the project folder
    if [[ -n ${PROJECT_WORKSPACE-} ]]; then
        additional_args="${additional_args} --default-workspace ${PROJECT_WORKSPACE}"
    elif [[ -n ${PROJECT_FOLDER-} ]]; then
        workspace_file=$(find "${PROJECT_FOLDER}" -maxdepth 1 -type f -name "*.code-workspace" | head -n 1)
        if [[ -n ${workspace_file-} ]]; then
            additional_args="${additional_args} --default-workspace ${workspace_file}"
        fi
    fi

    code serve-web \
        --disable-telemetry \
        --without-connection-token \
        --accept-server-license-terms \
        --host 0.0.0.0 \
        --port 8000 \
        ${additional_args} &

    VSCODE_PID=$!

	echo "- VS Code started on pid ${VSCODE_PID}..."

    timeout=30
    while [ -z "$(ls /tmp/code-* 2>/dev/null)" ] && [ $timeout -gt 0 ]; do
        curl http://localhost:8000 > /dev/null 2>&1
        sleep 1
        timeout=$((timeout - 1))
    done

    if [ $timeout -eq 0 ]; then
        echo "- VS Code server failed to start within the timeout period."
        return 1
    fi

    sleep 3

	echo "- Installing extensions..."
    /usr/local/bin/install-extensions.sh
	echo "- Extensions installed..."
    wait $VSCODE_PID
    fg
}

main() {
    read_file_env
    check_docker_socket
    configure_msmtp
    copy_home_files
    setup_github_auth
    setup_gitlab_auth
    import_gpg_key
    set_git_config
    clone_repo
    set_local_git_config

    source /usr/local/bin/load-extensions.sh
    /usr/local/bin/initialise-vscode.sh

    echo "- Starting SSH server..."
    sudo service ssh start

    if [[ $? -ne 0 ]]; then
        echo "- Failed to start SSH server..."
    else
        echo "- SSH server started..."
    fi

	enable_vnc
	start_vscode
}

main "$@"
