#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_tool() {
    tool_name=$1
    package_name=$2

    if is_installed "$tool_name"; then
        echo -e "${GREEN}$tool_name est déjà installé.${NC}"
    else
        echo -e "${YELLOW}Installation de $tool_name...${NC}"
        sudo apt-get install -y "$package_name"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$tool_name a été installé avec succès.${NC}"
        else
            echo -e "${RED}Échec de l'installation de $tool_name.${NC}"
        fi
    fi
}

echo -e "${YELLOW}Mise à jour des paquets...${NC}"
sudo apt-get update

install_tool "nmap" "nmap"

install_tool "masscan" "masscan"

install_tool "nikto" "nikto"

install_tool "netdiscover" "netdiscover"

echo -e "${GREEN}Tous les outils nécessaires ont été installés.${NC}"

