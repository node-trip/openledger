#!/bin/bash

# Цвета для красивого вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

# Функция для красивого вывода
print_header() {
    clear
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}║            OpenLedger Установщик                 ║${NC}"
    echo -e "${GREEN}║      Подготовлено командой NodeTrip             ║${NC}"
    echo -e "${GREEN}║  Подписывайтесь: https://t.me/nodetrip          ║${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
}

# Функция установки OpenLedger
install_openledger() {
    echo -e "\n${YELLOW}[+] Установка OpenLedger Node...${NC}"
    
    # Установка зависимостей
    apt update && apt upgrade -y
    apt install -y wget unzip

    # Загрузка и установка
    wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
    unzip openledger-node-1.0.0-linux.zip
    apt install -y ./openledger-node-1.0.0.deb

    echo -e "${GREEN}[✓] OpenLedger Node установлен${NC}"
    echo -e "\n${YELLOW}Для запуска используйте:${NC}"
    echo -e "${BLUE}openledger-node --no-sandbox${NC}"
}

# Функция удаления OpenLedger
remove_openledger() {
    echo -e "\n${YELLOW}[+] Удаление OpenLedger Node...${NC}"
    apt remove --purge -y openledger-node
    rm -rf /opt/OpenLedger\ Node
    rm -f /usr/bin/openledger-node
    echo -e "${GREEN}[✓] OpenLedger Node удален${NC}"
}

# Главное меню
show_menu() {
    while true; do
        print_header
        echo -e "\n${YELLOW}Выберите действие:${NC}"
        echo -e "${GREEN}1.${NC} Установить OpenLedger Node"
        echo -e "${RED}2.${NC} Удалить OpenLedger Node"
        echo -e "${GREEN}3.${NC} Выход"
        
        read -p "Выберите опцию [1-3]: " choice
        
        case $choice in
            1)
                install_openledger
                break
                ;;
            2)
                remove_openledger
                break
                ;;
            3)
                echo -e "\n${GREEN}Спасибо за использование! До свидания!${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}Неверный выбор. Попробуйте снова.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Запуск меню
show_menu 