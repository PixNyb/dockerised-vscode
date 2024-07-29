FROM pixnyb/%image% AS base

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc \
    clang \
    gdb \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/microsoft/vcpkg.git /opt/vcpkg \
    && /opt/vcpkg/bootstrap-vcpkg.sh

ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH=$PATH:/opt/vcpkg

COPY bin/cpp/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode

EXPOSE 80