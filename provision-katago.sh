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
sudo env DEBIAN_FRONTEND=noninteractive apt -o=Dpkg::Progress-Fancy=0 install -y \
    apache2-utils \
    apt-transport-https \
    build-essential \
    cmake \
    curl \
    default-jdk \
    dnsutils \
    dstat \
    git \
    icewm \
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
git clone -b v1.3.5 https://github.com/lightvector/KataGo.git
cd ~/KataGo/cpp
cmake . -DBUILD_MCTS=1 -DUSE_BACKEND=OPENCL -DUSE_TCMALLOC=1
make -j8
cp ~/KataGo/cpp/katago ~/Lizzie

# KataGo (net)
cd ~/Lizzie
wget \
    https://github.com/lightvector/KataGo/releases/download/v1.3.5-nets/g170e-b20c256x2-s3761649408-d809581368.bin.gz \
    https://github.com/lightvector/KataGo/releases/download/v1.3.5-nets/g170-b30c320x2-s2846858752-d829865719.bin.gz \
    https://github.com/lightvector/KataGo/releases/download/v1.3.5-nets/g170-b40c256x2-s2990766336-d830712531.bin.gz

# GTP settings
cp ~/KataGo/cpp/configs/gtp_example.cfg ~/Lizzie/

# Lizzie + Katago
cat > ~/Lizzie/config.txt <<EOF
{
  "leelaz": {
    "max-analyze-time-minutes": 99999,
    "analyze-update-interval-centisec": 10,
    "network-file": "lznetwork.gz",
    "_comment": "note, network-file is obselete in Lizzie 0.7+, ignore network-file, kept for compatibility",
    "max-game-thinking-time-seconds": 2,
    "engine-start-location": ".",
    "avoid-keep-variations": 30,
    "engine-command": "./katago gtp -model g170-b40c256x2-s1349368064-d524332537.bin.gz -config gtp_example.cfg",
    "print-comms": false,
    "show-lcb-winrate": false
  },
  "ui": {
    "comment-font-size": 0,
    "board-color": [
      217,
      152,
      77
    ],
    "shadow-size": 100,
    "show-winrate": true,
    "autosave-interval-seconds": -1,
    "append-winrate-to-comment": false,
    "fancy-board": true,
    "show-captured": true,
    "replay-branch-interval-seconds": 1,
    "panel-ui": false,
    "weighted-blunder-bar-height": false,
    "katago-estimate-mode": "small",
    "win-rate-always-black": false,
    "show-border": false,
    "show-move-number": false,
    "winrate-stroke-width": 3,
    "show-next-moves": true,
    "show-comment": true,
    "show-leelaz-variation": true,
    "theme": "default",
    "min-playout-ratio-for-stats": 0.1,
    "fancy-stones": true,
    "resume-previous-game": false,
    "new-move-number-in-branch": true,
    "shadows-enabled": true,
    "show-katago-boardscoremean": true,
    "show-katago-estimate-onsubboard": true,
    "show-variation-graph": true,
    "show-dynamic-komi": true,
    "gtp-console-style": "body {background:#000000; color:#d0d0d0; font-family:Consolas, Menlo, Monaco, 'Ubuntu Mono', monospace; margin:4px;} .command {color:#ffffff;font-weight:bold;} .winrate {color:#ffffff;font-weight:bold;} .coord {color:#ffffff;font-weight:bold;}",
    "katago-scoremean-alwaysblack": false,
    "katago-notshow-winrate": false,
    "minimum-blunder-bar-width": 3,
    "large-winrate": false,
    "show-blunder-bar": false,
    "only-last-move-number": 0,
    "confirm-exit": false,
    "show-status": true,
    "handicap-instead-of-winrate": false,
    "large-subboard": false,
    "dynamic-winrate-graph-width": false,
    "show-katago-estimate-onmainboard": true,
    "show-subboard": true,
    "show-katago-scoremean": true,
    "show-katago-estimate": true,
    "show-best-moves": true,
    "board-size": 19
  }
}
EOF

# Lizzie.run
cat > ~/Lizzie.run <<EOF
#!/bin/bash
cd ~/Lizzie
exec java -jar lizzie.jar
EOF
chmod 755 ~/Lizzie.run

# IceWM menu
mkdir ~/.icewm
cd ~/.icewm
cp /usr/share/icewm/menu ~/.icewm/menu
echo "prog Lizzie Lizzie /home/ubuntu/Lizzie.run" >> ~/.icewm/menu

# VNC password (default: katago)
mkdir ~/.vnc
cd ~/.vnc
uudecode <<EOF
begin 600 passwd
(OMP?ZSC,,>4`
`
end
EOF

# reboot script
echo "USER=ubuntu" > ~/crontab.ubuntu
echo "@reboot tightvncserver -depth 24 -geometry 1680x1050 > /tmp/tightvncserver.log 2>&1" >> ~/crontab.ubuntu
crontab ~/crontab.ubuntu
