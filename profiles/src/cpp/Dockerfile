FROM pixnyb/%image% AS base

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc \
    clang \
    clang-format \
    gdb \
    pkg-config \
    libtool \
    autoconf \
    automake \
    libx11-dev libxrandr-dev libxcursor-dev libxi-dev libudev-dev libgl1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

COPY bin/cpp/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode

ENV VCPKG_ROOT=/home/vscode/.vcpkg-repo
ENV PATH=$PATH:$VCPKG_ROOT
ENV CMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake

RUN git clone https://github.com/microsoft/vcpkg.git $VCPKG_ROOT \
    && $VCPKG_ROOT/bootstrap-vcpkg.sh