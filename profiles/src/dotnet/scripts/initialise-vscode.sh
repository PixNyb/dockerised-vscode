#!/usr/bin/env bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

cd $PROJECT_FOLDER

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
