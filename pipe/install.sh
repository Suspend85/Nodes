#!/bin/bash
PROJ_NAME="PIPE Network POP"
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

# функция установки пакетов-зависимостей
install_dependencies() {
    echo -e "${BLUE}Installing depencies (Устанавливаем необходимые пакеты)...${NC}"
    sudo apt update && sudo apt install -y iptables make gcc nano automake autoconf nvme-cli libssl-dev libleveldb-dev tar clang bsdmainutils ncdu
}

# Функция для установки ноды
install_node() {
    echo "================================================="
    echo -e "${BLUE}Installing $PROJ_NAME node (Установка ноды)...${NC}"
    echo "================================================="
    echo ""
    sleep 1
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
    
    # Проверяем, запущена ли уже сессия screen с именем pipepop
    if screen -ls | grep -q "pipepop"; then
        echo -e "${YELLOW}Сессия pipepop уже запущена. Пропускаем создание новой.${NC}"
    else
        # Создание новой сессии в screen
        screen -S pipepop -dm
    fi

    echo -e "${YELLOW}Enter your public Solana address (Введите свой Solana адрес):${NC}"
    read SOLANA_PUB_KEY
    
    # Запрос значения для RAM
    echo -e "${YELLOW}Enter the amount of RAM, in GB (Integer) (Введите объем оперативки, в GB. Целое число):${NC}"
    read RAM
    
    # Запрос значения для max-disk
    echo -e "${YELLOW}Enter the amount of max-disk, in GB (Integer) (Введите размер диска, в GB. Целое число):${NC}"
    read DISK
    
    # Запуск команды с параметрами, с указанием публичного ключа Solana, RAM и max-disk
    screen -S pipepop -X stuff "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"
    sleep 2
    # screen -S pipepop -X stuff "e4313e9d866ee3df\n"
    cd ..
    echo -e "${GREEN}The installation and launch process is complete! (Установка и запуск завершен!)${NC}"
    echo ""
}

# Функция для проверки статуса ноды
check_status() {
    echo -e "${BLUE}Checking node status (Проверка статуса ноды)...${NC}"   
    echo "Текущая директория: $(pwd)"
    # Переход в папку pipe
    if сd pipe; then
        echo "Перешли в директорию pipe."
        # Проверка наличия файла pop
        if [ -f "pop" ]; then
            ./pop --status
        else
            echo -e "${RED}Файл pop не найден в директории pipe${NC}"
        fi
        
        # Возврат в предыдущую директорию
        cd ..
    else
        echo -e "${RED}Ошибка перехода в директорию pipe${NC}"
    fi
}

# Функция для проверки поинтов ноды ./pop --points-route
check_points() {
    echo -e "${BLUE}Checking node points (Проверка поинтов ноды)...${NC}"
    echo "Текущая директория: $(pwd)"
    # Переход в папку pipe
    if сd pipe; then
        echo "Перешли в директорию pipe."
        # Проверка наличия файла pop
        if [ -f "pop" ]; then
            ./pop --points-route
        else
            echo -e "${RED}Файл pop не найден в директории pipe${NC}"
        fi
        
        # Возврат в предыдущую директорию
        cd ..
    else
        echo -e "${RED}Ошибка перехода в директорию pipe${NC}"
    fi
}

# Функция для создания реф-кода
generate_referral() {
    echo -e "${BLUE}Generating referral code (Создание реферрального кода)...${NC}"
    cd pipe
    ./pop --gen-referral-route
    cd ..
}

update_node() {
    echo -e "${BLUE}Update version to 0.2.4 (Обновление до версии 0.2.4) ...${NC}"

    # Остановка процесса pop
    echo -e "${YELLOW}Stopping service pipe-pop (Останавливаем службу pipe-pop)...${NC}"
    ps aux | grep '[p]op' | awk '{print $2}' | xargs kill

    # Переход в директорию pipe
    cd ~/pipe

    # Удаление старой версии pop
    echo -e "${YELLOW}Deleting old version of pop (Удаляем старую версию pop)...${NC}"
    rm -f pop

    # Скачивание новой версии pop
    echo -e "${YELLOW}Downloading new version of pop (Скачиваем новую версию pop)...${NC}"
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
    
    echo -e "${GREEN}Update complete! (Обновление завершено!).${NC}"
}

# Функция для удаления ноды
remove_node() {
    echo -e "${BLUE}Deleting the $PROJ_NAME node (Удаляем ноду)...${NC}"
    pkill -f pop

    # Завершаем сеанс screen с именем 'pipepop' и удаляем его
    screen -S pipepop -X quit

    # Удаление файлов ноды
    sudo rm -rf ~/pipe

    echo -e "${GREEN}The $PROJ_NAME node has been successfully removed! (Нода успешно удалена!).${NC}"
}

# Основное меню
while true; do
  echo ""
  echo -e "${YELLOW}"
  echo -e "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  echo -e "${GREEN} $PROJ_NAME - Node Menu (Меню):"
  echo -e "${YELLOW}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  echo -e "${BLUE}"
  echo "1. Install Node (Установить ноду)"
  echo "2. Check Node logs (Проверить статус ноды)"
  echo "3. Chech Node points (Проверить поинты ноды)"
  echo "4. Generate feferral code (Создать реф. код)"
  echo "5. Delete Node (Удалить ноду)"
  echo "6. Update Node (Обновить ноду)"
  echo "7. Exit (Выход)"
  echo -e "${YELLOW}"
  read -p "Choose an option (Выберите пункт): " choice
  echo -e "${NC}"
  
  case $choice in
    1) install_node ;;
    2) check_status ;;
    3) check_points ;;
    4) generate_referral ;;
    5) remove_node ;;
    6) update_node ;;
    7) break ;;
    *) echo -e "${RED}Invalid option. Try again (Некорректный выбор. Попробуйте еще).${NC}" ;;
  esac
done
