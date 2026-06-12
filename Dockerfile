FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_UNSAFE_CONFIGURE=1
ENV HOME=/root

RUN apt-get update && apt-get install -y \
    build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git \
    libncurses-dev libssl-dev python3-distutils \
    python3-setuptools rsync swig unzip zlib1g-dev \
    file wget curl ccache iputils-ping \
    python3 python3-pip nano vim \
    cmake ninja-build fakeroot && \
    rm -rf /var/lib/apt/lists/*

RUN printf '#!/bin/sh\nexec "$@"\n' > /usr/bin/fakeroot && \
    chmod +x /usr/bin/fakeroot && \
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/faked && \
    chmod +x /usr/bin/faked

WORKDIR /build
