#!/usr/bin/env bash
# =============================================================================
#   Boite a Scripts Linux - By ALEEXLEDEV  v1.0
# =============================================================================

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
C=$'\033[36m' W=$'\033[97m' DG=$'\033[90m'
G=$'\033[32m' R=$'\033[31m' Y=$'\033[33m' N=$'\033[0m'
BG_SEL=$'\033[46;30m' # Fond cyan, texte noir pour la sélection

# Elevation Sudo
if [[ $EUID -ne 0 ]]; then
    clear
    echo "[ ! ] Elevation des privileges requise..."
    exec sudo bash "$SCRIPT_PATH" "$@"
fi

# Logo
print_logo() {
    printf "${C}%s${N}\n" \
        "  ▄▄▄▄▄▄▄ ▄▄       ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄    ▄▄       ▄▄▄▄▄▄▄    ▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ " \
        " █       █  █     █       █       █  █ █  █  █  █     █       █  █      ██       █  █ █  █" \
        " █   ▄   █  █     █    ▄▄▄█    ▄▄▄█  █▄█  █  █  █     █    ▄▄▄█  █  ▄    █    ▄▄▄█  █▄█  █" \
        " █  █▄█  █  █     █   █▄▄▄█   █▄▄▄█       █  █  █     █   █▄▄▄   █ █ █   █   █▄▄▄█       █" \
        " █       █  █▄▄▄▄▄█    ▄▄▄█    ▄▄▄█       █  █  █▄▄▄▄▄█    ▄▄▄█  █ █▄█   █    ▄▄▄█       █" \
        " █   ▄   █       █   █▄▄▄█   █▄▄▄█   ▄   █  █       █   █▄▄▄   █       █   █▄▄▄█   ▄   █" \
        " █▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█  █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█  █▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█" \
        ""
}

# --- FONCTIONS SYSTÈME ---

check_and_install() {
    local cmd=$1
    local pkg=$2
    if ! command -v "$cmd" &> /dev/null; then
        printf "${Y}   [!] Outil '%s' manquant. Installation de '%s'...${N}\n" "$cmd" "$pkg"
        apt update -y &>/dev/null
        apt install -y "$pkg" &>/dev/null
        if [[ $? -eq 0 ]]; then
            printf "${G}   [✓] %s installé.${N}\n" "$pkg"
            return 0
        else
            printf "${R}   [✗] Erreur installation %s. Vérifiez votre connexion.${N}\n" "$pkg"
            return 1
        fi
    fi
    return 0
}

sys_fastview() {
    clear
    print_logo
    printf "${C}  [ VUE RAPIDE - ANALYSE MATÉRIELLE ]${N}\n\n"
    
    # --- 1. SYSTÈME & CPU ---
    local os_name=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    local kernel=$(uname -sr)
    local uptime_val=$(uptime -p | sed 's/up //')
    local cpu_model=$(lscpu | grep "Model name" | sed 's/Model name: *//' | xargs)

    # --- 2. RAM (Soudée, Slots vides, Max supporté) ---
    local ram_total=$(free -h | awk '/^Mem:/ {print $2}')
    local ram_slots_info=""
    local ram_max_cap="Inconnue"
    
    if check_and_install "dmidecode" "dmidecode"; then
        # Capacité max de la carte mère
        ram_max_cap=$(sudo dmidecode -t memory | grep "Maximum Capacity" | awk '{print $3 " " $4}')
        
        # Analyse des slots
        local total_slots=$(sudo dmidecode -t memory | grep -c "Size: [0-9]\|No Module Installed")
        local occupied_slots=$(sudo dmidecode -t memory | grep -c "Size: [0-9] [MG]B")
        local empty_slots=$((total_slots - occupied_slots))
        local ram_type=$(sudo dmidecode -t memory | grep -m1 "Type:" | awk '{print $2}')
        
        # Détection soudure
        if sudo dmidecode -t memory | grep -qi "Row of Chips"; then
            ram_slots_info="${R}Mémoire Soudée${N}"
        else
            ram_slots_info="${G}${occupied_slots}/${total_slots} slots occupés${N}"
        fi
        
        [[ $empty_slots -gt 0 ]] && ram_slots_info="${ram_slots_info} ${Y}(! $empty_slots slot(s) disponible(s))${N}"
    fi

    # --- 3. DISQUES (SSD vs HDD, Santé & Modèle) ---
    local disk_list=""
    # On récupère tous les disques physiques (sdX, nvmeX)
    local physical_disks=$(lsblk -d -n -o NAME,TYPE | grep "disk" | awk '{print $1}')
    
    for d in $physical_disks; do
        local model=$(lsblk -d -n -o MODEL "/dev/$d" | xargs)
        local size=$(lsblk -d -n -o SIZE "/dev/$d" | xargs)
        # Détection SSD (1 = HDD, 0 = SSD)
        local rota=$(cat /sys/block/$d/queue/rotational)
        local type_disk="${G}SSD${N}"
        [[ "$rota" == "1" ]] && type_disk="${Y}HDD${N}"
        # Si NVMe, c'est forcément SSD
        [[ "$d" =~ "nvme" ]] && type_disk="${G}NVMe SSD${N}"
        
        disk_list="${disk_list}   • /dev/$d : ${W}$model${N} (${size}) [${type_disk}]\n"
    done

    # --- 4. RÉSEAU & GPU ---
    local gpu_info=$(lspci | grep -iE 'vga|3d|display' | cut -d: -f3 | xargs)
    local ip_loc=$(hostname -I | awk '{print $1}')

    # --- AFFICHAGE FINAL ---
    printf "${W}   --- 🖥️  SYSTÈME & CPU ---${N}\n"
    printf "   • OS       : ${G}%s${N}\n" "$os_name"
    printf "   • Kernel   : ${G}%s${N}\n" "$kernel"
    printf "   • CPU      : ${G}%s${N}\n" "$cpu_model"
    printf "   • IP Loc   : ${C}%s${N}\n\n" "$ip_loc"

    printf "${W}   --- 🧠 MÉMOIRE RAM ---${N}\n"
    printf "   • Total    : ${G}%s${N} (Type: ${W}%s${N})\n" "$ram_total" "$ram_type"
    printf "   • Slots    : %b\n" "$ram_slots_info"
    printf "   • Max Mobo : ${W}%s${N}\n\n" "$ram_max_cap"

    printf "${W}   --- 💾 DISQUES PHYSIQUES ---${N}\n"
    printf "%b\n" "$disk_list"

    printf "${W}   --- 🎨 CARTE GRAPHIQUE ---${N}\n"
    printf "   • GPU      : ${C}%s${N}\n\n" "$gpu_info"
    
    printf "${C}  ----------------------------------------------------------------------------------------${N}\n"
    printf "${G}   [ RESULTAT : ANALYSE TERMINÉE AVEC SUCCÈS ]${N}\n\n"
    read -p "   Pressez [ENTRÉE] pour revenir..."
}

sys_monitor() {
    check_and_install "btop" "btop" || check_and_install "htop" "htop"
    
    if command -v btop &> /dev/null; then
        btop
    elif command -v htop &> /dev/null; then
        htop
    else
        top
    fi

    # 2. Une fois que l'utilisateur a pressé 'q' ou 'F10' pour quitter l'outil
    printf "\n${Y}   [i] Monitoring terminé.${N}\n"
    printf "${C}   >> Pressez [ENTRÉE] pour revenir au menu principal...${N}"
    
    # On vide le buffer d'entrée pour éviter que des touches pressées dans btop 
    # ne valident la pause automatiquement
    read -r
}

hw_disk_health() {
    clear
    print_logo
    printf "${C}  [ SANTÉ DISQUE - ANALYSE SMART ]${N}\n\n"
    
    check_and_install "smartctl" "smartmontools"
    
    if ! command -v smartctl &> /dev/null; then
        printf "${R}   [!] Erreur : 'smartmontools' est indispensable.${N}\n"
    else
        local physical_disks=$(lsblk -d -n -o NAME,TYPE | grep "disk" | awk '{print $1}')
        local global_status="OK"
        for d in $physical_disks; do
            printf "${W}   • /dev/$d :${N} "
            local health=$(sudo smartctl -H "/dev/$d" 2>/dev/null | grep "test result" | awk -F': ' '{print $2}')
            if [[ "$health" == "PASSED" ]]; then
                printf "${G}OK (PASSED)${N}\n"
            else
                printf "${R}ATTENTION / ERREUR${N}\n"
                global_status="BAD"
            fi
            
            # Détails importants
            if [[ "$d" =~ "nvme" ]]; then
                sudo smartctl -A "/dev/$d" 2>/dev/null | grep -iE "Percentage Used|Critical Warning|Power On Hours" | awk -F': ' '{printf "     - %-25s : %s\n", $1, $2}'
            else
                sudo smartctl -A "/dev/$d" 2>/dev/null | grep -iE "Reallocated_Sector_Ct|Power_On_Hours|Wear_Leveling_Count" | awk '{printf "     - %-25s : %s\n", $2, $10}'
            fi
            echo ""
        done

        if [[ "$global_status" == "OK" ]]; then
            printf "${G}   [ RESULTAT : TOUT EST OK - DISQUES EN BONNE SANTÉ ]${N}\n\n"
        else
            printf "${R}   [ RESULTAT : ATTENTION - DES ERREURS ONT ÉTÉ DÉTECTÉES ]${N}\n\n"
        fi
    fi
    read -p "   Pressez [ENTRÉE] pour revenir..."
}

hw_thermal_live() {
    clear
    print_logo
    printf "${C}  [ TEMPÉRATURES TEMPS RÉEL ]${N}\n\n"
    
    check_and_install "sensors" "lm-sensors"
    
    if ! command -v sensors &> /dev/null; then
        printf "${R}   [!] Erreur : 'lm-sensors' indispensable.${N}\n"
    else
        local temp_out=$(sensors)
        echo "$temp_out" | grep -v "Adapter" | sed 's/^/   /'
        
        # Détection intelligente :
        # 1. On cherche les alarmes réelles (mot ALARM ou crit sans le signe "=")
        local alarm=$(echo "$temp_out" | grep -Ei "ALARM" | grep -v "crit =")
        # 2. On vérifie si une température dépasse 85°C (souvent le cas en charge, mais à surveiller)
        local high=$(echo "$temp_out" | awk '/°C/ {gsub(/[+°C]/,"",$2); if($2 > 85) print $2}')

        if [[ -n "$alarm" ]]; then
            printf "\n${R}   [ RESULTAT : ALERTE - SURCHAUFFE MATÉRIELLE (ALARM) ]${N}\n"
        elif [[ -n "$high" ]]; then
            printf "\n${Y}   [ RESULTAT : ATTENTION - TEMPÉRATURE ÉLEVÉE (>85°C) ]${N}\n"
            printf "     Certains composants chauffent beaucoup. Vérifiez la ventilation.\n"
        else
            printf "\n${G}   [ RESULTAT : TEMPÉRATURES STABLES ]${N}\n"
        fi
    fi
    printf "\n"
    read -p "   Pressez [ENTRÉE] pour revenir..."
}

hw_power_stat() {
    clear
    print_logo
    printf "${C}  [ STATISTIQUES ÉNERGIE & BATTERIE ]${N}\n\n"
    
    check_and_install "upower" "upower"
    
    if ! command -v upower &> /dev/null; then
        printf "${R}   [!] Erreur : 'upower' indispensable.${N}\n"
    else
        local battery=$(upower -e | grep 'BAT')
        if [[ -z "$battery" ]]; then
            printf "${Y}   [!] Aucune batterie détectée sur cet appareil.${N}\n"
            printf "${G}   [ RESULTAT : OK (ALIMENTATION SECTEUR) ]${N}\n"
        else
            local bat_info=$(upower -i $battery)
            echo "$bat_info" | grep -E "state|percentage|capacity|cycle-count|energy-full-design|energy-full|model" | sed 's/^/   /'
            
            local capacity=$(echo "$bat_info" | grep -w "capacity:" | awk '{print $2}' | tr -d '%' | sed 's/[,.].*//')
            
            if [[ -n "$capacity" && "$capacity" -lt 80 ]]; then
                 printf "\n${Y}   [ RESULTAT : BATTERIE USÉE (${capacity}%%) - ENVISAGEZ UN REMPLACEMENT ]${N}\n"
            else
                 printf "\n${G}   [ RESULTAT : BATTERIE EN BON ÉTAT (${capacity}%%) ]${N}\n"
            fi
        fi
    fi
    printf "\n"
    read -p "   Pressez [ENTRÉE] pour revenir..."
}


# --- MOTEUR DE MENU PAR FLÈCHES ---

# Définition : Label | Type | Fonction | Description
menu_items=(
    "SYSTÈME|CAT||"
    "Vue Rapide|OPT|sys_fastview|Résumé OS, Kernel & Uptime"
    "Monitoring|OPT|sys_monitor|Dashboard interactif temps réel (Btop)"
    "AUDIT MATÉRIEL PROFOND|CAT||"
    "Santé Disque|OPT|hw_disk_health|Analyse SMART & Prédiction de pannes"
    "Températures|OPT|hw_thermal_live|Sondes de température (CPU, GPU, NVMe)"
    "Batterie & Énergie|OPT|hw_power_stat|Santé batterie & Cycles de charge"

    "MAINTENANCE & RÉPARATION|CAT||"
    "RÉSEAU LOCAL & WI-FI|CAT||"
    "PENTEST WEB|CAT||"
    "EXTRACTION LOCALE|CAT||"
    "SÉCURITÉ & UTILISATEURS|CAT||"
    "PERSONNALISATION|CAT||"
)

main_menu() {
    local selected=2 
    local total=${#menu_items[@]}

    while true; do
        clear
        print_logo
        printf "${C}  ========================================================================================${N}\n"
        printf "${W}   TABLEAU DE BORD - NAVIGATION AUX FLÈCHES${N}\n"
        printf "${C}  ========================================================================================${N}\n"
        
        local i=0
        for item in "${menu_items[@]}"; do
            ((i++))
            IFS="|" read -r label type func desc <<< "$item"
            
            if [[ "$type" == "CAT" ]]; then
                printf "\n${C}  [ %s ]${N}\n" "$label"
            elif [[ "$type" == "SEP" ]]; then
                printf "\n${C}  ----------------------------------------------------------------------------------------${N}\n"
            else
                if [[ $i -eq $selected ]]; then
                    printf "${BG_SEL}    >> %-20s ${N} ${DG} %-40s ${N}\n" "$label" "- $desc"
                else
                    printf "${W}       %-20s ${N} ${DG} %-40s ${N}\n" "$label" "- $desc"
                fi
            fi
        done

        printf "\n${C}  ========================================================================================${N}\n"
        printf "${DG}   [↑/↓] Naviguer | [ENTRÉE] Valider${N}\n"

        read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 -t 0.1 seq
                case "$seq" in
                    "[A") # Haut
                        ((selected--))
                        [[ $selected -lt 1 ]] && selected=$total
                        IFS="|" read -r l t f d <<< "${menu_items[$((selected-1))]}"
                        while [[ "$t" == "CAT" || "$t" == "SEP" ]]; do
                            ((selected--))
                            [[ $selected -lt 1 ]] && selected=$total
                            IFS="|" read -r l t f d <<< "${menu_items[$((selected-1))]}"
                        done
                        ;;
                    "[B") # Bas
                        ((selected++))
                        [[ $selected -gt $total ]] && selected=1
                        IFS="|" read -r l t f d <<< "${menu_items[$((selected-1))]}"
                        while [[ "$t" == "CAT" || "$t" == "SEP" ]]; do
                            ((selected++))
                            [[ $selected -gt $total ]] && selected=1
                            IFS="|" read -r l t f d <<< "${menu_items[$((selected-1))]}"
                        done
                        ;;
                esac
                ;;
            "") # Entrée
                IFS="|" read -r label type func desc <<< "${menu_items[$((selected-1))]}"
                if [[ "$func" == "exit" ]]; then exit 0; fi
                if [[ -n "$func" ]]; then "$func"; fi
                ;;
        esac
    done
}

main_menu
