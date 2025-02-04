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
    lcov valgrind \
    libx11-dev libxrandr-dev libxcursor-dev libxi-dev libudev-dev libgl1-mesa-dev \
    libxft-dev libxext-dev \
    && rm -rf /var/lib/apt/lists/*

COPY bin/cpp/* /usr/local/bin
RUN chmod +x /usr/local/bin/*

USER vscode

RUN . <(curl https://aka.ms/vcpkg-init.sh -L)

ENV PATH=$PATH:$VCPKG_ROOT
ENV CMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake