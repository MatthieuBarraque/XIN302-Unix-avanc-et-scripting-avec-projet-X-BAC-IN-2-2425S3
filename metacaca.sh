#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

lines=(
    "==================================================================== "
    "|                                                  __\\|,-          | "
    "|                                                 ,-=\`=--.         | "
    "|                                                   /=8\\           | "
    "|       _~               META-CACA                   =             |"
    "|   _~ )_)_~                                         = IP          |"
    "|   )_))_))_)      ---------------------             =             | "
    "|   _!__!__!_      D3sir3 - UNIX - Shell        NMAP =             | "
    "|   \\______t/      ---------------------   ~..:::::::::::::..~~    | "
    "==~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~== "
)

delay=0.02

clear

print_column_by_column() {
    local max_columns=${#lines[0]} 
    local total_lines=${#lines[@]}

    for ((i=0; i<max_columns; i++)); do
        for ((j=0; j<total_lines; j++)); do
            tput cup $j $i
            echo -ne "${lines[j]:i:1}"
        done
        sleep $delay
    done
    echo ""
}

return_to_menu() {
    echo ""
    echo -e "${YELLOW}Scan terminé. Redirection vers le menu principal dans 5 secondes...${NC}"
    sleep 5
    clear
    main_menu
}

validate_ip() {
    local ip="$1"
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]; then
        IFS='/' read -r base_ip mask <<< "$ip"
        IFS='.' read -r -a octets <<< "$base_ip"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

list_ips_and_mac() {
    local ip_range="192.168.0.0/24"

    echo -e "${BLUE}Utilisation de netdiscover pour lister les IP et adresses MAC...${NC}"
    if ! command -v netdiscover &> /dev/null; then
        echo -e "${RED}Erreur : netdiscover n'est pas installé. Veuillez l'installer et réessayer.${NC}"
        return_to_menu
        return
    fi

    sudo netdiscover -r $ip_range -P > netdiscover_output.txt
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Scan netdiscover terminé.${NC}"
        parse_ips_and_hosts
    else
        echo -e "${RED}Erreur lors de l'exécution de netdiscover.${NC}"
        return_to_menu
    fi
}

parse_ips_and_hosts() {
    echo -e "${YELLOW}IP et noms d'hôte détectés sur le réseau :${NC}"
    grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' netdiscover_output.txt | while read -r line; do
        ip=$(echo "$line" | awk '{print $1}')
        mac=$(echo "$line" | awk '{print $2}')
        vendor=$(echo "$line" | awk '{print $5,$6,$7,$8}')
        if validate_ip "$ip"; then
            echo -e "${GREEN}IP: $ip | MAC: $mac | Nom: $vendor${NC}"
        fi
    done
}

nmap_scan_options() {
    echo -e "${YELLOW}Sélectionnez le type de scan Nmap que vous souhaitez effectuer :${NC}"
    echo "1) Scan rapide (scan SYN)"
    echo "2) Scan complet (tous les ports TCP/UDP)"
    echo "3) Scan OS et services (détection de version, OS)"
    echo "4) Scan de vulnérabilité (recherche de vulnérabilités connues)"
    echo "5) Scan personnalisé (définir les ports et options)"
    echo "6) Scan UDP (détection des services UDP)"
    echo "7) Scan de fragmentation (pour contourner les firewalls)"
}

scan_with_nmap() {
    echo -e "${YELLOW}Affichage des IPs sur le réseau avec les noms associés...${NC}"
    parse_ips_and_hosts

    echo -e "${YELLOW}Voulez-vous scanner toutes ces IPs avec Nmap ? (y/n)${NC}"
    read -p "metacaca > " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        ips=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' netdiscover_output.txt | sort -u)
        nmap_scan_options
        read -p "metacaca > " scan_type

        for ip in $ips; do
            if validate_ip "$ip"; then
                case $scan_type in
                    1)
                        echo -e "${BLUE}Scan SYN rapide de l'IP : $ip${NC}"
                        sudo nmap -sS -T4 "$ip"
                        ;;
                    2)
                        echo -e "${BLUE}Scan complet de l'IP : $ip${NC}"
                        sudo nmap -p- -T4 "$ip"
                        ;;
                    3)
                        echo -e "${BLUE}Scan OS et services de l'IP : $ip${NC}"
                        sudo nmap -A -T4 "$ip"
                        ;;
                    4)
                        echo -e "${BLUE}Scan de vulnérabilité de l'IP : $ip${NC}"
                        sudo nmap --script vuln -T4 "$ip"
                        ;;
                    5)
                        echo -e "${YELLOW}Entrez les ports à scanner (ex: 80,443 ou 1-1000) :${NC}"
                        read -p "metacaca > " custom_ports
                        echo -e "${BLUE}Scan personnalisé de l'IP : $ip sur les ports $custom_ports${NC}"
                        sudo nmap -p "$custom_ports" -T4 "$ip"
                        ;;
                    6)
                        echo -e "${BLUE}Scan UDP de l'IP : $ip${NC}"
                        sudo nmap -sU -T4 "$ip"
                        ;;
                    7)
                        echo -e "${BLUE}Scan de fragmentation de l'IP : $ip${NC}"
                        sudo nmap -f -T4 "$ip"
                        ;;
                    *)
                        echo -e "${RED}Option de scan invalide.${NC}"
                        ;;
                esac

                if [ $? -ne 0 ]; then
                    echo -e "${RED}Erreur lors du scan Nmap de l'IP $ip.${NC}"
                else
                    echo -e "${GREEN}Scan Nmap terminé pour l'IP $ip.${NC}"
                fi
            else
                echo -e "${RED}IP invalide ignorée : $ip${NC}"
            fi
        done
    else
        echo -e "${RED}Scan annulé.${NC}"
        return_to_menu
    fi
}

scan_with_masscan() {
    echo -e "${YELLOW}Entrez l'adresse IP ou la plage d'IP à scanner avec Masscan :${NC}"
    read -p "metacaca > " ip_target
    if validate_ip "$ip_target"; then
        echo -e "${BLUE}Scan Masscan en cours sur l'IP : $ip_target${NC}"
        sudo masscan "$ip_target" --ports 1-65535 --rate 1000
        if [ $? -ne 0 ]; then
            echo -e "${RED}Erreur lors du scan Masscan de l'IP $ip_target.${NC}"
        else
            echo -e "${GREEN}Scan Masscan terminé pour l'IP $ip_target.${NC}"
        fi
    else
        echo -e "${RED}Adresse IP ou plage invalide.${NC}"
    fi
    return_to_menu
}

scan_with_nikto() {
    read -p "Entrez l'adresse du site web à scanner avec Nikto (ex: http://example.com) > " website_target
    echo -e "${BLUE}Scan Nikto en cours sur : $website_target${NC}"
    if ! sudo nikto -h "$website_target"; then
        echo -e "${RED}Erreur lors de l'exécution de Nikto.${NC}"
    else
        echo -e "${GREEN}Scan Nikto terminé pour $website_target.${NC}"
    fi
    return_to_menu
}

main_menu() {
    while true; do
        echo -e "${BLUE}============================"
        echo "      MENU PRINCIPAL        "
        echo "============================"
        echo -e "${GREEN}1) Lister les IP et MAC (netdiscover)"
        echo "2) Scanner des IP avec Nmap"
        echo "3) Scanner avec Masscan (rapide)"
        echo "4) Scanner des vulnérabilités web (Nikto)"
        echo "5) Automatiser un scan avec cron"
        echo "6) Quitter"
        read -p "metacaca > " choice

        case $choice in
            1)
                list_ips_and_mac
                ;;
            2)
                scan_with_nmap
                ;;
            3)
                scan_with_masscan
                ;;
            4)
                scan_with_nikto
                ;;
            5)
                schedule_scan
                ;;
            6)
                echo -e "${BLUE}Au revoir!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Option invalide, réessayez.${NC}"
                ;;
        esac
    done
}

print_column_by_column
main_menu