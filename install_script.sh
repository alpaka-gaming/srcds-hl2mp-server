#!/bin/bash

# SWAP CONFIGURATION

sudo swapoff /swapfile
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

echo 'vm.swappiness=10' >> /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf

# PRE-INSTALLS

# SYSTEM
sudo apt update
sudo apt upgrade -y

# TOOLS
sudo apt install zip git -y

# STEAMCMD
sudo add-apt-repository multiverse
sudo apt install software-properties-common -y
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install lib32gcc-s1 -y

# STEAM USER
sudo useradd -m steam
su -ls /bin/bash steam
usermod -aG sudo steam

su -ls /bin/bash steam
cd /home/steam

echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections

sudo apt install steamcmd -y

sudo deluser steam sudo

# SCRIPTS

echo '#!/bin/bash
echo Updating HL2MP 1...
screen -S HL2MP_1 -X quit
steamcmd +force_install_dir /home/steam/steamapps/common/hl2mp +login anonymous +app_update 232370 validate +quit
' >> update.sh

echo '#!/bin/bash
echo Starting HL2MP 1...
cd /home/steam/steamapps/common/hl2mp
screen -A -m -d -S HL2MP_1 sh -c "cd /home/steam/steamapps/common/hl2mp; /home/steam/steamapps/common/hl2mp/srcds_run -game hl2mp +map dm_lockdown +maxplayers 8 +exec server.cfg"
screen -list
' >> start.sh

chmod u+x update.sh
chmod u+x start.sh
./update.sh
./start.sh