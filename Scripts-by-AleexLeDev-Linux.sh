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

# Gestion de l'interruption (Ctrl+C) pour revenir au menu sans quitter
trap 'printf "\n${R} [!] Action interrompue. Retour au menu...${N}\n"' SIGINT

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
        printf "${Y}   [!] Outil '%s' manquant. Préparation de l'installation...${N}\n" "$cmd"
        
        local pm="apt"
        command -v nala &>/dev/null && pm="nala"
        
        printf "${DG}"
        if [[ "$pm" == "nala" ]]; then
            sudo nala update
        else
            sudo apt update -y
        fi
        sudo $pm install -y "$pkg"
        printf "${N}"
        
        if command -v "$cmd" &> /dev/null; then
            printf "${G}   [✓] %s installé avec succès.${N}\n" "$pkg"
            return 0
        else
            printf "${R}   [✗] Erreur lors de l'installation de %s.${N}\n" "$pkg"
            return 1
        fi
    fi
    return 0
}

pause_back() {
    printf "\n   ${DG}Pressez [ENTRÉE] ou [ECHAP] pour revenir au menu...${N}"
    # Désactive le trap temporairement pour que Echap/Entrée fonctionnent normalement ici
    local old_trap=$(trap -p SIGINT)
    trap '' SIGINT
    while true; do
        read -rsn1 key
        case "$key" in
            "") break ;;
            $'\x1b') break ;;
        esac
    done
    eval "$old_trap"
}

# Permet d'utiliser ECHAP pour interrompre une commande système longue
run_with_esc() {
    local old_stty=$(stty -g)
    # Map Echap (\x1b) sur le signal d'interruption
    stty intr $'\x1b'
    "$@"
    local ret=$?
    stty "$old_stty"
    return $ret
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
    pause_back
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
    pause_back
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
    pause_back
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
    pause_back
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
    pause_back
}
maint_turbo_clean() {
    clear
    print_logo
    printf "${C}  [ NETTOYAGE INTÉGRAL DU SYSTÈME ]${N}\n\n"

    check_and_install "nala" "nala"
    local pkg_mgr="apt"
    command -v nala &> /dev/null && pkg_mgr="nala"

    # --- ÉTAPE 1 ---
    printf "${C} [1/4]${N} ${W}Nettoyage des paquets et dépendances...${N}\n"
    printf "${DG}"
    sudo $pkg_mgr autoremove -y
    sudo $pkg_mgr clean
    printf "${N}"
    
    # --- ÉTAPE 2 ---
    printf "\n${C} [2/4]${N} ${W}Purge des journaux système (Journald)...${N}\n"
    printf "${DG}"
    sudo journalctl --vacuum-time=2d
    printf "${N}"
    
    # --- ÉTAPE 3 ---
    printf "\n${C} [3/4]${N} ${W}Vidage des caches et fichiers temporaires...${N}\n"
    printf "${DG}"
    local thumb_size=$(du -sh ~/.cache/thumbnails 2>/dev/null | awk '{print $1}')
    rm -rf ~/.cache/thumbnails/* && echo "   - Miniatures supprimées (Espace : $thumb_size)"
    rm -rf ~/.local/share/Trash/* && echo "   - Corbeille vidée"
    sudo rm -rf /tmp/* 2>/dev/null && echo "   - Répertoire /tmp vidé"
    sudo rm -rf /var/tmp/* 2>/dev/null && echo "   - Répertoire /var/tmp vidé"
    printf "${N}"
    
    # --- ÉTAPE 4 ---
    printf "\n${C} [4/4]${N} ${W}Optimisation matérielle (Trim SSD)...${N}\n"
    printf "     ${Y}(!) Cette opération peut prendre quelques minutes...${N}\n"
    printf "${DG}"
    run_with_esc sudo fstrim -av
    printf "${N}"
    
    printf "\n${G} [ RESULTAT : NETTOYAGE TERMINÉ AVEC SUCCÈS ]${N}\n"
    pause_back
}

maint_update_manager() {
    local sub_items=(
        "🚀 TOUT METTRE À JOUR|OPT|maint_up_full|Mise à jour Système + Apps + BIOS"
        "Système uniquement (Apt/Nala)|OPT|maint_up_sys|Mise à jour des dépôts classiques"
        "Applications modernes (Flatpak/Snap)|OPT|maint_up_apps|Mise à jour Flatpak & Snap"
        "Firmware & BIOS (fwupdmgr)|OPT|maint_up_firm|Mise à jour des pilotes matériels"
        "Mise à jour du noyau (Kernel)|OPT|maint_up_kern|Mise à jour linux-image-generic"
    )
    
    while true; do
        menu_engine "GESTIONNAIRE DE MISES À JOUR" "${sub_items[@]}"
        local choice=$?
        
        [[ $choice -eq 255 ]] && return
        
        IFS="|" read -r label type func desc <<< "${sub_items[$choice]}"
        
        clear
        print_logo
        case "$func" in
            maint_up_full)
                check_and_install "nala" "nala"
                local pm="apt"; command -v nala &>/dev/null && pm="nala"
                printf "${G} > Lancement de la mise à jour totale...${N}\n"
                run_with_esc sudo $pm upgrade -y
                command -v flatpak &>/dev/null && run_with_esc sudo flatpak update -y
                command -v snap &>/dev/null && run_with_esc sudo snap refresh
                if command -v snap &>/dev/null && [[ -n $(snap warnings 2>/dev/null | grep -v "No warnings") ]]; then
                    printf "\n${Y} [!] Alertes Snap :${N}\n"
                    snap warnings | sed 's/^/     /'
                fi
                if command -v fwupdmgr &>/dev/null; then sudo fwupdmgr get-updates && sudo fwupdmgr update; fi
                ;;
            maint_up_sys)
                check_and_install "nala" "nala"
                local pm="apt"; command -v nala &>/dev/null && pm="nala"
                run_with_esc sudo $pm upgrade -y
                ;;
            maint_up_apps)
                command -v flatpak &>/dev/null && run_with_esc sudo flatpak update -y
                command -v snap &>/dev/null && run_with_esc sudo snap refresh
                if command -v snap &>/dev/null && [[ -n $(snap warnings 2>/dev/null | grep -v "No warnings") ]]; then
                    printf "\n${Y} [!] Alertes Snap :${N}\n"
                    snap warnings | sed 's/^/     /'
                fi
                ;;
            maint_up_firm)
                check_and_install "fwupdmgr" "fwupd"
                sudo fwupdmgr get-updates && run_with_esc sudo fwupdmgr update
                ;;
            maint_up_kern)
                check_and_install "nala" "nala"
                local pm="apt"; command -v nala &>/dev/null && pm="nala"
                run_with_esc sudo $pm install --only-upgrade linux-image-generic -y
                ;;
        esac
        printf "\n${G} [ RESULTAT : OPÉRATION TERMINÉE ]${N}\n"
        pause_back
    done
}

maint_package_cleaner() {
    local sub_items=(
        "📱 Gérer les APPLICATIONS|OPT|maint_pkg_gui_apps|Lister uniquement les logiciels avec icônes"
        "🔍 RECHERCHER SPÉCIFIQUE|OPT|maint_pkg_search|Chercher un mot-clé précis"
        "📦 Système (Expert)|OPT|maint_pkg_apt|Lister ABSOLUMENT TOUT (immense)"
        "💎 Gérer les Flatpaks|OPT|maint_pkg_flatpak|Lister et supprimer des Flatpaks"
        "⚡ Gérer les Snaps|OPT|maint_pkg_snap|Lister et supprimer des Snaps"
        "🧹 Supprimer les résidus|OPT|maint_pkg_orphans|Nettoyer les paquets orphelins (autoremove)"
        "🔥 DÉSINSTALLATION TOTALE|OPT|maint_pkg_purge_all|/!\ PURGE COMPLÈTE /!\\"
    )
    
    while true; do
        menu_engine "GESTIONNAIRE DE PAQUETS & LOGICIELS" "${sub_items[@]}"
        local choice=$?
        [[ $choice -eq 255 ]] && return
        
        IFS="|" read -r label type func desc <<< "${sub_items[$choice]}"
        clear
        print_logo
        $func
    done
}

maint_pkg_gui_apps() {
    check_and_install "fzf" "fzf"
    printf "${C}  [ LISTE DES APPLICATIONS INSTALLÉES ]${N}\n\n"
    printf "   ${DG}Note : Cette liste ne contient que les logiciels avec une interface graphique.${N}\n\n"
    
    # Extraction des paquets possédant un fichier .desktop (Applications)
    local pkg_list=$(dpkg -S /usr/share/applications/*.desktop 2>/dev/null | cut -d: -f1 | sort -u)
    
    if [[ -z "$pkg_list" ]]; then
        printf "   ${R}[!] Aucune application graphique détectée via dpkg.${N}\n"
        pause_back
        return
    fi

    local selections=$(echo "$pkg_list" | xargs dpkg-query -W -f='${Package}|${Description}\n' | fzf -m --header="Sélectionnez les APPS à supprimer" --height 50% --preview "apt-cache show {1} | grep -E 'Description|Size'" --preview-window=right:50%:wrap)
    
    local pkgs=$(echo "$selections" | awk -F'|' '{print $1}' | xargs)
    
    if [[ -n "$pkgs" ]]; then
        printf "\n${R} [!] Confirmation de suppression pour :${N}\n"
        for p in $pkgs; do echo "     - $p"; done
        printf "\n${W} Confirmer la suppression ? (y/n) : ${N}"
        read -n 1 -r confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            printf "\n${DG}"
            for p in $pkgs; do
                sudo apt purge -y "$p"
            done
            sudo apt autoremove -y
            printf "${N}${G} [✓] Suppression terminée.${N}\n"
        fi
    fi
    pause_back
}

maint_pkg_search() {
    check_and_install "fzf" "fzf"
    printf "${C}  [ RECHERCHE & SUPPRESSION ]${N}\n\n"
    printf " Entrez un mot-clé (ou laissez VIDE pour tout voir) : "
    read -r search_query
    
    # Affiche le nom et la description pour plus de clarté
    local selection=$(dpkg -l | grep "^ii" | grep -i "$search_query" | awk '{printf "%-30s | %s\n", $2, $5}' | fzf --header="Sélectionnez le paquet à supprimer (ESC pour annuler)" --height 40%)
    
    local pkg=$(echo "$selection" | awk -F'|' '{print $1}' | xargs)
    
    if [[ -n "$pkg" ]]; then
        printf "\n${R} [!] Voulez-vous vraiment supprimer '$pkg' ? (y/n) : ${N}"
        read -n 1 -r confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            printf "\n${DG}"
            sudo apt purge -y "$pkg" && sudo apt autoremove -y
            printf "${N}${G} [✓] $pkg a été supprimé.${N}\n"
        fi
    fi
    pause_back
}

maint_pkg_apt() {
    check_and_install "fzf" "fzf"
    printf "${C}  [ LISTE DES PAQUETS SYSTÈME ]${N}\n\n"
    printf "   ${DG}Navigation: [↑/↓] | Sélection multiple: [TAB] | Valider: [ENTRÉE]${N}\n\n"
    
    # fzf avec sélection multiple (-m) et prévisualisation
    local selections=$(dpkg-query -W -f='${Package}|${Description}\n' | fzf -m --header="ESPACE pour marquer, ENTRÉE pour valider" --height 50% --preview "apt-cache show {1} | grep -E 'Description|Size|Maintainer'" --preview-window=right:50%:wrap)
    
    local pkgs=$(echo "$selections" | awk -F'|' '{print $1}' | xargs)
    
    if [[ -n "$pkgs" ]]; then
        printf "\n${R} [!] Confirmation de suppression pour :${N}\n"
        for p in $pkgs; do echo "     - $p"; done
        printf "\n${W} Confirmer la suppression ? (y/n) : ${N}"
        read -n 1 -r confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            printf "\n${DG}"
            for p in $pkgs; do
                sudo apt purge -y "$p"
            done
            sudo apt autoremove -y
            printf "${N}${G} [✓] Opération terminée.${N}\n"
        fi
    fi
    pause_back
}

maint_pkg_flatpak() {
    if ! command -v flatpak &>/dev/null; then printf "${R} Flatpak n'est pas installé.${N}\n"; pause_back; return; fi
    check_and_install "fzf" "fzf"
    printf "${C}  [ APPLICATIONS FLATPAK ]${N}\n\n"
    local pkg=$(flatpak list --columns=application,name | fzf --header="Sélectionnez un Flatpak à supprimer")
    local id=$(echo "$pkg" | awk '{print $1}')
    
    if [[ -n "$id" ]]; then
        printf "\n${R} [!] Supprimer le Flatpak '$id' ? (y/n) : ${N}"
        read -n 1 -r confirm
        [[ $confirm =~ ^[Yy]$ ]] && sudo flatpak uninstall -y "$id"
    fi
    pause_back
}

maint_pkg_snap() {
    if ! command -v snap &>/dev/null; then printf "${R} Snap n'est pas installé.${N}\n"; pause_back; return; fi
    check_and_install "fzf" "fzf"
    printf "${C}  [ APPLICATIONS SNAP ]${N}\n\n"
    local pkg=$(snap list | awk 'NR>1 {print $1}' | fzf --header="Sélectionnez un Snap à supprimer")
    
    if [[ -n "$pkg" ]]; then
        printf "\n${R} [!] Supprimer le Snap '$pkg' ? (y/n) : ${N}"
        read -n 1 -r confirm
        [[ $confirm =~ ^[Yy]$ ]] && sudo snap remove "$pkg"
    fi
    pause_back
}

maint_pkg_orphans() {
    printf "${C}  [ NETTOYAGE DES ORPHELINS ]${N}\n\n"
    printf "${DG}"
    sudo apt autoremove -y && sudo apt autoclean
    printf "${N}\n${G} [✓] Nettoyage terminé.${N}\n"
    pause_back
}

maint_pkg_purge_all() {
    printf "${R}  [!!!] DÉSINSTALLATION TOTALE / PURGE DU SYSTÈME [!!!]${N}\n\n"
    printf "${Y} Cette option va tenter de supprimer TOUS les paquets non-essentiels,${N}\n"
    printf "${Y} les caches, et purger les fichiers de configuration.${N}\n\n"
    
    printf "${R} ATTENTION : C'est une opération risquée. Taper 'PURGE' pour confirmer : ${N}"
    read -r confirm
    
    if [[ "$confirm" == "PURGE" ]]; then
        printf "\n${R} Lancement de la purge totale...${N}\n"
        printf "${DG}"
        # On ne supprime pas tout le système (sinon plus de script), mais on purge les paquets inutiles et les configs
        sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}') -y 2>/dev/null
        sudo apt-get autoremove --purge -y
        sudo apt-get clean
        printf "${N}\n${G} [✓] Système purgé des résidus et paquets inutiles.${N}\n"
    else
        printf "\n Annulé.${N}\n"
    fi
    pause_back
}

# --- FONCTIONS RÉSEAU ---

net_global_audit() {
    clear
    print_logo
    printf "${C}  [ AUDIT RÉSEAU GLOBAL ]${N}\n\n"

    check_and_install "speedtest-cli" "speedtest-cli"
    check_and_install "bc" "bc"
    check_and_install "curl" "curl"

    # --- 1. IDENTITÉ ---
    printf "${W} [1/4] Identification des interfaces...${N}\n"
    local gateway=$(ip route | grep default | awk '{print $3}' | head -n1)
    local ip_pub=$(curl -s --connect-timeout 5 https://ifconfig.me || echo "Indisponible")
    local dns_servers=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | xargs)
    
    printf "     • IP Interne : ${G}$(hostname -I | awk '{print $1}')${N}\n"
    printf "     • IP Publique: ${C}$ip_pub${N}\n"
    printf "     • Passerelle : ${W}$gateway${N}\n"
    printf "     • DNS        : ${DG}$dns_servers${N}\n"

    # --- 2. VITESSE ---
    printf "\n${W} [2/4] Test de débit (Speedtest)...${N}\n"
    printf "     ${Y}(!) Analyse en cours, veuillez patienter...${N}\n"
    printf "${DG}"
    local st_res=$(run_with_esc speedtest-cli --simple 2>/dev/null)
    printf "${N}"
    
    if [[ -n "$st_res" ]]; then
        local down=$(echo "$st_res" | awk '/Download/ {print $2}')
        local up=$(echo "$st_res" | awk '/Upload/ {print $2}')
        local ping=$(echo "$st_res" | awk '/Ping/ {print $2}')
        
        local color=$R; local rank="MAUVAIS"
        if (( $(echo "$down > 200" | bc -l) )); then color=$C; rank="TRÈS BON"
        elif (( $(echo "$down > 50" | bc -l) )); then color=$G; rank="BON"
        elif (( $(echo "$down > 10" | bc -l) )); then color=$Y; rank="MOYEN"
        fi
        
        printf "     • Réception : ${color}$down Mbps ($rank)${N}\n"
        printf "     • Envoi     : ${W}$up Mbps${N}\n"
        printf "     • Latence   : ${W}$ping ms${N}\n"
    else
        printf "     ${R}[!] Test de débit annulé ou échoué.${N}\n"
    fi

    # --- 3. STABILITÉ ---
    printf "\n${W} [3/4] Test de stabilité (Ping 8.8.8.8)...${N}\n"
    local loss=$(ping -c 4 -W 2 8.8.8.8 2>/dev/null | grep -oP '\d+(?=% packet loss)')
    if [[ "$loss" == "0" ]]; then
        printf "     • Statut : ${G}STABLE (0%% de perte)${N}\n"
    else
        printf "     • Statut : ${R}INSTABLE ($loss%% de perte)${N}\n"
    fi

    # --- 4. LOOT WI-FI ---
    printf "\n${W} [4/4] Récupération des clés Wi-Fi enregistrées...${N}\n"
    if [[ -d "/etc/NetworkManager/system-connections/" ]]; then
        sudo grep -r '^psk=' /etc/NetworkManager/system-connections/ 2>/dev/null | while read -r line; do
            local file_path=$(echo "$line" | cut -d: -f1)
            local ssid=$(basename "$file_path" | sed 's/\.nmconnection//')
            local pass=$(echo "$line" | cut -d= -f2)
            printf "     • ${W}%-20s${N} : ${G}%s${N}\n" "$ssid" "$pass"
        done
    else
        printf "     ${DG}Aucun profil NetworkManager trouvé.${N}\n"
    fi

    pause_back
}

net_wifi_scanner() {
    clear
    print_logo
    printf "${C}  [ SCANNER WI-FI PASSIF ]${N}\n\n"
    
    if ! command -v nmcli &> /dev/null; then
        printf "${R} [!] Erreur : nmcli n'est pas installé.${N}\n"
        pause_back
        return
    fi

    printf "${W} Recherche des réseaux à proximité...${N}\n\n"
    printf "${DG}"
    run_with_esc nmcli -f BARS,SSID,SIGNAL,BARS,SECURITY,CHAN dev wifi list
    printf "${N}"
    
    pause_back
}

net_stack_reset() {
    clear
    print_logo
    printf "${C}  [ RÉINITIALISATION DE LA PILE RÉSEAU ]${N}\n\n"
    
    printf "${W} [1/3] Redémarrage de NetworkManager...${N}\n"
    sudo systemctl restart NetworkManager
    sleep 2
    
    printf "${W} [2/3] Vidage du cache DNS (systemd-resolved)...${N}\n"
    if command -v resolvectl &>/dev/null; then
        sudo resolvectl flush-caches
        printf "     ${G}✓ Cache DNS vidé.${N}\n"
    else
        printf "     ${DG}! resolvectl non trouvé, passage...${N}\n"
    fi
    
    printf "${W} [3/3] Réactivation des interfaces...${N}\n"
    sudo nmcli networking off && sleep 1 && sudo nmcli networking on
    
    printf "\n${G} [ RESULTAT : RÉSEAU RÉINITIALISÉ ]${N}\n"
    pause_back
}


# --- MOTEUR DE MENU UNIFIÉ ---

menu_engine() {
    local title="$1"
    shift
    local items=("$@")
    local selected=1
    local total=${#items[@]}
    
    # Trouver le premier item sélectionnable
    for ((i=0; i<total; i++)); do
        IFS="|" read -r label type func desc <<< "${items[$i]}"
        if [[ "$type" != "CAT" && "$type" != "SEP" ]]; then
            selected=$((i+1))
            break
        fi
    done

    while true; do
        clear
        print_logo
        printf "${C}  ========================================================================================${N}\n"
        printf "${W}   %s${N}\n" "$title"
        printf "${C}  ========================================================================================${N}\n"
        
        local i=0
        for item in "${items[@]}"; do
            ((i++))
            IFS="|" read -r label type func desc <<< "$item"
            
            if [[ "$type" == "CAT" ]]; then
                printf "\n${C}  [ %s ]${N}\n" "$label"
            elif [[ "$type" == "SEP" ]]; then
                printf "\n${C}  ----------------------------------------------------------------------------------------${N}\n"
            else
                if [[ $i -eq $selected ]]; then
                    printf "${BG_SEL}    >> %-30s ${N} ${DG} %-40s ${N}\n" "$label" "- $desc"
                else
                    printf "${W}       %-30s ${N} ${DG} %-40s ${N}\n" "$label" "- $desc"
                fi
            fi
        done

        printf "\n${C}  ========================================================================================${N}\n"
        printf "${DG}   [↑/↓] Naviguer | [ENTRÉE] Valider | [ECHAP] Retour${N}\n"

        read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 -t 0.1 seq
                if [[ -z "$seq" ]]; then return 255; fi
                case "$seq" in
                    "[A") # Haut
                        ((selected--))
                        [[ $selected -lt 1 ]] && selected=$total
                        IFS="|" read -r l t f d <<< "${items[$((selected-1))]}"
                        while [[ "$t" == "CAT" || "$t" == "SEP" ]]; do
                            ((selected--))
                            [[ $selected -lt 1 ]] && selected=$total
                            IFS="|" read -r l t f d <<< "${items[$((selected-1))]}"
                        done
                        ;;
                    "[B") # Bas
                        ((selected++))
                        [[ $selected -gt $total ]] && selected=1
                        IFS="|" read -r l t f d <<< "${items[$((selected-1))]}"
                        while [[ "$t" == "CAT" || "$t" == "SEP" ]]; do
                            ((selected++))
                            [[ $selected -gt $total ]] && selected=1
                            IFS="|" read -r l t f d <<< "${items[$((selected-1))]}"
                        done
                        ;;
                esac
                ;;
            "") # Entrée
                return $((selected-1))
                ;;
        esac
    done
}

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
    "Nettoyage Turbo|OPT|maint_turbo_clean|Libère de l'espace & Optimise SSD"
    "Désinstalleur Pro|OPT|maint_package_cleaner|Supprimer paquets Apt, Flatpak, Snap"
    "Hub Mise à jour|OPT|maint_update_manager|Gestionnaire Apt, Flatpak, Snap & BIOS"
    "RÉSEAU LOCAL & WI-FI|CAT||"
    "Audit Global|OPT|net_global_audit|Rapport complet (Débit, IP, Wi-Fi)"
    "Scanner Wi-Fi|OPT|net_wifi_scanner|Voir les réseaux à proximité"
    "Reset Réseau|OPT|net_stack_reset|Relancer la stack & vider les DNS"
    "PENTEST WEB|CAT||"
    "EXTRACTION LOCALE|CAT||"
    "SÉCURITÉ & UTILISATEURS|CAT||"
    "PERSONNALISATION|CAT||"
    "QUITTER|OPT|exit|Fermer la boîte à scripts"
)

main_menu() {
    while true; do
        menu_engine "TABLEAU DE BORD - NAVIGATION AUX FLÈCHES" "${menu_items[@]}"
        local choice=$?
        
        [[ $choice -eq 255 ]] && continue
        
        IFS="|" read -r label type func desc <<< "${menu_items[$choice]}"
        
        if [[ "$func" == "exit" ]]; then exit 0; fi
        if [[ -n "$func" ]]; then "$func"; fi
    done
}

main_menu
