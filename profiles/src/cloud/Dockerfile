FROM pixnyb/%image% AS base

USER root

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    install minikube-linux-amd64 /usr/local/bin/minikube && \
    rm minikube-linux-amd64

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

ENV GOPATH=/go
ENV PATH=$PATH:/go/bin

RUN mkdir -p /go/bin && \
    mkdir -p /go/src && \
    mkdir -p /go/pkg && \
    chmod -R 777 /go

RUN apt update && apt install -y golang-go && \
    go install sigs.k8s.io/kind@v0.24.0

COPY bin/cloud/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode