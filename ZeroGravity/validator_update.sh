#!/bin/bash
PROJ_NAME="ZeroGravity (0,G)"

echo ''
echo -e "\e[1m\e[32m========================================================================"
echo -e "\e[1m\e[32m=== Backup $PROJ_NAME node configuration files... \e[0m" && sleep 1
echo ''

# Останавливаем сервис ноды для безопасного обновления
sudo systemctl stop ogd

# Backup your priv_validator_key.json file
cd $HOME
rm -rf $HOME/backup-update
mkdir -p $HOME/backup-update/config
mkdir -p $HOME/backup-update/keyring-test
cp -r $HOME/.0gchain/config/priv_validator_key.json $HOME/backup-update/config
cp -r $HOME/.0gchain/keyring-test/* $HOME/backup-update/keyring-test
cp -r $HOME/.0gchain/* $HOME/backup-update

echo ""
echo -e "\e[1m\e[32m========================================================================"
echo -e "\e[1m\e[32m=== Update $PROJ_NAME node... \e[0m" && sleep 1
echo ""

# Delete old release
rm -f 0gchaind-linux-v*

# Get new release
wget https://github.com/0glabs/0g-chain/releases/download/v0.5.1/0gchaind-linux-v0.5.1
sudo chmod +x ./0gchaind-linux-v0.5.1
sudo mv ./0gchaind-linux-v0.5.1 $(which 0gchaind)

#check Version
0gchaind version

#Restart node
sudo systemctl restart ogd
