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

# Функция установки OpenLedger и VNC
install_openledger() {
    echo -e "\n${YELLOW}[+] Установка OpenLedger Node и VNC...${NC}"
    
    # Получаем IP адрес сервера
    SERVER_IP=$(curl -s ifconfig.me)
    
    # Установка зависимостей
    apt update && apt upgrade -y
    apt install -y wget unzip tightvncserver xfce4 xfce4-goodies dbus-x11 x11-xserver-utils

    # Загрузка и установка OpenLedger
    wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
    unzip openledger-node-1.0.0-linux.zip
    apt install -y ./openledger-node-1.0.0.deb

    # Настройка VNC
    mkdir -p ~/.vnc
    
    # Создаем улучшенный xstartup
    cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_SESSION_DESKTOP="xfce"

# Запуск autocutsel для синхронизации буферов обмена
autocutsel -fork
autocutsel -selection PRIMARY -fork

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

/usr/bin/startxfce4
EOF
    chmod +x ~/.vnc/xstartup

    # Настройка буфера обмена
    cat > ~/.vnc/config << 'EOF'
ClipboardRecv=1
ClipboardSend=1
EOF

    # Генерация пароля для VNC
    VNC_PASS=$(openssl rand -base64 8)
    echo $VNC_PASS | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    # Сохраняем пароль в читаемом виде
    echo $VNC_PASS > ~/.vnc/passwd.txt
    chmod 600 ~/.vnc/passwd.txt

    # Сначала убиваем все существующие сессии VNC
    vncserver -kill :1 >/dev/null 2>&1 || true
    
    # Очищаем старые файлы блокировки если они есть
    rm -rf /tmp/.X1-lock
    rm -rf /tmp/.X11-unix/X1
    
    # Запускаем TigerVNC с явными параметрами для буфера обмена
    vncserver :1 \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost no \
    -SecurityTypes VncAuth \
    -SelectionOwner \
    -AcceptClipboard=true \
    -SendClipboard=true \
    -AcceptCutText=true \
    -SendCutText=true \
    -AcceptPointerEvents=true \
    -AcceptKeyEvents=true \
    -RemoteResize=true

    # Открытие порта в файрволе
    ufw allow 5901/tcp

    echo -e "${GREEN}[✓] OpenLedger Node и VNC установлены${NC}"
    echo -e "\n${YELLOW}Для подключения используйте VNC Viewer:${NC}"
    echo -e "Адрес: ${GREEN}${SERVER_IP}:5901${NC}"
    echo -e "Пароль: ${GREEN}$VNC_PASS${NC}"
    echo -e "\n${YELLOW}Для запуска OpenLedger используйте:${NC}"
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

# Функция перезапуска VNC
restart_vnc() {
    echo -e "\n${YELLOW}[+] Перезапуск VNC сервера...${NC}"
    
    # Убиваем текущую сессию
    vncserver -kill :1 >/dev/null 2>&1 || true
    
    # Полная очистка VNC
    rm -rf ~/.vnc/*
    rm -rf /tmp/.X1-lock
    rm -rf /tmp/.X11-unix/X1
    
    # Создаем конфиг заново
    mkdir -p ~/.vnc
    
    # Создаем улучшенный xstartup
    cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_SESSION_DESKTOP="xfce"

# Запуск autocutsel для синхронизации буферов обмена
autocutsel -fork
autocutsel -selection PRIMARY -fork

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

/usr/bin/startxfce4
EOF
    chmod +x ~/.vnc/xstartup

    # Настройка буфера обмена
    cat > ~/.vnc/config << 'EOF'
ClipboardRecv=1
ClipboardSend=1
EOF
    
    # Генерируем новый пароль
    VNC_PASS=$(openssl rand -base64 8)
    echo $VNC_PASS | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    
    # Запускаем заново
    vncserver :1 -geometry 1920x1080 -depth 24
    
    # Получаем IP адрес сервера
    SERVER_IP=$(curl -s ifconfig.me)
    
    echo -e "${GREEN}[✓] VNC сервер перезапущен${NC}"
    echo -e "\n${YELLOW}Для подключения используйте:${NC}"
    echo -e "Адрес: ${GREEN}${SERVER_IP}:5901${NC}"
    echo -e "Пароль: ${GREEN}${VNC_PASS}${NC}"
}

# Главное меню
show_menu() {
    while true; do
        print_header
        echo -e "\n${YELLOW}Выберите действие:${NC}"
        echo -e "${GREEN}1.${NC} Установить OpenLedger Node и VNC"
        echo -e "${RED}2.${NC} Удалить OpenLedger Node"
        echo -e "${BLUE}3.${NC} Перезапустить VNC сервер"
        echo -e "${GREEN}4.${NC} Выход"
        
        read -p "Выберите опцию [1-4]: " choice
        
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
                restart_vnc
                break
                ;;
            4)
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
