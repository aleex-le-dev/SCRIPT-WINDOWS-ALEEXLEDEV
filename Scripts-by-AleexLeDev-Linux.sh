#!/usr/bin/env bash
# ==============================================================
#  Scripts-by-AleexLeDev - Linux Edition v1.0
#  Equivalent Linux du toolkit Windows (10 categories, 133 outils)
#  Navigation : fleches clavier uniquement, jamais de saisie
# ==============================================================

# ================================================================
#  AUTO-LANCEMENT : si double-clic (pas de terminal) -> ouvrir un
#  terminal et se relancer en root automatiquement. Fichier unique.
# ================================================================
SELF="$(readlink -f "${BASH_SOURCE[0]}")"

if [ ! -t 1 ]; then
    CMD="sudo bash '$SELF'; echo; read -rp 'Appuie sur Entree pour fermer...'"
    for term in gnome-terminal konsole xfce4-terminal mate-terminal tilix lxterminal xterm; do
        if command -v "$term" &>/dev/null; then
            case "$term" in
                gnome-terminal) "$term" -- bash -c "$CMD" ;;
                *)              "$term" -e bash -c "$CMD" ;;
            esac
            exit 0
        fi
    done
    notify-send "Scripts AleexLeDev" "Aucun terminal trouve. Lance : sudo bash '$SELF'" 2>/dev/null
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    exec sudo bash "$SELF" "$@"
fi

# ================================================================
#  CONFIGURATION GLOBALE
# ================================================================
VERSION="1.0 LINUX EDITION"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAV_FILE="$HOME/.config/scripts-aleex/favoris.txt"
mkdir -p "$HOME/.config/scripts-aleex"

# ================================================================
#  COULEURS & STYLES
# ================================================================
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
BLU='\033[0;34m'
CYN='\033[0;36m'
MAG='\033[0;35m'
WHT='\033[1;37m'
GRY='\033[0;90m'
BLD='\033[1m'
NC='\033[0m'
SEL='\033[1;97;44m'   # Blanc gras sur fond bleu (selection)
HDR='\033[1;96m'      # Cyan gras (titres)
SEP='\033[0;90m'      # Gris (separateurs)

# ================================================================
#  DICTIONNAIRE t[N] - FORMAT : "label:Titre~Description"
# ================================================================
declare -A t

# --- CATEGORIE 1 : DIAGNOSTIC ---
t[1]="sys_report:Rapport Systeme~CPU, RAM, GPU, Stockage, Reseau"
t[2]="sys_temp:Temperatures~Capteurs thermiques (lm-sensors)"
t[3]="sys_ram_check:Analyse RAM~Modules, slots, vitesse (dmidecode)"
t[4]="sys_diag_net:Diagnostic Reseau~Ping, traceroute, ports ouverts"
t[5]="sys_battery:Rapport Batterie~Usure et autonomie estimee"
t[6]="sys_luks:Chiffrement Disque~Verification LUKS / dm-crypt"
t[7]="sys_journal:Journal Erreurs~Erreurs systeme recentes (journalctl)"
t[8]="sys_stress:Test de Charge~CPU/RAM stress test (stress-ng)"
t[9]="sys_av_status:Statut Antivirus~ClamAV / protection active"
t[10]="ev_crit_24h:Erreurs Critiques 24h~Evenements critiques 24 dernieres heures"
t[11]="ev_crit_7d:Erreurs Critiques 7j~Evenements critiques 7 derniers jours"
t[12]="ev_app_24h:Crashs Applications 24h~Segfaults et crashs recents"
t[13]="ev_disk_warn:Sante Disques SMART~smartctl health check"

# --- CATEGORIE 2 : REPARATION ---
t[16]="rep_fsck:Verification Disque~fsck sur les partitions non montees"
t[17]="rep_pkg_fix:Reparer Paquets~apt --fix-broken + dpkg --configure -a"
t[18]="rep_dpkg_fix:Reparer DPKG Bloque~Verrous dpkg/apt + reconstruction base"
t[19]="rep_net_reset:Reinitialiser Reseau~NetworkManager + DNS + interfaces"
t[20]="rep_desktop:Redemarrer Bureau~GNOME Shell / KDE Plasma / XFCE"
t[21]="rep_display_manager:Redemarrer Display Manager~GDM / SDDM / LightDM"
t[22]="rep_timeshift:Point de Restauration~Snapshot Timeshift"
t[23]="rep_grub:Mise a jour GRUB~update-grub / grub2-mkconfig / grub-mkconfig"
t[24]="rep_initramfs:Reconstruire initramfs~update-initramfs / mkinitcpio / dracut"
t[25]="rep_services:Reparer Services Systemd~reset-failed + logs services"
t[26]="rep_permissions:Corriger Permissions~home / tmp / ssh / sudoers"
t[27]="rep_hosts:Reinitialiser /etc/hosts~Reset au fichier par defaut"
t[28]="rep_locale:Reparer Locales~locale-gen + dpkg-reconfigure"
t[29]="rep_font_cache:Cache Polices~fc-cache -fv reconstruction"
t[30]="rep_ssh_fix:Reparer SSH~Cles hotes, config, service sshd"

# --- CATEGORIE 3 : NETTOYAGE & OPTIMISATION ---
t[37]="cl_all:Nettoyage Complet~Tout nettoyer en une fois"
t[38]="cl_apt:Cache APT~Nettoyer cache apt/dpkg"
t[39]="cl_temp:Fichiers Temporaires~/tmp et caches utilisateur"
t[40]="cl_dns:Cache DNS~Vider le cache DNS systemd-resolved"
t[41]="cl_logs:Anciens Logs~journalctl --vacuum (rotation)"
t[42]="cl_trash:Corbeille~Vider la corbeille"
t[43]="cl_orphans:Paquets Orphelins~autoremove + autoclean"
t[44]="sys_startup:Gestionnaire Demarrage~Services actifs au boot (systemctl)"
t[45]="sys_tweaks:Optimisations Systeme~Swappiness, scheduler, performance"

# --- CATEGORIE 4 : RESEAU & CYBER ---
t[50]="dns_manager:Gestionnaire DNS~Changer DNS (Cloudflare / Google / Custom)"
t[51]="dns_display:Afficher DNS~DNS actuels et resolveurs"
t[52]="net_ports:Ports Ouverts~ss -tulpn (connexions actives)"
t[53]="net_ip_info:Info IP~IP locale, publique, passerelle"
t[54]="net_arp:Table ARP~Appareils detectes sur le LAN"
t[55]="cyber_lan:Scan LAN~nmap - decouverte hotes reseau"
t[56]="cyber_ports:Scan de Ports~nmap - ports d un hote cible"
t[57]="cyber_dns_leak:DNS Leak Test~Verifier fuite VPN/DNS"
t[58]="net_wifi_scan:Scan WiFi~Reseaux disponibles (SSID, signal, chiffrement)"
t[59]="net_wifi_target:Analyser WiFi~Details d un reseau cible"
t[60]="net_wifi_crack:Cracker WiFi~WPA2 handshake + aircrack-ng"
t[61]="net_discover:Decouverte LAN~IP, Nom, MAC, Fabricant"
t[62]="net_enum:Enum Services~SSH, Telnet, RDP, FTP, VNC"
t[63]="net_web_hunt:Web Interface Hunt~Ports 80/443/8080/8443"
t[64]="net_vuln:Verif Vulnerabilites~Partages, acces guest, SMB"

# --- CATEGORIE 5 : DISQUE ---
t[74]="disk_manager:Gestionnaire Disque~fdisk / lsblk / formatage"
t[75]="disk_smart:Sante SMART~Rapport complet smartctl"
t[76]="disk_usage:Utilisation Disque~df -h + top repertoires"
t[77]="disk_bench:Benchmark I/O~Test vitesse lecture/ecriture"

# --- CATEGORIE 6 : APPLICATIONS ---
t[80]="app_update:Mise a jour Tout~apt + snap + flatpak"
t[81]="app_list:Liste Applications~Paquets installes"
t[82]="app_install:Installateur Rapide~Selection d apps par categorie"
t[83]="app_clean:Nettoyer Anciennes Versions~Snap revisions + apt"

# --- CATEGORIE 7 : COMPTES & SECURITE ---
t[85]="pw_menu:Menu Mots de Passe~Extraction et gestion"
t[86]="pw_wifi:Export WiFi~Mots de passe WiFi sauvegardes"
t[87]="pw_browser:MDP Navigateur~Firefox / Chromium (profils)"
t[88]="pw_history:Historique Navigateur~Firefox / Chrome / Chromium"
t[89]="pw_sensitive:Fichiers Sensibles~Scanner documents confidentiels"
t[90]="um_menu:Gestion Utilisateurs~Lister, creer, supprimer comptes"
t[91]="um_add:Creer Utilisateur~Nouveau compte avec groupe"
t[92]="um_del:Supprimer Utilisateur~Suppression compte + home"
t[93]="um_passwd:Changer Mot de Passe~Modifier mdp utilisateur"
t[94]="um_sudo:Droits Sudo~Gerer privileges sudo"
t[95]="sys_eicar:Test EICAR~Verifier reponse antivirus (safe)"

# --- CATEGORIE 8 : EXTRACTION & SAUVEGARDE ---
t[110]="ex_hw:Info Materiel~lshw - inventaire complet"
t[111]="ex_drivers:Modules Kernel~Pilotes et modules charges"
t[112]="ex_pkglist:Exporter Liste Apps~Export paquets installes"
t[113]="ex_wifi:Exporter Profils WiFi~Backup configurations WiFi"
t[114]="ex_loot:Extraction Complete~WiFi + historique + comptes"
t[115]="ex_dotfiles:Sauvegarder Config~Dotfiles et configurations"

# --- CATEGORIE 9 : PERSONNALISATION ---
t[165]="per_theme:Theme Systeme~GNOME/KDE dark/light mode"
t[166]="per_aliases:Alias Utiles~Ajouter aliases bash pratiques"
t[167]="per_gaming:Mode Gaming~CPU performance + latence reseau"
t[168]="per_shortcuts:Raccourcis Bureau~Creer lanceurs .desktop"
t[169]="per_hostname:Changer Hostname~Modifier le nom de la machine"

# --- CATEGORIE 10 : MATERIEL ---
t[124]="hw_report:Rapport Materiel~CPU, RAM, GPU, disques complet"
t[125]="hw_cpu:Infos CPU~Frequence, coeurs, temperature"
t[126]="hw_gpu:Infos GPU~Detection GPU + memoire"
t[127]="hw_ram:Infos RAM~Modules, frequence, capacite"
t[128]="hw_disks:Infos Disques~Tous les disques et partitions"
t[129]="hw_usb:Peripheriques USB~Lister les appareils connectes"
t[130]="pp_perf:Mode Performance~CPU governor = performance"
t[131]="pp_balanced:Mode Equilibre~CPU governor = ondemand"
t[132]="pp_save:Mode Economie~CPU governor = powersave"
t[133]="pp_current:Plan Actuel~Afficher governor en cours"

# Compter le total automatiquement
total_tools=0
for k in "${!t[@]}"; do ((total_tools++)); done


# ================================================================
#  SYSTEME DE MENUS - NAVIGATION AUX FLECHES
#  Equivalent : call :AutoMenu "TITRE" "label1;[---];label2"
# ================================================================

# Variables globales menu
declare -a MENU_OPTS=()
MENU_CHOICE=0

# Separateur : toute option commencant par "---" est non-selectable
_is_separator() {
    [[ "$1" == ---* ]]
}

# Trouver le prochain index non-separateur
_next_selectable() {
    local idx=$1 dir=$2 total=$3
    local tries=0
    while [ $tries -lt $total ]; do
        idx=$(( (idx + dir + total) % total ))
        if ! _is_separator "${MENU_OPTS[$idx]}"; then
            echo $idx; return
        fi
        ((tries++))
    done
    echo $idx
}

# Dessiner le header
_draw_header() {
    local title="$1"
    local width=62
    local padded
    printf -v padded "%-${width}s" "$title"
    echo -e "${HDR}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║  ${padded}║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Banniere principale
_draw_banner() {
    echo -e "${HDR}"
    echo "  ██████╗  ██████╗██████╗ ██╗██████╗ ████████╗███████╗"
    echo "  ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝"
    echo "  ╚█████╗ ██║     ██████╔╝██║██████╔╝   ██║   ███████╗"
    echo "   ╚═══██╗██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║"
    echo "  ██████╔╝╚██████╗██║  ██║██║██║        ██║   ███████║"
    echo "  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝"
    echo -e "${GRY}  by AleexLeDev  —  Linux Edition v${VERSION}  —  ${total_tools} outils${NC}"
    echo ""
}

# AutoMenu : menu fleches avec MENU_OPTS defini avant l'appel
AutoMenu() {
    local title="$1"
    local total=${#MENU_OPTS[@]}
    local selected=0

    # Partir sur le premier element non-separateur
    while _is_separator "${MENU_OPTS[$selected]}" && [ $selected -lt $total ]; do
        ((selected++))
    done

    while true; do
        clear
        if [ "$title" = "MAIN" ]; then
            _draw_banner
        else
            _draw_header "$title"
        fi

        for i in "${!MENU_OPTS[@]}"; do
            local opt="${MENU_OPTS[$i]}"
            if _is_separator "$opt"; then
                echo -e "  ${SEP}  ${opt}${NC}"
            elif [ "$i" -eq "$selected" ]; then
                printf "  ${SEL} >> %-56s ${NC}\n" "$opt"
            else
                printf "  ${GRY}    %-56s ${NC}\n" "$opt"
            fi
        done

        echo ""
        echo -e "  ${GRY}[ ↑↓ Naviguer ]  [ Entree : Selectionner ]  [ Echap : Retour ]${NC}"

        # Lecture touche
        IFS= read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 seq
            if [[ -z "$seq" ]]; then
                # Echap seul (pas une sequence fleche)
                MENU_CHOICE=-1
                return 1
            fi
            case "$seq" in
                '[A') selected=$(_next_selectable $selected -1 $total) ;;
                '[B') selected=$(_next_selectable $selected  1 $total) ;;
            esac
        elif [[ "$key" == "" ]]; then
            MENU_CHOICE=$selected
            return 0
        fi
    done
}

# Pause standard
_pause() {
    echo ""
    echo -e "  ${GRY}[ Appuie sur Entree pour revenir... ]${NC}"
    IFS= read -rs
}

# Detecter le gestionnaire de paquets (multi-distro)
_detect_pm() {
    if   command -v apt    &>/dev/null; then echo "apt install"
    elif command -v dnf    &>/dev/null; then echo "dnf install"
    elif command -v pacman &>/dev/null; then echo "pacman -S"
    elif command -v zypper &>/dev/null; then echo "zypper install"
    elif command -v apk    &>/dev/null; then echo "apk add"
    else                                     echo "votre-pm install"
    fi
}

# Installer automatiquement un outil manquant
_require() {
    local cmd="$1" pkg="${2:-$1}"
    command -v "$cmd" &>/dev/null && return 0

    local pm
    pm=$(_detect_pm)
    echo -e "\n  ${YLW}[~] $cmd manquant — installation de $pkg...${NC}"

    case "$pm" in
        "apt install")
            echo -e "  ${GRY}Mise a jour de la liste des paquets...${NC}"
            apt-get update
            echo ""
            DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
            ;;
        "dnf install")    dnf install -y "$pkg" ;;
        "pacman -S")      pacman -S --noconfirm "$pkg" ;;
        "zypper install") zypper --non-interactive install "$pkg" ;;
        "apk add")        apk add "$pkg" ;;
        *)
            echo -e "  ${RED}[✗] Gestionnaire de paquets inconnu. Installe $pkg manuellement.${NC}"
            _pause; return 1
            ;;
    esac

    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GRN}[✓] $pkg installe avec succes.${NC}"
        sleep 1
        return 0
    else
        echo -e "  ${RED}[✗] Echec de l'installation de $pkg.${NC}"
        _pause; return 1
    fi
}

# ================================================================
#  CATEGORIE 1 : DIAGNOSTIC (13 outils)
# ================================================================

diag_sys_report() {
    clear
    _draw_header "RAPPORT SYSTEME COMPLET"

    echo -e "  ${YLW}[ OS & KERNEL ]${NC}"
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo -e "  Distribution : ${WHT}${PRETTY_NAME}${NC}"
    fi
    echo -e "  Kernel       : ${WHT}$(uname -r)${NC}"
    echo -e "  Archi        : ${WHT}$(uname -m)${NC}"

    echo -e "\n  ${YLW}[ CPU ]${NC}"
    local cpu_model cpu_cores cpu_threads cpu_mhz
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
    cpu_mhz=$(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs | cut -d. -f1)
    echo -e "  Modele       : ${WHT}${cpu_model}${NC}"
    echo -e "  Coeurs       : ${WHT}${cpu_cores}${NC}"
    echo -e "  Frequence    : ${WHT}${cpu_mhz} MHz${NC}"

    echo -e "\n  ${YLW}[ RAM ]${NC}"
    free -h | awk '
        NR==1 { next }
        NR==2 { printf "  Total : %s  |  Utilisee : %s  |  Libre : %s\n", $2, $3, $4 }
        NR==3 { printf "  Swap  : %s  |  Utilisee : %s  |  Libre : %s\n", $2, $3, $4 }
    '

    echo -e "\n  ${YLW}[ GPU ]${NC}"
    _require lspci pciutils
    lspci | grep -iE "vga|3d|display" | while IFS= read -r line; do
        echo -e "  ${WHT}${line}${NC}"
    done

    echo -e "\n  ${YLW}[ STOCKAGE ]${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done

    echo -e "\n  ${YLW}[ RESEAU ]${NC}"
    ip addr show 2>/dev/null | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1" | while IFS= read -r line; do
        echo "  $line"
    done

    echo -e "\n  ${YLW}[ UPTIME ]${NC}"
    echo -e "  $(uptime -p 2>/dev/null || uptime)"

    _pause
}

diag_sys_temp() {
    clear
    _draw_header "TEMPERATURES SYSTEME"

    _require sensors lm-sensors || return

    # Apres installation, configurer les capteurs automatiquement
    if ! sensors 2>/dev/null | grep -qE "[0-9]+\.[0-9]+°C"; then
        echo -e "  ${YLW}[~] Detection des capteurs (sensors-detect --auto)...${NC}"
        sensors-detect --auto 2>/dev/null | tail -5 | while IFS= read -r l; do echo "  $l"; done
        # Charger les modules detectes
        if [ -f /etc/modules-load.d/lm_sensors.conf ] || [ -f /etc/conf.d/lm_sensors ]; then
            systemctl restart kmod 2>/dev/null || modprobe -a 2>/dev/null || true
        fi
        echo ""
    fi

    local out
    out=$(sensors 2>/dev/null)
    if [ -n "$out" ]; then
        echo "$out" | while IFS= read -r line; do echo "  $line"; done
    else
        # Fallback /sys si sensors ne retourne rien
        echo -e "  ${YLW}[ Fallback : /sys/class/thermal ]${NC}"
        for zone in /sys/class/thermal/thermal_zone*/; do
            local ztype ztemp
            ztype=$(cat "$zone/type" 2>/dev/null || echo "?")
            ztemp=$(cat "$zone/temp" 2>/dev/null || echo "0")
            printf "  %-25s : ${WHT}%d°C${NC}\n" "$ztype" "$((ztemp / 1000))"
        done
    fi

    _pause
}

diag_ram_check() {
    clear
    _draw_header "ANALYSE MODULES RAM"

    _require dmidecode || return
    echo -e "  ${YLW}[ Slots memoire ]${NC}"
    dmidecode --type memory 2>/dev/null \
        | grep -E "Size|Type:|Speed|Manufacturer|Part Number|Locator|Form Factor" \
        | grep -v "No Module\|Unknown\|Not Specified" \
        | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Utilisation memoire ]${NC}"
    free -h | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Memoire virtuelle ]${NC}"
    vmstat -s 2>/dev/null | head -10 | while IFS= read -r line; do echo "  $line"; done

    _pause
}

diag_network() {
    clear
    _draw_header "DIAGNOSTIC RESEAU"

    echo -e "  ${YLW}[ Interfaces IP ]${NC}"
    ip addr show 2>/dev/null | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1" \
        | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Passerelle ]${NC}"
    ip route | grep default | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ DNS ]${NC}"
    if command -v resolvectl &>/dev/null; then
        resolvectl status 2>/dev/null | grep -i "DNS Servers" | while IFS= read -r line; do echo "  $line"; done
    else
        grep nameserver /etc/resolv.conf | while IFS= read -r line; do echo "  $line"; done
    fi

    echo -e "\n  ${YLW}[ Ping 8.8.8.8 ]${NC}"
    ping -c 3 8.8.8.8 2>&1 | tail -3 | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Ping 1.1.1.1 ]${NC}"
    ping -c 3 1.1.1.1 2>&1 | tail -3 | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Ports en ecoute (ss) ]${NC}"
    ss -tulpn 2>/dev/null | head -25 | while IFS= read -r line; do echo "  $line"; done

    _pause
}

diag_battery() {
    clear
    _draw_header "RAPPORT BATTERIE"

    local bat_path=""
    for p in /sys/class/power_supply/BAT*; do
        [ -d "$p" ] && bat_path="$p" && break
    done

    if [ -z "$bat_path" ]; then
        echo -e "  ${YLW}[!] Aucune batterie detectee (machine fixe ?)${NC}"
    else
        local status capacity energy_full energy_design
        status=$(cat "$bat_path/status" 2>/dev/null || echo "Inconnu")
        capacity=$(cat "$bat_path/capacity" 2>/dev/null || echo "?")
        energy_full=$(cat "$bat_path/energy_full" 2>/dev/null \
                   || cat "$bat_path/charge_full" 2>/dev/null || echo "0")
        energy_design=$(cat "$bat_path/energy_full_design" 2>/dev/null \
                     || cat "$bat_path/charge_full_design" 2>/dev/null || echo "0")

        # Couleur selon statut
        local scol="$WHT"
        [[ "$status" == "Discharging" ]] && scol="$YLW"
        [[ "$status" == "Charging" ]]    && scol="$GRN"
        [[ "$status" == "Full" ]]        && scol="$GRN"

        echo -e "  Statut   : ${scol}${status}${NC}"
        echo -e "  Charge   : ${BLD}${capacity}%${NC}"

        if [ "$energy_design" -gt 0 ] 2>/dev/null; then
            local health=$(( energy_full * 100 / energy_design ))
            local wear=$(( 100 - health ))
            echo -e "  Sante    : ${GRN}${health}%${NC} (usure : ${YLW}${wear}%${NC})"
        fi

        echo ""
        echo -e "  ${YLW}[ Fichiers systeme ]${NC}"
        for f in status capacity technology manufacturer model_name; do
            [ -f "$bat_path/$f" ] && printf "  %-20s : %s\n" "$f" "$(cat "$bat_path/$f" 2>/dev/null)"
        done
    fi

    _pause
}

diag_luks() {
    clear
    _draw_header "CHIFFREMENT DISQUES (LUKS)"

    echo -e "  ${YLW}[ Partitions chiffrees ]${NC}"
    lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINT,SIZE 2>/dev/null \
        | grep -iE "crypt|luks|dm" | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Mapper dm-crypt ]${NC}"
    ls /dev/mapper/ 2>/dev/null | while IFS= read -r line; do echo "  $line"; done

    echo -e "\n  ${YLW}[ Detection LUKS (blkid) ]${NC}"
    blkid 2>/dev/null | grep -i luks | while IFS= read -r line; do echo "  $line"; done \
        || echo -e "  ${GRN}Aucun volume LUKS detecte${NC}"

    echo -e "\n  ${YLW}[ Crypttab ]${NC}"
    if [ -f /etc/crypttab ]; then
        cat /etc/crypttab | while IFS= read -r line; do echo "  $line"; done
    else
        echo -e "  ${GRY}(pas de /etc/crypttab)${NC}"
    fi

    _pause
}

diag_journal() {
    clear
    _draw_header "JOURNAL ERREURS SYSTEME"

    echo -e "  ${YLW}[ 50 dernieres erreurs (journalctl) ]${NC}\n"
    journalctl -p err -n 50 --no-pager 2>/dev/null \
        | tail -45 | while IFS= read -r line; do
            echo -e "  ${RED}${line}${NC}"
        done

    _pause
}

diag_stress() {
    clear
    _draw_header "TEST DE CHARGE (STRESS-NG)"

    _require stress-ng || return

    MENU_OPTS=(
        "CPU seulement (30s)"
        "RAM seulement (30s)"
        "CPU + RAM (30s)"
        "--- Annuler"
    )
    AutoMenu "CHOISIR LE TEST" || return
    local choice=$MENU_CHOICE

    clear
    _draw_header "TEST EN COURS..."

    case $choice in
        0)
            echo -e "  ${YLW}Test CPU en cours (30s)...${NC}\n"
            stress-ng --cpu 0 --timeout 30s --metrics-brief 2>&1 \
                | while IFS= read -r line; do echo "  $line"; done
            ;;
        1)
            echo -e "  ${YLW}Test RAM en cours (30s)...${NC}\n"
            stress-ng --vm 1 --vm-bytes 75% --timeout 30s --metrics-brief 2>&1 \
                | while IFS= read -r line; do echo "  $line"; done
            ;;
        2)
            echo -e "  ${YLW}Test CPU + RAM en cours (30s)...${NC}\n"
            stress-ng --cpu 0 --vm 1 --vm-bytes 50% --timeout 30s --metrics-brief 2>&1 \
                | while IFS= read -r line; do echo "  $line"; done
            ;;
        *)  return ;;
    esac

    _pause
}

diag_av_status() {
    clear
    _draw_header "STATUT ANTIVIRUS (ClamAV)"

    _require clamscan "clamav clamav-daemon" || return

    echo -e "  ${GRN}[✓] ClamAV installe${NC}"
    clamscan --version 2>/dev/null | while IFS= read -r line; do echo "  $line"; done
    echo ""
    echo -e "  ${YLW}[ Service clamav-daemon ]${NC}"
    systemctl status clamav-daemon 2>/dev/null | head -12 \
        | while IFS= read -r line; do echo "  $line"; done

    _pause
}

diag_critical_events() {
    local period="$1" label="$2"
    clear
    _draw_header "ERREURS CRITIQUES ($label)"

    echo -e "  ${YLW}[ journalctl -p crit --since \"$period\" ]${NC}\n"
    local count
    count=$(journalctl -p crit --since "$period ago" --no-pager 2>/dev/null | wc -l)

    if [ "$count" -le 1 ]; then
        echo -e "  ${GRN}[✓] Aucune erreur critique sur la periode.${NC}"
    else
        journalctl -p crit --since "$period ago" --no-pager 2>/dev/null \
            | tail -50 | while IFS= read -r line; do
                echo -e "  ${RED}${line}${NC}"
            done
    fi

    _pause
}

diag_app_crashes() {
    clear
    _draw_header "CRASHS APPLICATIONS (24H)"

    echo -e "  ${YLW}[ Segfaults et crashs (24h) ]${NC}\n"
    local count
    count=$(journalctl -p err --since "24 hours ago" --no-pager 2>/dev/null \
        | grep -icE "segfault|crash|killed|core dump|exception" || true)

    if [ "${count:-0}" -eq 0 ]; then
        echo -e "  ${GRN}[✓] Aucun crash detecte dans les dernieres 24h.${NC}"
    else
        journalctl -p err --since "24 hours ago" --no-pager 2>/dev/null \
            | grep -iE "segfault|crash|killed|core dump|exception" \
            | tail -40 | while IFS= read -r line; do
                echo -e "  ${RED}${line}${NC}"
            done
    fi

    _pause
}

diag_disk_smart() {
    clear
    _draw_header "SANTE DISQUES (SMART)"

    _require smartctl smartmontools || return

    local disks
    mapfile -t disks < <(lsblk -dn -o NAME 2>/dev/null | grep -E "^sd|^nvme|^hd|^vd")

    if [ ${#disks[@]} -eq 0 ]; then
        echo -e "  ${YLW}Aucun disque compatible detecte.${NC}"
    fi

    for disk in "${disks[@]}"; do
        echo -e "  ${YLW}[ /dev/$disk ]${NC}"
        local result
        result=$(smartctl -H "/dev/$disk" 2>/dev/null | grep -E "SMART|result|health|overall" || true)
        if [ -n "$result" ]; then
            echo "$result" | while IFS= read -r line; do
                if echo "$line" | grep -qi "passed\|ok"; then
                    echo -e "  ${GRN}${line}${NC}"
                elif echo "$line" | grep -qi "failed\|error"; then
                    echo -e "  ${RED}${line}${NC}"
                else
                    echo "  $line"
                fi
            done
        else
            echo -e "  ${GRY}(acces impossible - essaie avec nvme-cli pour NVMe)${NC}"
        fi
        echo ""
    done

    _pause
}

# ================================================================
#  MENU CATEGORIE 1 : DIAGNOSTIC
# ================================================================
menu_diagnostic() {
    while true; do
        MENU_OPTS=(
            "Rapport Systeme Complet     — CPU, RAM, GPU, Stockage, Reseau"
            "Temperatures                — Capteurs thermiques (lm-sensors)"
            "Analyse RAM                 — Modules, slots, vitesse"
            "Diagnostic Reseau           — Ping, traceroute, ports"
            "Rapport Batterie            — Usure et autonomie"
            "Chiffrement Disque (LUKS)   — dm-crypt / LUKS"
            "Journal Erreurs             — journalctl errors"
            "Test de Charge              — stress-ng CPU/RAM"
            "Statut Antivirus            — ClamAV"
            "Erreurs Critiques 24h       — journalctl -p crit"
            "Erreurs Critiques 7j        — journalctl -p crit"
            "Crashs Applications 24h     — Segfaults et exceptions"
            "Sante Disques SMART         — smartctl health check"
            "--- Retour au menu principal"
        )
        AutoMenu "DIAGNOSTIC SYSTEME" || return

        case $MENU_CHOICE in
            0)  diag_sys_report ;;
            1)  diag_sys_temp ;;
            2)  diag_ram_check ;;
            3)  diag_network ;;
            4)  diag_battery ;;
            5)  diag_luks ;;
            6)  diag_journal ;;
            7)  diag_stress ;;
            8)  diag_av_status ;;
            9)  diag_critical_events "24 hours" "24H" ;;
            10) diag_critical_events "7 days" "7J" ;;
            11) diag_app_crashes ;;
            12) diag_disk_smart ;;
            13) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 2 : REPARATION (15 outils)
# ================================================================

rep_fsck() {
    clear
    _draw_header "VERIFICATION & REPARATION DISQUE (fsck)"

    echo -e "  ${YLW}[ Disques disponibles ]${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE | while IFS= read -r l; do echo "  $l"; done
    echo ""

    # Lister uniquement les partitions non montees
    local parts=()
    while IFS= read -r dev; do
        local mnt
        mnt=$(lsblk -no MOUNTPOINT "/dev/$dev" 2>/dev/null)
        [ -z "$mnt" ] && parts+=("/dev/$dev")
    done < <(lsblk -lno NAME,TYPE | awk '$2=="part"{print $1}')

    if [ ${#parts[@]} -eq 0 ]; then
        echo -e "  ${YLW}[!] Aucune partition demontee trouvee.${NC}"
        echo -e "  ${GRY}    fsck ne peut pas tourner sur une partition montee.${NC}"
        echo -e "  ${GRY}    Pour reparer la partition root : relance en mode recovery.${NC}"
        _pause; return
    fi

    MENU_OPTS=()
    for p in "${parts[@]}"; do
        local fstype size
        fstype=$(blkid -o value -s TYPE "$p" 2>/dev/null || echo "?")
        size=$(lsblk -no SIZE "$p" 2>/dev/null || echo "?")
        MENU_OPTS+=("$p  [$fstype]  $size")
    done
    MENU_OPTS+=("--- Annuler")
    AutoMenu "CHOISIR LA PARTITION A VERIFIER" || return

    local idx=$MENU_CHOICE
    [ $idx -ge ${#parts[@]} ] && return
    local target="${parts[$idx]}"

    clear
    _draw_header "fsck SUR $target"
    echo -e "  ${YLW}Verification en cours...${NC}\n"
    fsck -V -y "$target" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Termine.${NC}"
    _pause
}

rep_pkg_fix() {
    clear
    _draw_header "REPARATION PAQUETS CASSES"

    echo -e "  ${YLW}[1/3] Configuration des paquets non configures...${NC}\n"
    dpkg --configure -a 2>&1 | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[2/3] Reparation des dependances cassees...${NC}\n"
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y 2>&1 | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[3/3] Verification finale...${NC}\n"
    dpkg -l | grep -E "^.H|^.F|^.U" | while IFS= read -r l; do
        echo -e "  ${RED}$l${NC}"
    done || echo -e "  ${GRN}[✓] Aucun paquet en etat anormal.${NC}"

    _pause
}

rep_dpkg_fix() {
    clear
    _draw_header "REPARATION DPKG BLOQUE"

    echo -e "  ${YLW}[~] Suppression des verrous dpkg/apt...${NC}"
    local locks=(
        /var/lib/dpkg/lock
        /var/lib/dpkg/lock-frontend
        /var/cache/apt/archives/lock
        /var/lib/apt/lists/lock
    )
    for f in "${locks[@]}"; do
        if [ -f "$f" ]; then
            rm -f "$f"
            echo -e "  ${GRN}[✓] Supprime : $f${NC}"
        fi
    done

    echo -e "\n  ${YLW}[~] Reconstruction de la base dpkg...${NC}\n"
    dpkg --configure -a 2>&1 | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[~] Mise a jour des listes...${NC}\n"
    apt-get update 2>&1 | tail -5 | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${GRN}[✓] DPKG repare.${NC}"
    _pause
}

rep_net_reset() {
    clear
    _draw_header "REINITIALISATION RESEAU"

    echo -e "  ${YLW}[1/4] Arret NetworkManager...${NC}"
    systemctl stop NetworkManager 2>&1 | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[2/4] Vidage cache DNS...${NC}"
    if command -v resolvectl &>/dev/null; then
        resolvectl flush-caches 2>/dev/null && echo -e "  ${GRN}[✓] Cache DNS vide (systemd-resolved)${NC}"
    fi
    systemd-resolve --flush-caches 2>/dev/null || true

    echo -e "\n  ${YLW}[3/4] Reinitialisation interfaces...${NC}"
    for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -vE "^lo$"); do
        ip link set "$iface" down 2>/dev/null && ip link set "$iface" up 2>/dev/null
        echo -e "  ${GRY}  Interface $iface reinitalisee${NC}"
    done

    echo -e "\n  ${YLW}[4/4] Redemarrage NetworkManager...${NC}"
    systemctl start NetworkManager 2>&1 | while IFS= read -r l; do echo "  $l"; done
    sleep 2

    echo -e "\n  ${YLW}[ Etat apres reset ]${NC}"
    ip addr show | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1" | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${GRN}[✓] Reseau reinitialise.${NC}"
    _pause
}

rep_desktop() {
    clear
    _draw_header "REDEMARRAGE ENVIRONNEMENT DE BUREAU"

    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-inconnu}}"
    echo -e "  Bureau detecte : ${WHT}${de}${NC}\n"

    case "${de,,}" in
        *gnome*)
            echo -e "  ${YLW}[~] Redemarrage GNOME Shell...${NC}"
            if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
                killall -HUP gnome-shell 2>/dev/null \
                    && echo -e "  ${GRN}[✓] GNOME Shell redémarre.${NC}" \
                    || echo -e "  ${YLW}[!] Impossible de redémarrer (Wayland ?). Deconnecte/reconnecte ta session.${NC}"
            fi
            ;;
        *kde*|*plasma*)
            echo -e "  ${YLW}[~] Redemarrage KDE Plasma...${NC}"
            systemctl --user restart plasma-plasmashell 2>/dev/null \
                || kquitapp5 plasmashell 2>/dev/null && sleep 1 && kstart5 plasmashell 2>/dev/null &
            echo -e "  ${GRN}[✓] Plasma redémarre.${NC}"
            ;;
        *xfce*)
            echo -e "  ${YLW}[~] Redemarrage XFCE...${NC}"
            xfce4-session-logout --reboot 2>/dev/null || xfwm4 --replace 2>/dev/null &
            echo -e "  ${GRN}[✓] XFCE redémarre.${NC}"
            ;;
        *)
            echo -e "  ${YLW}[!] Bureau non reconnu automatiquement.${NC}"
            echo -e "  ${GRY}  Solutions manuelles :${NC}"
            echo -e "  ${CYN}  GNOME  : killall -HUP gnome-shell${NC}"
            echo -e "  ${CYN}  KDE    : systemctl --user restart plasma-plasmashell${NC}"
            echo -e "  ${CYN}  XFCE   : xfwm4 --replace${NC}"
            echo -e "  ${CYN}  Tous   : sudo systemctl restart display-manager${NC}"
            ;;
    esac

    _pause
}

rep_display_manager() {
    clear
    _draw_header "REDEMARRAGE DISPLAY MANAGER (GDM/SDDM/LightDM)"

    echo -e "  ${YLW}[ Display manager actif ]${NC}"
    local dm
    dm=$(systemctl status display-manager 2>/dev/null | grep "Loaded:" | grep -o '[^/]*\.service' | head -1)
    echo -e "  ${WHT}${dm:-inconnu}${NC}"
    echo ""
    echo -e "  ${RED}[!] ATTENTION : cela va fermer ta session graphique.${NC}"
    echo ""

    MENU_OPTS=("Confirmer le redemarrage" "--- Annuler")
    AutoMenu "REDEMARRER LE DISPLAY MANAGER ?" || return
    [ $MENU_CHOICE -ne 0 ] && return

    systemctl restart display-manager 2>&1 | while IFS= read -r l; do echo "  $l"; done
    _pause
}

rep_timeshift() {
    clear
    _draw_header "POINT DE RESTAURATION (TIMESHIFT)"

    _require timeshift || return

    echo -e "  ${YLW}[ Snapshots existants ]${NC}"
    timeshift --list 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo ""

    MENU_OPTS=(
        "Creer un nouveau snapshot"
        "Restaurer un snapshot existant"
        "Supprimer un snapshot"
        "--- Annuler"
    )
    AutoMenu "TIMESHIFT" || return

    case $MENU_CHOICE in
        0)
            echo -e "\n  ${YLW}[~] Creation du snapshot...${NC}\n"
            timeshift --create --comments "Scripts-AleexLeDev $(date +%Y-%m-%d)" 2>&1 \
                | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${GRN}[✓] Snapshot cree.${NC}"
            ;;
        1)
            echo -e "\n  ${YLW}Lance timeshift-gtk pour une restauration graphique...${NC}"
            timeshift-gtk 2>/dev/null & sleep 1
            ;;
        2)
            echo -e "\n  ${YLW}Lance timeshift-gtk pour supprimer un snapshot...${NC}"
            timeshift-gtk 2>/dev/null & sleep 1
            ;;
        *) return ;;
    esac
    _pause
}

rep_grub() {
    clear
    _draw_header "MISE A JOUR GRUB"

    local pm
    pm=$(_detect_pm)

    echo -e "  ${YLW}[~] Mise a jour de la configuration GRUB...${NC}\n"

    if command -v update-grub &>/dev/null; then
        update-grub 2>&1 | while IFS= read -r l; do echo "  $l"; done
    elif command -v grub2-mkconfig &>/dev/null; then
        grub2-mkconfig -o /boot/grub2/grub.cfg 2>&1 | while IFS= read -r l; do echo "  $l"; done
    elif command -v grub-mkconfig &>/dev/null; then
        grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | while IFS= read -r l; do echo "  $l"; done
    else
        echo -e "  ${YLW}[!] Commande GRUB non trouvee.${NC}"
        echo -e "      Installe avec : ${CYN}sudo $pm grub2-common${NC}"
        _pause; return
    fi

    echo -e "\n  ${GRN}[✓] GRUB mis a jour.${NC}"
    _pause
}

rep_initramfs() {
    clear
    _draw_header "RECONSTRUCTION INITRAMFS"

    echo -e "  ${YLW}[~] Reconstruction en cours...${NC}\n"

    if command -v update-initramfs &>/dev/null; then
        update-initramfs -u -k all 2>&1 | while IFS= read -r l; do echo "  $l"; done
    elif command -v mkinitcpio &>/dev/null; then
        mkinitcpio -P 2>&1 | while IFS= read -r l; do echo "  $l"; done
    elif command -v dracut &>/dev/null; then
        dracut --force 2>&1 | while IFS= read -r l; do echo "  $l"; done
    else
        echo -e "  ${YLW}[!] Outil initramfs non trouve sur ce systeme.${NC}"
        _pause; return
    fi

    echo -e "\n  ${GRN}[✓] initramfs reconstruit.${NC}"
    _pause
}

rep_services() {
    clear
    _draw_header "REPARATION SERVICES SYSTEMD ECHOUES"

    echo -e "  ${YLW}[ Services en echec ]${NC}\n"
    local failed
    failed=$(systemctl list-units --state=failed --no-legend 2>/dev/null)

    if [ -z "$failed" ]; then
        echo -e "  ${GRN}[✓] Aucun service en echec.${NC}"
        _pause; return
    fi

    echo "$failed" | while IFS= read -r l; do echo -e "  ${RED}$l${NC}"; done
    echo ""

    MENU_OPTS=(
        "Reinitialiser tous les services echoues (reset-failed)"
        "Voir les logs du premier service en echec"
        "--- Annuler"
    )
    AutoMenu "ACTION" || return

    case $MENU_CHOICE in
        0)
            systemctl reset-failed 2>&1
            echo -e "  ${GRN}[✓] Services reinitialises.${NC}"
            ;;
        1)
            local svc
            svc=$(echo "$failed" | head -1 | awk '{print $1}')
            echo -e "\n  ${YLW}[ Logs : $svc ]${NC}\n"
            journalctl -u "$svc" -n 40 --no-pager 2>/dev/null \
                | while IFS= read -r l; do echo "  $l"; done
            ;;
        *) return ;;
    esac
    _pause
}

rep_permissions() {
    clear
    _draw_header "CORRECTION DES PERMISSIONS"

    local user="${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}"
    local home="/home/$user"

    echo -e "  ${YLW}[ Utilisateur : $user | Home : $home ]${NC}\n"

    MENU_OPTS=(
        "Corriger permissions du dossier home ($user)"
        "Corriger permissions /tmp"
        "Corriger permissions SSH (~/.ssh)"
        "Corriger permissions sudo (/etc/sudoers.d)"
        "Tout corriger"
        "--- Annuler"
    )
    AutoMenu "CORRECTION PERMISSIONS" || return

    _fix_home() {
        echo -e "  ${YLW}[~] Correction home...${NC}"
        chown -R "$user:$user" "$home" 2>/dev/null
        chmod 750 "$home"
        echo -e "  ${GRN}[✓] $home : chown $user + chmod 750${NC}"
    }
    _fix_tmp() {
        echo -e "  ${YLW}[~] Correction /tmp...${NC}"
        chmod 1777 /tmp
        echo -e "  ${GRN}[✓] /tmp : chmod 1777${NC}"
    }
    _fix_ssh() {
        local sshdir="$home/.ssh"
        if [ -d "$sshdir" ]; then
            echo -e "  ${YLW}[~] Correction ~/.ssh...${NC}"
            chown -R "$user:$user" "$sshdir"
            chmod 700 "$sshdir"
            chmod 600 "$sshdir"/* 2>/dev/null || true
            [ -f "$sshdir/authorized_keys" ] && chmod 644 "$sshdir/authorized_keys"
            [ -f "$sshdir/config" ]          && chmod 600 "$sshdir/config"
            echo -e "  ${GRN}[✓] ~/.ssh : 700 | cles : 600${NC}"
        else
            echo -e "  ${GRY}  Pas de dossier ~/.ssh${NC}"
        fi
    }
    _fix_sudoers() {
        echo -e "  ${YLW}[~] Correction /etc/sudoers.d...${NC}"
        chmod 750 /etc/sudoers.d 2>/dev/null
        chmod 440 /etc/sudoers.d/* 2>/dev/null || true
        echo -e "  ${GRN}[✓] /etc/sudoers.d : 750 | fichiers : 440${NC}"
    }

    echo ""
    case $MENU_CHOICE in
        0) _fix_home ;;
        1) _fix_tmp ;;
        2) _fix_ssh ;;
        3) _fix_sudoers ;;
        4) _fix_home; _fix_tmp; _fix_ssh; _fix_sudoers ;;
        *) return ;;
    esac

    _pause
}

rep_hosts() {
    clear
    _draw_header "REINITIALISATION /etc/hosts"

    echo -e "  ${YLW}[ Contenu actuel ]${NC}"
    cat /etc/hosts | while IFS= read -r l; do echo "  $l"; done
    echo ""

    MENU_OPTS=(
        "Reinitialiser au contenu par defaut"
        "--- Annuler"
    )
    AutoMenu "/etc/hosts" || return
    [ $MENU_CHOICE -ne 0 ] && return

    local hostname
    hostname=$(hostname)
    cp /etc/hosts /etc/hosts.bak.$(date +%Y%m%d_%H%M%S)
    echo -e "  ${GRY}[~] Backup cree : /etc/hosts.bak.*${NC}\n"

    cat > /etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       ${hostname}
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

    echo -e "  ${GRN}[✓] /etc/hosts reinitialise.${NC}"
    cat /etc/hosts | while IFS= read -r l; do echo "  $l"; done
    _pause
}

rep_locale() {
    clear
    _draw_header "REPARATION LOCALES"

    echo -e "  ${YLW}[ Locales actuelles ]${NC}"
    locale 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo ""

    echo -e "  ${YLW}[~] Generation des locales...${NC}\n"
    if command -v locale-gen &>/dev/null; then
        locale-gen 2>&1 | while IFS= read -r l; do echo "  $l"; done
    fi

    if command -v dpkg-reconfigure &>/dev/null; then
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 2>&1 \
            | while IFS= read -r l; do echo "  $l"; done
    fi

    echo -e "\n  ${YLW}[ Verification ]${NC}"
    locale 2>&1 | grep -v "^$" | while IFS= read -r l; do
        if echo "$l" | grep -q "cannot set"; then
            echo -e "  ${RED}$l${NC}"
        else
            echo -e "  ${GRN}$l${NC}"
        fi
    done

    _pause
}

rep_font_cache() {
    clear
    _draw_header "RECONSTRUCTION CACHE POLICES"

    echo -e "  ${YLW}[~] Reconstruction en cours...${NC}\n"
    fc-cache -fv 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Cache polices reconstruit.${NC}"
    _pause
}

rep_ssh_fix() {
    clear
    _draw_header "REPARATION SERVICE SSH"

    echo -e "  ${YLW}[ Statut sshd ]${NC}"
    systemctl status sshd 2>/dev/null | head -8 | while IFS= read -r l; do echo "  $l"; done
    echo ""

    MENU_OPTS=(
        "Redemarrer le service SSH"
        "Regenerer les cles hotes SSH"
        "Verifier la configuration sshd_config"
        "--- Annuler"
    )
    AutoMenu "REPARATION SSH" || return

    case $MENU_CHOICE in
        0)
            systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
            echo -e "  ${GRN}[✓] SSH redemarre.${NC}"
            ;;
        1)
            echo -e "  ${YLW}[~] Suppression des anciennes cles...${NC}"
            rm -f /etc/ssh/ssh_host_*
            echo -e "  ${YLW}[~] Generation des nouvelles cles...${NC}"
            dpkg-reconfigure openssh-server 2>/dev/null \
                || ssh-keygen -A 2>&1 | while IFS= read -r l; do echo "  $l"; done
            systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
            echo -e "  ${GRN}[✓] Cles SSH regenerees.${NC}"
            ;;
        2)
            echo -e "\n  ${YLW}[ /etc/ssh/sshd_config ]${NC}"
            sshd -t 2>&1 | while IFS= read -r l; do echo -e "  ${RED}$l${NC}"; done \
                && echo -e "  ${GRN}[✓] Configuration valide.${NC}"
            ;;
        *) return ;;
    esac
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 2 : REPARATION
# ----------------------------------------------------------------
menu_reparation() {
    while true; do
        MENU_OPTS=(
            "Verification Disque (fsck)          — Reparer le filesystem"
            "Reparer Paquets Casses              — apt --fix-broken"
            "Reparer DPKG Bloque                 — Verrous et base dpkg"
            "Reinitialiser Reseau                — NetworkManager + DNS + IP"
            "Redemarrer Bureau                   — GNOME / KDE / XFCE"
            "Redemarrer Display Manager          — GDM / SDDM / LightDM"
            "Point de Restauration               — Timeshift snapshot"
            "Mettre a jour GRUB                  — update-grub / grub2-mkconfig"
            "Reconstruire initramfs              — update-initramfs / mkinitcpio"
            "Reparer Services Systemd            — reset-failed + logs"
            "Corriger Permissions                — home / tmp / ssh / sudoers"
            "Reinitialiser /etc/hosts            — Reset au fichier par defaut"
            "Reparer Locales                     — locale-gen + dpkg-reconfigure"
            "Reconstruire Cache Polices          — fc-cache -fv"
            "Reparer SSH                         — cles, config, service"
            "--- Retour au menu principal"
        )
        AutoMenu "REPARATION SYSTEME" || return

        case $MENU_CHOICE in
            0)  rep_fsck ;;
            1)  rep_pkg_fix ;;
            2)  rep_dpkg_fix ;;
            3)  rep_net_reset ;;
            4)  rep_desktop ;;
            5)  rep_display_manager ;;
            6)  rep_timeshift ;;
            7)  rep_grub ;;
            8)  rep_initramfs ;;
            9)  rep_services ;;
            10) rep_permissions ;;
            11) rep_hosts ;;
            12) rep_locale ;;
            13) rep_font_cache ;;
            14) rep_ssh_fix ;;
            15) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  PLACEHOLDER CATEGORIES 3-10 (a developper)
# ================================================================
_wip() {
    local cat="$1"
    clear
    _draw_header "$cat — EN COURS DE DEVELOPPEMENT"
    echo -e "  ${YLW}Cette categorie sera implementee dans la prochaine etape.${NC}"
    _pause
}

# ================================================================
#  MENU PRINCIPAL
# ================================================================
menu_principal() {
    while true; do
        MENU_OPTS=(
            " 1. DIAGNOSTIC          — Sante systeme, temperatures, reseau"
            " 2. REPARATION          — fsck, paquets, reseau, GRUB"
            " 3. NETTOYAGE           — Cache, logs, corbeille, orphelins"
            " 4. RESEAU & CYBER      — DNS, scan LAN, WiFi, pentest"
            " 5. DISQUE              — Partitions, SMART, benchmark"
            " 6. APPLICATIONS        — MAJ, installation, nettoyage"
            " 7. COMPTES & SECURITE  — Utilisateurs, mots de passe"
            " 8. EXTRACTION          — Inventaire, export, backup"
            " 9. PERSONNALISATION    — Theme, aliases, performance"
            "10. MATERIEL            — CPU, GPU, RAM, USB, gouverneur"
            "--- ──────────────────────────────────────────"
            "    Quitter"
        )
        AutoMenu "MAIN"

        case $MENU_CHOICE in
            0)  menu_diagnostic ;;
            1)  menu_reparation ;;
            2)  _wip "NETTOYAGE & OPTIMISATION" ;;
            3)  _wip "RESEAU & CYBER" ;;
            4)  _wip "DISQUE" ;;
            5)  _wip "APPLICATIONS" ;;
            6)  _wip "COMPTES & SECURITE" ;;
            7)  _wip "EXTRACTION & SAUVEGARDE" ;;
            8)  _wip "PERSONNALISATION" ;;
            9)  _wip "MATERIEL" ;;
            11) clear; echo -e "${CYN}Au revoir !${NC}"; exit 0 ;;
            *)  clear; echo -e "${CYN}Au revoir !${NC}"; exit 0 ;;
        esac
    done
}

# ================================================================
#  ENTRYPOINT
# ================================================================
menu_principal
