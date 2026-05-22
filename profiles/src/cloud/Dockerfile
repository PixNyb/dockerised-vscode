FROM pixnyb/%image% AS base

USER root

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh

RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-$(dpkg --print-architecture) && \
    install minikube-linux-$(dpkg --print-architecture) /usr/local/bin/minikube && \
    rm minikube-linux-$(dpkg --print-architecture)

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

ENV GOROOT=/home/vscode/.local/go
ENV GOPATH=/home/vscode/go
ENV PATH=$PATH:/home/vscode/.local/go/bin:$GOPATH/bin

RUN mkdir -p ${GOROOT} && \
    mkdir -p ${GOPATH}/{bin,pkg,src}

RUN curl -L https://go.dev/dl/$(curl -s https://go.dev/VERSION?m=text | head -n 1).linux-$(dpkg --print-architecture).tar.gz -o go.tar.gz && \
    tar -xf go.tar.gz -C ${GOROOT} --strip-components=1 && \
    rm go.tar.gz && \
    chown -R vscode:vscode ${GOROOT} ${GOPATH}

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

RUN go install sigs.k8s.io/kind@latest
