#!/bin/bash
PROJ_NAME="ZeroGravity (0,G)"
# Проверка наличия необходимых утилит, установка если отсутствуют
if ! command -v figlet &> /dev/null; then
    sudo apt update && sudo apt install -y figlet
fi

# Определяем цвета для удобства
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
MAGENTA='\033[1;35m'
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

# Вывод логотипа с помощью figlet
echo -e "${YELLOW}$(figlet -l -k -w 150 -f slant "BlockRockNodes" | while IFS= read -r line; do echo -e "${YELLOW}$line${NC}"; done)${NC}"
echo ""
sleep 1

# Останавливаем сервис ноды для безопасного обновления
sudo systemctl stop 0gd

# Переходим в домашнюю директорию пользователя
cd $HOME

# Клонируем репозиторий с исходным кодом 0g-chain с GitHub
git clone https://github.com/0glabs/0g-chain.git

# Переходим в директорию с клонированным репозиторием
cd 0g-chain

# Переключаемся на конкретный коммит (или ветку) для обновления ноды
git checkout 351c2cb

# Компилируем и устанавливаем ноду (сборка бинарного файла)
make install

# Перемещаем скомпилированный бинарный файл в системную директорию для глобального доступа
sudo mv $HOME/go/bin/0gchaind /usr/local/bin/0gchaind

# Переходим в директорию, где находится бинарник для проверки версии
cd $HOME/go/bin

# Проверяем версию установленного бинарного файла, чтобы убедиться в успешном обновлении
0gchaind version

# Перезапускаем сервис ноды, чтобы применить обновления
sudo systemctl restart 0gd
