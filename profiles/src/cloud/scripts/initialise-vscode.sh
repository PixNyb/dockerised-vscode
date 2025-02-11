#!/bin/bash

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null
minikube completion bash | sudo tee /etc/bash_completion.d/minikube > /dev/null
k3d completion bash | sudo tee /etc/bash_completion.d/k3d > /dev/null
kind completion bash | sudo tee /etc/bash_completion.d/kind > /dev/null

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

sudo dockerd &

echo "echo -e 'You are currently running a \033[1;36mCloud\033[0m generic container.'" >>~/.bashrc
