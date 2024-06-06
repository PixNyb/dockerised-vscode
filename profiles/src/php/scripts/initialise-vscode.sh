#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

extensions="bmewburn.vscode-intelephense-client,porifa.laravel-intelephense,xdebug.php-debug,devsense.profiler-php-vscode,devsense.composer-php-vscode"
if [ -z "$EXTENSION_LIST" ]; then
	EXTENSION_LIST=$extensions
else
	EXTENSION_LIST="$EXTENSION_LIST,$extensions"
fi
export EXTENSION_LIST

DB_HOST=${DB_HOST-}
DB_PORT=${DB_PORT:-3306}
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-password}
DB_DATABASE=${DB_DATABASE:-$PROJECT_NAME}

# If the DB_HOST is set and the DB_USER is root, attempt to connect to the database and create the database if it doesn't exist
if [[ -n $DB_HOST && $DB_USER == "root" ]]; then
	RES=0
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_DATABASE;" 2>/dev/null
	RES=$?

	# If the user is root, drop the existing user, create a new user with a random password and grant all privileges on the database
	DB_USER_PASSWORD=$(openssl rand -base64 12)
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "DROP USER IF EXISTS '$PROJECT_NAME'@'%';" 2>/dev/null
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "CREATE USER '$PROJECT_NAME'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';" 2>/dev/null
	RES=$((RES + $?))
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_DATABASE.* TO '$PROJECT_NAME'@'%';" 2>/dev/null
	RES=$((RES + $?))
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "FLUSH PRIVILEGES;" 2>/dev/null
	RES=$((RES + $?))

	# If any of the commands failed, output an error message
	if [[ $RES -ne 0 ]]; then
		echo "Failed to initialise the database, continuing without connection."
	else
		# Output the database details
		echo "Initialised database using root user:"
		echo "Host: $DB_HOST"
		echo "Port: $DB_PORT"
		echo "User: $PROJECT_NAME"
		echo "Password: $DB_USER_PASSWORD"
		echo "Database: $DB_DATABASE"

		# Set the DB_USER and DB_PASSWORD to the new user and password
		DB_USER=$PROJECT_NAME
		DB_PASSWORD=$DB_USER_PASSWORD
		export DB_USER
		export DB_PASSWORD

		echo "export DB_USER=$DB_USER" >>~/.bashrc
		echo "export DB_PASSWORD=$DB_PASSWORD" >>~/.bashrc
		echo "export DB_DATABASE=$DB_DATABASE" >>~/.bashrc
	fi
fi

# Link apache to $PROJECT_FOLDER
sudo rm -rf /var/www/html
sudo ln -s "${PROJECT_FOLDER}" /var/www/html

# Start Apache
sudo service apache2 start

# Set up the PHP project
cd "${PROJECT_FOLDER}" || exit

# If the project contains a composer-lock.json file, install the dependencies
if [[ -f composer.lock ]]; then
	composer install -n &
fi

# If the project does not yet contain a .env file, create one using /etc/templates/env. In order to do this, the project must contain a composer.json file to determine the project type
# Determine if the project uses a common framework, currently only Laravel and Silverstripe have supported .env files.
if [[ -f composer.json && ! -f .env ]]; then
	frameworks=($(ls "/etc/templates" | sed 's/\.env$//'))
	for framework in "${frameworks[@]}"; do
		if grep -q "\"$framework" composer.json; then
			echo "Creating .env file for $framework"
			template=$(<"/etc/templates/$framework.env")
			eval "echo \"$template\"" >.env

			# If there's an existing .env.* file, compare the two and add any missing variables to the .env file.
			# Do this by grabbing the keys from the existing .env.* file and adding any key not present in the .env file to the .env file.
			files=$(ls .env.* 2>/dev/null)
			if [[ -n $files ]]; then
				for file in $files; do
					while IFS='=' read -r key _; do
						# Skip lines that are comments or empty
						if [[ ! $key =~ ^# && -n $key ]]; then
							# Check if the key exists in the .env file
							if ! grep -q "^$key=" .env; then
								# If the key does not exist, add it to the .env file
								value=$(eval "echo \"\$$key\"")
								echo "$key=$value" >>.env
							fi
						fi
					done <"$file"
				done
			fi
			break
		fi
	done
fi

# If nvm is installed and .nvmrc exists, install the required node version
if [[ -f .nvmrc && -s "$NVM_DIR/nvm.sh" ]]; then
	NODE_VERSION=$(cat .nvmrc)
	source "$NVM_DIR/nvm.sh"
	nvm install "$NODE_VERSION"
	nvm use "$NODE_VERSION"

	# If the project contains a package-lock.json file, install the dependencies
	if [[ -f package-lock.json ]]; then
		npm install &
	fi

	# If the project contains a yarn.lock file, install the dependencies
	if [[ -f yarn.lock ]]; then
		npm install -g yarn && yarn install &
	fi
fi

echo "echo -e 'You are currently running a \033[1;36mPHP\033[0m generic container.'" >>~/.bashrc
echo "echo -e 'Included scripts:'" >>~/.bashrc
echo "echo -e '  - \033[1;34mimport-db\033[0m: Import a database dump into the database'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: import-db <sql_file>'" >>~/.bashrc
echo "echo -e '  - \033[1;34mexport-db\033[0m: Export the database into a dump file'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: export-db <dump_file>'" >>~/.bashrc
echo "echo -e '  - \033[1;34mclear-db\033[0m: Remove all tables from the database'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: clear-db <dump_file>'" >>~/.bashrc
