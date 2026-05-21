FROM pixnyb/%image% AS base

USER root

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-$(dpkg --print-architecture) && \
    install minikube-linux-$(dpkg --print-architecture) /usr/local/bin/minikube && \
    rm minikube-linux-$(dpkg --print-architecture)

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

ENV GOPATH=/home/vscode/.local/go
ENV PATH=$PATH:/home/vscode/.local/go/bin

RUN mkdir -p /home/vscode/.local/go/bin && \
    mkdir -p /home/vscode/.local/go/src && \
    mkdir -p /home/vscode/.local/go/pkg

RUN curl -L https://go.dev/dl/$(curl -s https://go.dev/VERSION?m=text | head -n 1).linux-$(dpkg --print-architecture).tar.gz -o go.tar.gz && \
    tar -xf go.tar.gz -C ${GOPATH} --strip-components=1 && \
    rm go.tar.gz && \
    go install sigs.k8s.io/kind@latest

RUN chmod -R 775 /home/vscode/.local/go && \
    chown -R vscode:vscode /home/vscode/.local/go

RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x86_64"; elif [ "$ARCH" = "arm64" ]; then ARCH="aarch64"; fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-$ARCH.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws awscliv2.zip

RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH="x86_64"; elif [ "$ARCH" = "arm64" ]; then ARCH="arm"; fi && \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-$ARCH.tar.gz && \
    tar -xf google-cloud-cli-linux-$ARCH.tar.gz && \
    mv google-cloud-sdk /usr/local && \
    /usr/local/google-cloud-sdk/install.sh -q \
    --usage-reporting false \
    --path-update true \
    --bash-completion true \
    --rc-path /home/vscode/.bashrc && \
    rm google-cloud-cli-linux-$ARCH.tar.gz

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    az aks install-cli

COPY bin/cloud/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode
