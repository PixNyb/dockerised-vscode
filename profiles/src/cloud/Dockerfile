FROM pixnyb/%image% AS base

USER root

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    sudo apt-get install apt-transport-https --yes && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    sudo apt-get update && \
    sudo apt-get install helm -y

RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-$(dpkg --print-architecture) && \
    install minikube-linux-$(dpkg --print-architecture) /usr/local/bin/minikube && \
    rm minikube-linux-$(dpkg --print-architecture)

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

ENV GOPATH=/home/vscode/.local/go
ENV PATH=$PATH:/home/vscode/.local/go/bin

RUN mkdir -p /home/vscode/.local/go/bin && \
    mkdir -p /home/vscode/.local/go/src && \
    mkdir -p /home/vscode/.local/go/pkg

RUN apt update && apt install -y golang-go && \
    go install sigs.k8s.io/kind@v0.24.0

RUN chmod -R 775 /home/vscode/.local/go && \
    chown -R vscode:vscode /home/vscode/.local/go

RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x86_64"; elif [ "$ARCH" = "arm64" ]; then ARCH="aarch64"; fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-$ARCH.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws

RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x86_64"; elif [ "$ARCH" = "arm64" ]; then ARCH="aarch64"; fi && \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-$ARCH.tar.gz && \
    tar -xf google-cloud-cli-linux-$ARCH.tar.gz && \
    mv google-cloud-sdk /usr/local && \
    /usr/local/google-cloud-sdk/install.sh -q \
    --usage-reporting false \
    --path-update true \
    --bash-completion true \
    --rc-path /home/vscode/.bashrc

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    az aks install-cli

COPY bin/cloud/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode