#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Set up the .NET project
cd $PROJECT_FOLDER

# If there are any project or solution files, use them
for file in *.csproj; do
	if [[ -f $file ]]; then
		dotnet restore $file
	fi
done

for file in *.fsproj; do
	if [[ -f $file ]]; then
		dotnet restore $file
	fi
done

for file in *.sln; do
	if [[ -f $file ]]; then
		dotnet restore $file
	fi
done

echo "echo -e 'You are currently running a \033[1;31m.NET\033[0m generic container.'" >>~/.bashrc
