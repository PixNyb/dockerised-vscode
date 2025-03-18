#!/usr/bin/env bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

DB_HOST=${DB_HOST-}
DB_PORT=${DB_PORT:-3306}
DB_USER=${DB_USER:-root}
DB_PASSWORD=${DB_PASSWORD:-password}
DB_DATABASE=${DB_DATABASE:-$PROJECT_NAME}

if [[ -n $DB_HOST && $DB_USER == "root" ]]; then
	RES=0
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_DATABASE;" 2>/dev/null
	RES=$?

	DB_USER_USERNAME=${DB_DATABASE}
	DB_USER_PASSWORD=$(openssl rand -base64 12)
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "DROP USER IF EXISTS '$DB_USER_USERNAME'@'%';" 2>/dev/null
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "CREATE USER '$DB_USER_USERNAME'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';" 2>/dev/null
	RES=$((RES + $?))
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_DATABASE.* TO '$DB_USER_USERNAME'@'%';" 2>/dev/null
	RES=$((RES + $?))
	mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "FLUSH PRIVILEGES;" 2>/dev/null
	RES=$((RES + $?))

	if [[ $RES -ne 0 ]]; then
		echo "Failed to initialise the database, continuing without connection."
	else
		# Output the database details
		echo "Initialised database using root user:"
		echo "Host: $DB_HOST"
		echo "Port: $DB_PORT"
		echo "User: $DB_USER_USERNAME"
		echo "Password: $DB_USER_PASSWORD"
		echo "Database: $DB_DATABASE"

		DB_USER=$DB_USER_USERNAME
		DB_PASSWORD=$DB_USER_PASSWORD
		export DB_USER
		export DB_PASSWORD

		echo "export DB_USER=$DB_USER" >>~/.bashrc
		echo "export DB_PASSWORD=$DB_PASSWORD" >>~/.bashrc
		echo "export DB_DATABASE=$DB_DATABASE" >>~/.bashrc
	fi
fi

sudo rm -rf /var/www/html
sudo ln -s "${PROJECT_FOLDER}" /var/www/html

if [[ -n $GH_TOKEN ]]; then
	composer config -g github-oauth.github.com "$GH_TOKEN"
fi

sudo service apache2 start

cd $PROJECT_FOLDER

if [[ -f composer.lock ]]; then
	composer install -n &
fi

if [[ -f composer.json && ! -f .env ]]; then
	frameworks=($(ls "/etc/templates" | sed 's/\.env$//'))
	for framework in "${frameworks[@]}"; do
		if grep -q "\"$framework" composer.json; then
			echo "Creating .env file for $framework"
			template=$(<"/etc/templates/$framework.env")
			eval "echo \"$template\"" >.env

			files=$(ls .env.* 2>/dev/null)
			if [[ -n $files ]]; then
				for file in $files; do
					while IFS='=' read -r key _; do
						if [[ ! $key =~ ^# && -n $key ]]; then
							if ! grep -q "^$key=" .env; then
								value=$(eval "echo \"\$$key\"")

								if [[ -n $value ]]; then
									echo "$key=\"$value\"" >>.env
								else
									echo "$key=\"\"" >>.env
								fi
							fi
						fi
					done <"$file"
				done
			fi
			break
		fi
	done
fi

if [ -d "$HOME/.nvm/.git" ]; then
	. "$HOME/.nvm/nvm.sh"

	if [ -f .nvmrc ]; then
		NODE_VERSION=$(cat .nvmrc)
		source "$NVM_DIR/nvm.sh"
		nvm install "$NODE_VERSION"
		nvm use "$NODE_VERSION"
	fi

	if [[ -f package-lock.json ]]; then
		npm install &
	fi

	if [[ -f yarn.lock ]]; then
		npm install -g yarn && yarn install &
	fi
fi
