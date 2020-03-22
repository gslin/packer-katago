#!/bin/bash

sudo fallocate -l 512M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo -e "net.core.default_qdisc=fq\nnet.ipv4.tcp_congestion_control=bbr" | sudo tee /etc/sysctl.d/99-tcp.conf
sudo sysctl -p /etc/sysctl.d/99-tcp.conf

sudo apt update
sudo env DEBIAN_FRONTEND=noninteractive apt -y upgrade
sudo apt install -y \
     \
     \
     \
    apache2-utils \
    apt-transport-https \
    build-essential \
    cmake \
    curl \
    default-jdk \
    dnsutils \
    dstat \
    git \
    jq \
    libboost-filesystem-dev \
    libgoogle-perftools-dev \
    libzip-dev \
    locales \
    moreutils \
    most \
    mtr-tiny \
    net-tools \
    nvidia-compute-utils-435 \
    nvidia-driver-435 \
    nvidia-headless-435 \
    nvidia-utils-435 \
    ocl-icd-opencl-dev \
    p7zip-full \
    pigz \
    rsync \
    sharutils \
    software-properties-common \
    sysstat \
    tightvncserver \
    unrar \
    unzip \
    vim-nox \
    wget \
    zsh \
    zsh-syntax-highlighting \
    zstd \
    zlib1g-dev
sudo apt clean

# Lizzie
cd /tmp
wget https://github.com/featurecat/lizzie/releases/download/0.7.2/Lizzie.0.7.2.Mac-Linux.zip
cd ~
unzip /tmp/Lizzie.0.7.2.Mac-Linux.zip

# KataGo (software)
cd ~
git clone https://github.com/lightvector/KataGo.git
cd ~/KataGo/cpp
cmake . -DBUILD_MCTS=1 -DUSE_BACKEND=OPENCL -DUSE_TCMALLOC=1
make -j4
cp ~/KataGo/cpp/katago ~/Lizzie

# KataGo (net)
cd ~/Lizzie
wget \
    https://github.com/lightvector/KataGo/releases/download/v1.3.3/g170e-b20c256x2-s2430231552-d525879064.bin.gz \
    https://github.com/lightvector/KataGo/releases/download/v1.3.3/g170-b30c320x2-s1287828224-d525929064.bin.gz \
    https://github.com/lightvector/KataGo/releases/download/v1.3.3/g170-b40c256x2-s1349368064-d524332537.bin.gz
