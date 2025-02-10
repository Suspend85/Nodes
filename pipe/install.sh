#!/bin/bash
# Проверка наличия необходимых утилит, установка если отсутствуют
if ! command -v figlet &> /dev/null; then
    # echo "figlet не найден. Устанавливаем..."
    sudo apt update && sudo apt install -y figlet
fi

if ! command -v whiptail &> /dev/null; then
    # echo "whiptail не найден. Устанавливаем..."
    sudo apt update && sudo apt install -y whiptail
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

install_dependencies() {
    echo -e "${GREEN}Устанавливаем необходимые пакеты...${NC}"
    sudo apt update && sudo apt install -y iptables make gcc nano automake autoconf nvme-cli libssl-dev libleveldb-dev tar clang bsdmainutils ncdu
}

# Вывод логотипа с помощью figlet
echo -e "${YELLOW}$(figlet -l -k -w 150 -f slant "BlockRockNodes" | while IFS= read -r line; do echo -e "${YELLOW}$line${NC}"; done)${NC}"

# echo "========================================"
# echo "Начинаем установку необходимых библиотек"
# echo "========================================"

echo ""

# # Определение функции анимации
# animate_loading() {
#     for ((i = 1; i <= 5; i++)); do
#         printf "\r${GREEN}Загрузка меню${NC}."
#         sleep 0.3
#         printf "\r${GREEN}Загрузка меню${NC}.."
#         sleep 0.3
#         printf "\r${GREEN}Загрузка меню${NC}..."
#         sleep 0.3
#         printf "\r${GREEN}Загрузка меню${NC}"
#         sleep 0.3
#     done
#     echo ""
# }

# # Вызов функции анимации
# animate_loading
# echo ""

# Функция для установки ноды
install_node() {
    echo -e "${BLUE}Начинаем установку ноды...${NC}"
    
    # Обновление и установка зависимостей
    source <(wget -O- 'https://raw.githubusercontent.com/Suspend85/Nodes/refs/heads/master/_utils/serv-prepare.sh')
    install_dependencies

    # Создание директории для кэша и переход в неё
    mkdir -p ~/pipe/download_cache
    cd ~/pipe

    # Скачиваем файл pop
    wget https://dl.pipecdn.app/v0.2.4/pop

    # Делаем файл исполнимым
    chmod +x pop

    # Создание новой сессии в screen
    screen -S pipepop -dm

    echo -e "${YELLOW}Введите ваш публичный адрес Solana:${NC}"
    read SOLANA_PUB_KEY
    
    # Запрос значения для RAM
    echo -e "${YELLOW}Введите количество RAM в ГБ (целое число):${NC}"
    read RAM
    
    # Запрос значения для max-disk
    echo -e "${YELLOW}Введите количество max-disk в ГБ (целое число):${NC}"
    read DISK
    
    # Запуск команды с параметрами, с указанием публичного ключа Solana, RAM и max-disk
    screen -S pipepop -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"
    sleep 2
    # screen -S pipepop -X stuff "e4313e9d866ee3df\n"
    echo -e "${GREEN}Процесс установки и запуска завершён!${NC}"
}

# Функция для проверки статуса ноды
check_status() {
    echo -e "${BLUE}Проверка статуса ноды...${NC}"   
    cd pipe
    ./pop --status
    cd ..
}

# Функция для проверки поинтов ноды
check_points() {
    echo -e "${BLUE}Проверка поинтов ноды...${NC}"
    cd pipe
    ./pop --points-route
    cd ..
}

# Функция для создания реф-кода
generate_referral() {
    echo -e "${BLUE}Генерация реферрального кода...${NC}"
    cd pipe
    ./pop --gen-referral-route
    cd ..
}

# Зарегистрироваться по реф-коду
# signup_by_referral() {
#     echo -e "${BLUE}Регистрация по реферральному коду...${NC}"
#     ./pop --signup-by-referral-route <CODE>
# }

update_node() {
    echo -e "${BLUE}Обновление до версии 0.2.4...${NC}"

    # Остановка процесса pop
    echo -e "${YELLOW}Останавливаем службу pipe-pop...${NC}"
    ps aux | grep '[p]op' | awk '{print $2}' | xargs kill

    # Переход в директорию pipe
    cd ~/pipe

    # Удаление старой версии pop
    echo -e "${YELLOW}Удаляем старую версию pop...${NC}"
    rm -f pop

    # Скачивание новой версии pop
    echo -e "${YELLOW}Скачиваем новую версию pop...${NC}"
    wget -O pop "https://dl.pipecdn.app/v0.2.4/pop"

    # Делаем файл исполнимым
    chmod +x pop

    # Перезагрузка системных служб
    sudo systemctl daemon-reload
    # Завершаем сессию screen с именем 'pipepop', если она существует
    if screen -list | grep -q "pipepop"; then
    screen -S pipepop -X quit
    fi
    sleep 2
    
    # Перезапуск сессии screen с именем 'pipepop' и запуск pop
    screen -S pipepop -dm ./pop
    
    sleep 5
    screen -S pipepop -X stuff "y\n"
    
    echo -e "${GREEN}Обновление завершено!${NC}"
}

# Функция для удаления ноды
remove_node() {
    echo -e "${BLUE}Удаляем ноду...${NC}"
    pkill -f pop

    # Завершаем сеанс screen с именем 'pipepop' и удаляем его
    screen -S pipepop -X quit

    # Удаление файлов ноды
    sudo rm -rf ~/pipe

    echo -e "${GREEN}Нода успешно удалена!${NC}"
}

# Основное меню
CHOICE=$(whiptail --title "Меню действий" \
    --menu "Выберите действие:" 18 50 7 \
    "1" "Установка ноды" \
    "2" "Проверка статуса ноды" \
    "3" "Проверка поинтов ноды" \
    "4" "Создание реф-кода" \
    "5" "Удаление ноды" \
    "6" "Обновление ноды" \
    "7" "Выход" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    1) install_node ;;
    2) check_status ;;
    3) check_points ;;
    4) generate_referral ;;
    5) remove_node ;;
    6) update_node ;;
    7) echo -e "${CYAN}Выход из программы.${NC}" ;;
    *) echo -e "${RED}Неверный выбор. Завершение программы.${NC}" ;;
esac
