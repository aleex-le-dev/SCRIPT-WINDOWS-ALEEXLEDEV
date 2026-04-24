#!/usr/bin/env bash
# ==============================================================
#  Scripts-by-AleexLeDev - Linux Edition v1.0
#  Equivalent Linux du toolkit Windows (10 categories, 167 outils)
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
t[2]="sys_temp_report:Rapport de Temperature~Capteurs CPU et GPU (lm-sensors)"
t[3]="sys_ram_check:Test de Memoire RAM~Modules, slots, vitesse (dmidecode)"
t[4]="sys_diag_network:Diagnostic Reseau~Ping, traceroute, ports ouverts"
t[5]="sys_battery_report:Rapport Batterie~Usure et autonomie estimee"
t[6]="sys_bitlocker_check:Etat Chiffrement Disque~Verification LUKS / dm-crypt"
t[7]="sys_event_log:Journal des Erreurs~Evenements critiques (journalctl)"
t[8]="sys_hw_test:Test Materiel~CPU/RAM stress test (stress-ng)"
t[9]="sys_defender:Etat Antivirus~ClamAV / protection active"
t[10]="ev_critical_24h:Erreurs Critiques 24h~Evenements critiques 24 dernieres heures"
t[11]="ev_critical_7d:Erreurs Critiques 7 jours~Evenements critiques 7 derniers jours"
t[12]="ev_app_24h:Erreurs Applications 24h~Crashs et segfaults recents"
t[13]="ev_disk_warn:Alertes Disque~smartctl health check"

# --- CATEGORIE 2 : REPARATION ---
t[16]="res_chkdsk:Verification Disque~fsck sur les partitions non montees"
t[17]="res_sfc:Reparer Paquets~apt --fix-broken + dpkg --configure -a"
t[18]="res_dism:Reparer DPKG Bloque~Verrous dpkg/apt + reconstruction base"
t[19]="res_net_reset:Reinitialiser Reseau~NetworkManager + DNS + interfaces"
t[20]="res_explorer_restart:Redemarrer Bureau~GNOME Shell / KDE Plasma / XFCE"
t[21]="res_display_manager:Redemarrer Display Manager~GDM / SDDM / LightDM"
t[22]="res_restore_point:Point de Restauration~Snapshot Timeshift"
t[23]="res_grub:Mise a jour GRUB~update-grub / grub2-mkconfig / grub-mkconfig"
t[24]="res_initramfs:Reconstruire initramfs~update-initramfs / mkinitcpio / dracut"
t[25]="res_services:Reparer Services Systemd~reset-failed + logs services"
t[26]="res_permissions:Corriger Permissions~home / tmp / ssh / sudoers"
t[27]="res_hosts:Reinitialiser /etc/hosts~Reset au fichier par defaut"
t[28]="res_locale:Reparer Locales~locale-gen + dpkg-reconfigure"
t[29]="res_font_cache:Cache Polices~fc-cache -fv reconstruction"
t[30]="res_ssh_fix:Reparer SSH~Cles hotes, config, service sshd"
t[31]="sys_repair_icons:Reparation Cache Icones~Corrige les icones et miniatures corrompues"
t[32]="res_dism_check:Verifier Integrite Systeme~debsums - controle des paquets"
t[33]="res_dism_restore:Restaurer Integrite Systeme~Reinstaller les paquets corrompus"
t[34]="res_wu_reset:Reset Mises a Jour~Reinitialiser verrous et listes APT"
t[35]="res_gpu_reset:Reinitialiser le GPU~Rechargement du module pilote"
t[36]="winre_bios:Redemarrer vers le BIOS~Acces au firmware UEFI"
t[150]="winre_safe_minimal:Mode Sans Echec~GRUB recovery mode"
t[151]="winre_status:Statut Boot~Noyaux, GRUB, EFI / BIOS"
t[152]="winre_reset:Reinitialiser Options Demarrage~Restaurer GRUB par defaut"

# --- CATEGORIE 3 : NETTOYAGE & OPTIMISATION ---
t[37]="cl_all:Nettoyage Complet~Tout nettoyer en une fois"
t[38]="cl_apt:Cache APT~autoremove + autoclean + clean"
t[39]="cl_temp:Fichiers Temporaires~/tmp, /var/tmp, ~/.cache"
t[40]="cl_dns:Cache DNS~systemd-resolved flush-caches"
t[41]="cl_logs:Anciens Logs~journalctl vacuum + /var/log"
t[42]="cl_trash:Corbeille~Vider la corbeille utilisateur"
t[43]="cl_orphans:Paquets Orphelins~autoremove avec confirmation"
t[44]="cl_browser:Caches Navigateurs~Firefox, Chrome, Brave, Opera..."
t[45]="cl_snap:Anciennes Versions Snap~Revisions desactivees"
t[46]="cl_pip_npm:Caches Pip/NPM/Yarn~Outils de developpement"
t[47]="sys_startup:Gestionnaire Demarrage~Activer/desactiver services systemd"
t[48]="sys_tweaks:Optimisations Systeme~Swappiness, CPU governor, IPv6"

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
t[74]="disk_usage:Utilisation Disque~df -h + top 15 dossiers lourds"
t[75]="disk_smart:Sante SMART~Rapport complet smartctl par disque"
t[76]="disk_manager:Gestionnaire Disque~format, fsck, mount, fdisk"
t[77]="disk_bench:Benchmark I/O~Test lecture/ecriture dd + hdparm"
t[78]="disk_wipe:Effacement Securise~shred 1/3/7 passes"

# --- CATEGORIE 6 : APPLICATIONS ---
t[80]="app_update:Mise a jour Tout~apt + snap + flatpak + pip"
t[81]="app_list:Liste Applications~APT / Snap / Flatpak"
t[82]="app_search:Rechercher un Paquet~apt-cache + snap + flatpak"
t[83]="app_install:Installateur Rapide~Browsers, Dev, Media, Bureautique..."
t[84]="app_remove:Supprimer une App~apt remove / purge + autoremove"
t[85]="app_info:Infos Paquet~apt-cache show + dpkg -L"
t[86]="app_snap_mgr:Gestionnaire Snap~list, update, remove, revisions"
t[87]="app_flatpak_mgr:Gestionnaire Flatpak~list, update, remove, flathub"

# --- CATEGORIE 7 : COMPTES & SECURITE ---
t[200]="pw_menu:Menu Mots de Passe~Extraction et gestion"
t[201]="pw_wifi:Export WiFi~Mots de passe WiFi sauvegardes"
t[202]="dump_browser:MDP Navigateur~Firefox / Chromium (profils)"
t[203]="gather_browser_history:Historique Navigateur~Firefox / Chrome / Chromium"
t[204]="search_sensitive_docs:Fichiers Sensibles~Scanner documents confidentiels"
t[90]="um_menu:Gestion Utilisateurs~Lister, creer, supprimer comptes"
t[91]="um_add:Creer Utilisateur~Nouveau compte avec groupe"
t[92]="um_del:Supprimer Utilisateur~Suppression compte + home"
t[93]="um_reset:Changer Mot de Passe~Modifier mdp utilisateur"
t[94]="um_admin:Droits Sudo~Gerer privileges sudo"
t[95]="sys_eicar:Test EICAR~Verifier reponse antivirus (safe)"
t[205]="um_list:Lister Utilisateurs~Afficher tous les comptes locaux"
t[206]="um_remove_pwd:Supprimer le Mot de Passe~Auto-login sans mot de passe"
t[207]="um_superadmin:Super Administrateur~Activer ou desactiver le compte root"
t[208]="wd_quick:Scan Rapide ClamAV~Analyse de securite rapide (home)"
t[209]="wd_full:Scan Complet ClamAV~Analyse totale du systeme"
t[210]="wd_update:Mettre a jour ClamAV~Signatures de virus (freshclam)"
t[211]="wd_status:Statut ClamAV~Protection active ou non"

# --- CATEGORIE 8 : EXTRACTION & SAUVEGARDE ---
t[110]="sys_hw_export:Info Materiel~lshw - inventaire complet"
t[111]="sys_drivers:Modules Kernel~Pilotes et modules charges"
t[112]="sys_export_software:Exporter Liste Apps~Export paquets installes"
t[113]="dump_wifi:Exporter Profils WiFi~Backup configurations WiFi"
t[114]="sys_loot_all:Extraction Complete~WiFi + historique + comptes"
t[115]="sys_export_dotfiles:Sauvegarder Config~Dotfiles et configurations"
t[116]="sys_win_key:Cle de Licence~Machine ID et cle ACPI MSDM"
t[117]="sys_export_wifi_apps:Export WiFi et Apps~Profils reseau et logiciels"
t[118]="scan_web_routes:Audit Routes Web~Detecte .env, wp-config, /admin exposes"

# --- CATEGORIE 9 : PERSONNALISATION ---
t[165]="sys_theme:Theme Systeme~GNOME/KDE/XFCE dark/light mode"
t[166]="sys_aliases:Alias Bash~Ajouter ~20 alias utiles dans .bashrc"
t[167]="sys_gaming_mode:Mode Gaming~CPU perf + reseau + GameMode"
t[168]="sys_hostname:Changer Hostname~hostnamectl + /etc/hosts"
t[169]="sys_prompt:Personnaliser Prompt~Style PS1 avec git branch"
t[170]="sys_autostart:Apps au Demarrage~Gestion autostart de session"
t[171]="context_menu:Menu Contextuel~Scripts clic-droit Nautilus/Thunar"
t[172]="sys_god_mode:Dossier God Mode~Raccourci ultime des parametres"
t[173]="sys_shortcuts_bureau:Raccourcis Bureau~Redemarrer / Eteindre / Veille"
t[174]="photo_viewer_toggle:Visionneuse d Images~Changer la visionneuse par defaut"
t[175]="list_folder_menu:Lister et Rechercher~Arborescence et recherche par extensions"

# --- CATEGORIE 10 : MATERIEL ---
t[124]="hw_full_report:Rapport Materiel Complet~lshw -short"
t[125]="hw_cpu:Infos CPU~Frequence, coeurs, temp, governor par coeur"
t[126]="hw_gpu:Infos GPU~Detection + NVIDIA nvidia-smi + OpenGL"
t[127]="hw_ram:Infos RAM~Slots dmidecode + usage + top procs"
t[128]="hw_smart:Infos Disques~lsblk + SMART summary par disque"
t[129]="hw_usb:Peripheriques USB~lsusb + arbre"
t[130]="hw_pci:Peripheriques PCI~lspci -v"
t[131]="hw_audio:Audio~ALSA + PulseAudio/PipeWire"
t[132]="hw_bluetooth:Bluetooth~Controleurs + appareils appaires"
t[133]="pp_high:Mode Performance~CPU governor = performance"
t[134]="pp_balanced:Mode Equilibre~CPU governor = ondemand"
t[135]="pp_saver:Mode Economie~CPU governor = powersave"
t[136]="pp_current:Plan Actuel~Afficher governor + frequences par coeur"
t[137]="touch_screen_manager:Gestionnaire Ecran Tactile~Activer / Desactiver xinput"
t[138]="sys_print_manager:Gestionnaire d Imprimantes~CUPS / lpstat / file d attente"
t[139]="hw_winsat:Score de Performances~sysbench CPU, RAM, I/O"
t[140]="hw_ram_test:Test RAM~memtester - diagnostic memoire"

# ── Entrees Windows manquantes (aliases implementes) ─────────────
# DIAGNOSTIC
t[300]="sys_diagnostic_menu:Analyse et Diagnostic Systeme~13 outils CPU, RAM, Reseau:HIDDEN"
# REPARATION
t[301]="sys_rescue_menu:Outil Reparation Systeme~SFC, DISM, CHKDSK, WU Reset:HIDDEN"
t[302]="sys_winre:Mode Demarrage GRUB~Options boot avancees:HIDDEN"
t[303]="winre_boot:Redemarrer~Redemarrage avec confirmation:HIDDEN"
t[304]="winre_bootmenu:Menu Boot GRUB~GRUB_TIMEOUT=10 afficher menu:HIDDEN"
t[305]="winre_safe_network:Mode Sans Echec Reseau~Instructions GRUB recovery reseau:HIDDEN"
t[306]="winre_safe_cmd:Mode Sans Echec Terminal~Shell root GRUB recovery:HIDDEN"
t[307]="winre_nosign:Desactiver Signature Pilote~mokutil / modprobe:HIDDEN"
# NETTOYAGE
t[308]="sys_opti_menu:Nettoyeur et Optimiseur Systeme~Menu optimisation complet:HIDDEN"
t[309]="sys_clean_unified:Tout Nettoyer d un Coup~Nettoyage automatique complet:HIDDEN"
t[310]="sys_registry_cleanup:Nettoyer Paquets Orphelins~Cles orphelines APT:HIDDEN"
t[311]="sys_tweaks_menu:Optimisations Systeme~Swappiness, governor, IPv6:HIDDEN"
t[312]="sys_startup_manager:Gestionnaire Demarrage~Activer/desactiver services:HIDDEN"
t[313]="cl_wu:Nettoyage Cache APT~autoremove + autoclean + clean:HIDDEN"
t[314]="cl_disk:Nettoyage Disque~Orphelins + snap + cache dev:HIDDEN"
t[315]="cl_clipboard:Vider Presse-papiers~xclip / xdotool clear:HIDDEN"
t[316]="sys_power_plan:Gestionnaire Plan Alimentation~Equilibre / Performance / Economie:HIDDEN"
# RESEAU
t[317]="sys_network_menu:Menu Depannage Reseau~Outils avances DNS, ARP, TCP/IP:HIDDEN"
t[318]="net_cyber_menu:Scanner Failles et Pentest~Vulnerabilites Web et Reseau:HIDDEN"
t[319]="show_dns_config:Affichage Config DNS~Voir configuration DNS actuelle:HIDDEN"
t[320]="net_flush_dns:Vider Cache DNS~systemd-resolved flush-caches:HIDDEN"
t[321]="net_clear_arp:Vider Cache ARP~ip neigh flush all:HIDDEN"
t[322]="net_renew_ip:Liberer et Renouveler IP~dhclient / nmcli reapply:HIDDEN"
t[323]="net_reset_tcpip:Reset TCP/IP Stack~NetworkManager restart complet:HIDDEN"
t[324]="net_reset_winsock:Reset Sockets Reseau~NetworkManager + DNS reset:HIDDEN"
t[325]="net_reset_all:Reset Reseau Automatique~Flush DNS, ARP, TCP/IP, NM:HIDDEN"
t[326]="net_restart_adapters:Redemarrer Cartes Reseau~Ethernet et WiFi:HIDDEN"
t[327]="net_fast_reset:Script Urgence Reseau~5 commandes de depannage reseau:HIDDEN"
t[328]="cyber_triage:Triage de Connectivite~Diagnostic rapide IP, Gateway, DNS:HIDDEN"
t[329]="cyber_adapter_audit:Audit des Adaptateurs Reseau~MAC, vitesse, statut:HIDDEN"
t[330]="cyber_lan_auto:Scanner Reseau Local LAN~Detecte appareils connectes et failles:HIDDEN"
# APPLICATIONS
t[331]="winget_manager:Mises a jour d Applications~apt + snap + flatpak update:HIDDEN"
t[332]="app_installer:Installateur d Applications~Chrome, VLC, Office, PDF...:HIDDEN"
# COMPTES
t[333]="sys_passwords_menu:Extracteurs de Mots de Passe~Credentials, WiFi, navigateurs:HIDDEN"
t[334]="sys_av_test:Test Antivirus EICAR~Tester protection ClamAV:HIDDEN"

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
    echo "   █████╗ ██╗     ███████╗███████╗██╗  ██╗██╗     ███████╗██████╗ ███████╗██╗   ██╗"
    echo "  ██╔══██╗██║     ██╔════╝██╔════╝╚██╗██╔╝██║     ██╔════╝██╔══██╗██╔════╝██║   ██║"
    echo "  ███████║██║     █████╗  █████╗   ╚███╔╝ ██║     █████╗  ██║  ██║█████╗  ██║   ██║"
    echo "  ██╔══██║██║     ██╔══╝  ██╔══╝   ██╔██╗ ██║     ██╔══╝  ██║  ██║██╔══╝  ╚██╗ ██╔╝"
    echo "  ██║  ██║███████╗███████╗███████╗██╔╝ ██╗███████╗███████╗██████╔╝███████╗ ╚████╔╝ "
    echo "  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚══════╝  ╚═══╝  "
    echo -e "${GRY}  Linux Edition v${VERSION}  —  ${total_tools} outils${NC}"
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

sys_report() {
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

sys_temp_report() {
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

sys_ram_check() {
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

sys_diag_network() {
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

sys_battery_report() {
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

sys_bitlocker_check() {
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

sys_event_log() {
    clear
    _draw_header "JOURNAL ERREURS SYSTEME"

    echo -e "  ${YLW}[ 50 dernieres erreurs (journalctl) ]${NC}\n"
    journalctl -p err -n 50 --no-pager 2>/dev/null \
        | tail -45 | while IFS= read -r line; do
            echo -e "  ${RED}${line}${NC}"
        done

    _pause
}

sys_hw_test() {
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

sys_defender() {
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

sys_ev_critical() {
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

ev_app_24h() {
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

ev_disk_warn() {
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
            "Rapport Systeme             — CPU, RAM, GPU, Stockage, Reseau"
            "Rapport de Temperature      — Capteurs CPU et GPU (lm-sensors)"
            "Test de Memoire RAM         — Modules, slots, vitesse"
            "Diagnostic Reseau           — Ping, traceroute, ports ouverts"
            "Rapport Batterie            — Usure et autonomie estimee"
            "Etat Chiffrement Disque     — LUKS / dm-crypt"
            "Journal des Erreurs         — Evenements critiques (journalctl)"
            "Test Materiel               — CPU/RAM stress test (stress-ng)"
            "Etat Antivirus (ClamAV)     — Protection active"
            "Erreurs Critiques 24h       — journalctl -p crit"
            "Erreurs Critiques 7 jours   — journalctl -p crit"
            "Erreurs Applications 24h    — Segfaults et crashs recents"
            "Alertes Disque              — smartctl health check"
            "--- Retour au menu principal"
        )
        AutoMenu "DIAGNOSTIC SYSTEME" || return

        case $MENU_CHOICE in
            0)  sys_report ;;
            1)  sys_temp_report ;;
            2)  sys_ram_check ;;
            3)  sys_diag_network ;;
            4)  sys_battery_report ;;
            5)  sys_bitlocker_check ;;
            6)  sys_event_log ;;
            7)  sys_hw_test ;;
            8)  sys_defender ;;
            9)  sys_ev_critical "24 hours" "24H" ;;
            10) sys_ev_critical "7 days" "7J" ;;
            11) ev_app_24h ;;
            12) ev_disk_warn ;;
            13) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 2 : REPARATION (15 outils)
# ================================================================

res_chkdsk() {
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

res_sfc() {
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

res_dism() {
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

res_net_reset() {
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

res_explorer_restart() {
    clear
    _draw_header "REDEMARRAGE ENVIRONNEMENT DE BUREAU"

    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-inconnu}}"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local dbus
    dbus=$(cat "/proc/$(pgrep -u "$user" dbus-daemon | head -1)/environ" 2>/dev/null \
           | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2- || echo "")

    echo -e "  Bureau  : ${WHT}${de}${NC}"
    echo -e "  Session : $( [ -n "$WAYLAND_DISPLAY" ] && echo "${WHT}Wayland${NC}" || echo "${WHT}X11${NC}" )\n"

    # Wayland : on ne peut pas redemarrer le compositor sans couper la session
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo -e "  ${YLW}[!] Session Wayland detectee.${NC}"
        echo -e "  ${GRY}    Le compositor Wayland ne peut pas etre redémarre"
        echo -e "  ${GRY}    depuis l interieur de la session sans ecran noir.${NC}"
        echo ""
        echo -e "  ${CYN}  Solution : deconnecte-toi et reconnecte-toi depuis l ecran de login.${NC}"
        _pause; return
    fi

    # X11 : on peut relancer le shell/compositor sans couper la session
    case "${de,,}" in
        *gnome*)
            echo -e "  ${YLW}[~] Redemarrage GNOME Shell (X11 safe)...${NC}"
            su -c "DISPLAY=$DISPLAY DBUS_SESSION_BUS_ADDRESS=$dbus killall -HUP gnome-shell" "$user" 2>/dev/null \
                && echo -e "  ${GRN}[✓] GNOME Shell redemarre (session conservee).${NC}" \
                || echo -e "  ${RED}[✗] Echec. Verifie que GNOME tourne en X11.${NC}"
            ;;
        *kde*|*plasma*)
            echo -e "  ${YLW}[~] Redemarrage KDE Plasma...${NC}"
            su -c "DISPLAY=$DISPLAY DBUS_SESSION_BUS_ADDRESS=$dbus systemctl --user restart plasma-plasmashell" "$user" 2>/dev/null \
                && echo -e "  ${GRN}[✓] Plasma redemarre.${NC}" \
                || echo -e "  ${RED}[✗] Echec.${NC}"
            ;;
        *xfce*)
            echo -e "  ${YLW}[~] Redemarrage gestionnaire fenetres XFCE...${NC}"
            su -c "DISPLAY=$DISPLAY xfwm4 --replace &" "$user" 2>/dev/null
            echo -e "  ${GRN}[✓] xfwm4 redemarre.${NC}"
            ;;
        *)
            echo -e "  ${YLW}[!] Bureau non reconnu : ${de}${NC}\n"
            echo -e "  ${GRY}  Lance ces commandes en tant que ton utilisateur (pas root) :${NC}"
            echo -e "  ${CYN}  GNOME  : killall -HUP gnome-shell${NC}"
            echo -e "  ${CYN}  KDE    : systemctl --user restart plasma-plasmashell${NC}"
            echo -e "  ${CYN}  XFCE   : xfwm4 --replace${NC}"
            ;;
    esac

    _pause
}

res_display_manager() {
    clear
    _draw_header "REDEMARRAGE DISPLAY MANAGER (GDM/SDDM/LightDM)"

    # SECURITE : bloquer si session graphique active → ecran noir garanti
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        echo -e "  ${RED}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${RED}║  ACTION BLOQUEE — ECRAN NOIR GARANTI SINON          ║${NC}"
        echo -e "  ${RED}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  Tu es dans une ${WHT}session graphique active${NC}."
        echo -e "  Redemarrer le display manager coupe TOUTE la session"
        echo -e "  en cours, y compris ce terminal."
        echo ""
        echo -e "  ${YLW}[ Procedure correcte depuis un TTY ]${NC}"
        echo -e "  ${WHT}  1.${NC} Appuie sur ${CYN}Ctrl+Alt+F2${NC} pour ouvrir un TTY"
        echo -e "  ${WHT}  2.${NC} Connecte-toi avec ton compte"
        echo -e "  ${WHT}  3.${NC} Lance : ${CYN}sudo systemctl restart display-manager${NC}"
        echo -e "  ${WHT}  4.${NC} Appuie sur ${CYN}Ctrl+Alt+F1${NC} (ou F7) pour revenir"
        echo ""
        echo -e "  ${GRY}  Ou plus simple : deconnecte ta session et reconnecte-toi.${NC}"
        _pause; return
    fi

    # Depuis un TTY : pas de session graphique a couper, on peut y aller
    local dm
    dm=$(systemctl status display-manager 2>/dev/null | grep "Loaded:" | grep -o '[^/]*\.service' | head -1)
    echo -e "  ${YLW}[ Display manager : ${WHT}${dm:-inconnu}${YLW} ]${NC}\n"

    MENU_OPTS=("Confirmer le redemarrage (depuis TTY)" "--- Annuler")
    AutoMenu "REDEMARRER LE DISPLAY MANAGER ?" || return
    [ $MENU_CHOICE -ne 0 ] && return

    systemctl restart display-manager 2>&1 | while IFS= read -r l; do echo "  $l"; done
    _pause
}

res_restore_point() {
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

res_grub() {
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

res_initramfs() {
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

res_services() {
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

res_permissions() {
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

res_hosts() {
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

res_locale() {
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

res_font_cache() {
    clear
    _draw_header "RECONSTRUCTION CACHE POLICES"

    echo -e "  ${YLW}[~] Reconstruction en cours...${NC}\n"
    fc-cache -fv 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Cache polices reconstruit.${NC}"
    _pause
}

res_ssh_fix() {
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

sys_repair_icons() {
    clear
    _draw_header "REPARATION CACHE ICONES"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    echo -e "  ${YLW}[1/3] Suppression du cache de miniatures...${NC}\n"
    rm -rf "/home/$user/.cache/thumbnails"/* 2>/dev/null
    rm -rf "/root/.cache/thumbnails"/* 2>/dev/null
    echo -e "  ${GRN}[✓] Cache miniatures supprime.${NC}\n"
    echo -e "  ${YLW}[2/3] Mise a jour du cache d icones GTK...${NC}\n"
    for dir in /usr/share/icons/*/; do
        command -v gtk-update-icon-cache &>/dev/null \
            && gtk-update-icon-cache -f "$dir" 2>/dev/null \
            && echo -e "  ${GRY}  [✓] $(basename "$dir")${NC}"
    done
    echo -e "\n  ${YLW}[3/3] Base de donnees applications...${NC}"
    command -v update-desktop-database &>/dev/null \
        && update-desktop-database /usr/share/applications 2>/dev/null \
        && echo -e "  ${GRN}[✓] Base de donnees mise a jour.${NC}"
    echo -e "\n  ${GRN}[✓] Cache icones reconstruit. Redemarrez la session pour appliquer.${NC}"
    _pause
}

res_dism_check() {
    clear
    _draw_header "VERIFICATION INTEGRITE SYSTEME (debsums)"
    echo -e "  ${YLW}[~] Verification de l integrite des paquets installes...${NC}\n"
    if ! command -v debsums &>/dev/null; then
        echo -e "  ${YLW}[~] Installation de debsums...${NC}"
        apt-get install -y debsums 2>&1 | tail -3 | while IFS= read -r l; do echo "  $l"; done
    fi
    debsums --changed 2>&1 | while IFS= read -r l; do
        echo "$l" | grep -qiE "FAILED|changed" \
            && echo -e "  ${RED}[!] $l${NC}" || echo -e "  ${GRY}$l${NC}"
    done
    echo -e "\n  ${GRN}[✓] Verification terminee.${NC}"
    _pause
}

res_dism_restore() {
    clear
    _draw_header "RESTAURATION INTEGRITE SYSTEME"
    echo -e "  ${YLW}[1/3] Detection des paquets corrompus (debsums)...${NC}\n"
    local bad_pkgs=()
    if command -v debsums &>/dev/null; then
        while IFS= read -r line; do
            local pkg
            pkg=$(dpkg -S "$(echo "$line" | awk '{print $1}')" 2>/dev/null | awk -F: '{print $1}' | head -1)
            [ -n "$pkg" ] && bad_pkgs+=("$pkg")
        done < <(debsums --changed 2>/dev/null)
    fi
    echo -e "  ${YLW}[2/3] Reinstallation des paquets corrompus...${NC}\n"
    if [ ${#bad_pkgs[@]} -gt 0 ]; then
        local unique_pkgs
        mapfile -t unique_pkgs < <(printf '%s\n' "${bad_pkgs[@]}" | sort -u)
        echo -e "  Reinstallation : ${WHT}${unique_pkgs[*]}${NC}\n"
        apt-get install --reinstall -y "${unique_pkgs[@]}" 2>&1 \
            | while IFS= read -r l; do echo "  $l"; done
    else
        echo -e "  ${GRN}  Aucun paquet corrompu detecte.${NC}"
    fi
    echo -e "\n  ${YLW}[3/3] Nettoyage et reconfiguration dpkg...${NC}\n"
    dpkg --configure -a 2>&1 | while IFS= read -r l; do echo "  $l"; done
    apt-get install -f -y 2>&1 | tail -5 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Restauration terminee.${NC}"
    _pause
}

res_wu_reset() {
    clear
    _draw_header "RESET MISES A JOUR APT"
    echo -e "  ${YLW}[1/5] Arret des processus apt/dpkg...${NC}\n"
    killall -9 apt apt-get dpkg 2>/dev/null; sleep 1
    echo -e "  ${YLW}[2/5] Suppression des verrous...${NC}\n"
    rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock \
          /var/cache/apt/archives/lock /var/lib/apt/lists/lock 2>/dev/null
    echo -e "  ${GRN}  [✓] Verrous supprimes.${NC}\n"
    echo -e "  ${YLW}[3/5] Reconfiguration dpkg...${NC}\n"
    dpkg --configure -a 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[4/5] Reparation des dependances...${NC}\n"
    apt-get install -f -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[5/5] Mise a jour des listes de paquets...${NC}\n"
    apt-get update 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] APT reinitialise avec succes.${NC}"
    _pause
}

res_gpu_reset() {
    clear
    _draw_header "REINITIALISER LE GPU"
    echo -e "  ${YLW}[ GPUs detectes ]${NC}\n"
    lspci | grep -iE "vga|3d|display" | while IFS= read -r l; do echo -e "  ${WHT}$l${NC}"; done
    echo ""
    local gpu_mod
    gpu_mod=$(lspci -k 2>/dev/null | grep -A3 -iE "vga|3d|display" \
        | grep "Kernel driver in use" | awk '{print $NF}' | head -1)
    if [ -z "$gpu_mod" ]; then
        echo -e "  ${YLW}[~] Aucun module detecte. Rescan PCI...${NC}"
        echo "1" > /sys/bus/pci/rescan 2>/dev/null
        echo -e "  ${GRN}[✓] Rescan PCI effectue.${NC}"
    else
        echo -e "  ${YLW}Module GPU : ${WHT}${gpu_mod}${NC}"
        echo -e "  ${RED}[!] Le rechargement peut couper l affichage temporairement.${NC}\n"
        MENU_OPTS=("Recharger le module $gpu_mod" "--- Annuler")
        AutoMenu "GPU RESET" || return
        [ $MENU_CHOICE -ne 0 ] && return
        modprobe -r "$gpu_mod" 2>&1 | while IFS= read -r l; do echo "  $l"; done
        sleep 1
        modprobe "$gpu_mod" 2>&1 | while IFS= read -r l; do echo "  $l"; done
        echo -e "  ${GRN}[✓] Module ${gpu_mod} rechargé.${NC}"
    fi
    _pause
}

winre_bios() {
    clear
    _draw_header "REDEMARRER VERS LE BIOS/UEFI"
    if [ -d /sys/firmware/efi ]; then
        echo -e "  ${GRN}[✓] Systeme UEFI detecte.${NC}\n"
        echo -e "  ${RED}[!] Le systeme va redemarrer dans le BIOS/UEFI.${NC}"
        echo -e "  ${GRY}    Enregistre ton travail maintenant.${NC}\n"
        MENU_OPTS=("Confirmer le redemarrage vers BIOS/UEFI" "--- Annuler")
        AutoMenu "CONFIRMATION" || return
        [ $MENU_CHOICE -ne 0 ] && return
        systemctl reboot --firmware-setup
    else
        echo -e "  ${RED}[✗] Systeme BIOS legacy — option non disponible.${NC}"
        echo -e "  ${GRY}    Acces BIOS : appuie sur Del / F2 / F12 au demarrage.${NC}"
        _pause
    fi
}

winre_safe_minimal() {
    clear
    _draw_header "MODE SANS ECHEC (GRUB RECOVERY)"
    echo -e "  ${YLW}[ Entrees GRUB disponibles ]${NC}\n"
    grep -E "^menuentry" /boot/grub/grub.cfg 2>/dev/null \
        | sed 's/menuentry /  /' | head -10 | while IFS= read -r l; do echo -e "  ${GRY}$l${NC}"; done
    echo ""
    MENU_OPTS=(
        "Activer l affichage du menu GRUB au prochain boot"
        "Voir les entrees de demarrage disponibles"
        "--- Annuler"
    )
    AutoMenu "MODE DEMARRAGE" || return
    case $MENU_CHOICE in
        0)
            sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub 2>/dev/null
            sed -i 's/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub 2>/dev/null
            update-grub 2>/dev/null | tail -3 | while IFS= read -r l; do echo "  $l"; done
            echo -e "  ${GRN}[✓] Menu GRUB active. Redemarrez et selectionnez 'recovery mode'.${NC}"
            ;;
        1)
            grep -c "^menuentry" /boot/grub/grub.cfg 2>/dev/null \
                | while IFS= read -r l; do echo -e "  ${WHT}$l entrees trouvees${NC}"; done
            grep "^menuentry" /boot/grub/grub.cfg 2>/dev/null \
                | nl | while IFS= read -r l; do echo "  $l"; done
            ;;
    esac
    _pause
}

winre_status() {
    clear
    _draw_header "STATUT BOOT / GRUB"
    echo -e "  ${YLW}[ Noyaux installes ]${NC}\n"
    ls /boot/vmlinuz-* 2>/dev/null | sort -V | while IFS= read -r k; do
        echo -e "  ${WHT}$(basename "$k")${NC}"
    done
    echo -e "\n  ${YLW}[ Noyau actif ]${NC}\n  ${GRN}$(uname -r)${NC}"
    echo -e "\n  ${YLW}[ Mode EFI / BIOS ]${NC}\n"
    if [ -d /sys/firmware/efi ]; then
        echo -e "  ${GRN}UEFI${NC}"
        command -v efibootmgr &>/dev/null \
            && efibootmgr 2>/dev/null | grep -E "BootOrder|Boot[0-9]" | head -8 \
            | while IFS= read -r l; do echo -e "  ${GRY}$l${NC}"; done
    else
        echo -e "  ${YLW}BIOS Legacy${NC}"
    fi
    echo -e "\n  ${YLW}[ Options de demarrage ]${NC}\n"
    cat /proc/cmdline 2>/dev/null | tr ' ' '\n' \
        | while IFS= read -r l; do echo -e "  ${GRY}$l${NC}"; done
    _pause
}

winre_reset() {
    clear
    _draw_header "REINITIALISER OPTIONS DE DEMARRAGE"
    MENU_OPTS=(
        "Restaurer GRUB aux valeurs par defaut"
        "Mettre a jour GRUB"
        "Reinstaller GRUB (MBR / EFI)"
        "--- Annuler"
    )
    AutoMenu "ACTION GRUB" || return
    case $MENU_CHOICE in
        0)
            sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub 2>/dev/null
            sed -i 's/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub 2>/dev/null
            update-grub 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${GRN}[✓] GRUB restaure aux valeurs par defaut.${NC}"
            ;;
        1)
            update-grub 2>&1 | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${GRN}[✓] GRUB mis a jour.${NC}"
            ;;
        2)
            local -a devices
            mapfile -t devices < <(lsblk -dno NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')
            [ ${#devices[@]} -eq 0 ] && { echo -e "  ${RED}Aucun disque detecte.${NC}"; _pause; return; }
            MENU_OPTS=("${devices[@]}" "--- Annuler")
            AutoMenu "DISQUE CIBLE" || return
            [ $MENU_CHOICE -ge ${#devices[@]} ] && return
            local target="${devices[$MENU_CHOICE]}"
            if [ -d /sys/firmware/efi ]; then
                grub-install --target=x86_64-efi --efi-directory=/boot/efi "$target" 2>&1 \
                    | while IFS= read -r l; do echo "  $l"; done
            else
                grub-install "$target" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            fi
            update-grub 2>&1 | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${GRN}[✓] GRUB reinstalle sur ${target}.${NC}"
            ;;
    esac
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 2 : REPARATION
# ----------------------------------------------------------------
menu_reparation() {
    while true; do
        MENU_OPTS=(
            "--- ──────────────── REPARATION SYSTEME ─────────────────"
            "Verification Disque (fsck)     — CHKDSK : reparer le filesystem"
            "Reparer Paquets Casses         — SFC : apt --fix-broken"
            "Verifier Integrite Systeme     — DISM CheckHealth : debsums"
            "Restaurer Integrite Systeme    — DISM RestoreHealth : reinstaller"
            "Reset Mises a Jour APT         — Reset WinUpdate : verrous dpkg"
            "Redemarrer Bureau              — Restart Explorer : GNOME/KDE/XFCE"
            "Reinitialiser GPU              — GPU Reset : modprobe reload"
            "Point de Restauration          — Snapshot Timeshift"
            "--- ──────────────── DEMARRAGE / GRUB ──────────────────"
            "Redemarrer vers BIOS/UEFI      — WinRE Bios : firmware-setup"
            "Mode Sans Echec                — WinRE Safe : GRUB recovery"
            "Statut Boot                    — Noyaux, GRUB, EFI / BIOS"
            "Reinitialiser GRUB             — Restaurer options de demarrage"
            "--- ──────────────── AUTRES OUTILS ──────────────────────"
            "Reparation Cache Icones        — Miniatures et icones GTK"
            "Reinitialiser Reseau           — NetworkManager + DNS + IP"
            "Reparer DPKG Bloque            — Verrous dpkg/apt"
            "Redemarrer Display Manager     — GDM / SDDM / LightDM"
            "Mettre a jour GRUB             — update-grub / grub2-mkconfig"
            "Reconstruire initramfs         — update-initramfs / mkinitcpio"
            "Reparer Services Systemd       — reset-failed + logs"
            "Corriger Permissions           — home / tmp / ssh / sudoers"
            "Reinitialiser /etc/hosts       — Reset au fichier par defaut"
            "Reparer Locales                — locale-gen + dpkg-reconfigure"
            "Reconstruire Cache Polices     — fc-cache -fv"
            "Reparer SSH                    — cles, config, service sshd"
            "--- Retour au menu principal"
        )
        AutoMenu "REPARATION SYSTEME" || return

        case $MENU_CHOICE in
            1)  res_chkdsk ;;
            2)  res_sfc ;;
            3)  res_dism_check ;;
            4)  res_dism_restore ;;
            5)  res_wu_reset ;;
            6)  res_explorer_restart ;;
            7)  res_gpu_reset ;;
            8)  res_restore_point ;;
            10) winre_bios ;;
            11) winre_safe_minimal ;;
            12) winre_status ;;
            13) winre_reset ;;
            15) sys_repair_icons ;;
            16) res_net_reset ;;
            17) res_dism ;;
            18) res_display_manager ;;
            19) res_grub ;;
            20) res_initramfs ;;
            21) res_services ;;
            22) res_permissions ;;
            23) res_hosts ;;
            24) res_locale ;;
            25) res_font_cache ;;
            26) res_ssh_fix ;;
            27) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 3 : NETTOYAGE & OPTIMISATION
# ================================================================

# Afficher un bilan avant/apres (taille liberee)
_disk_free() { df / --output=avail -BM | tail -1 | tr -d 'M '; }

cl_apt() {
    clear
    _draw_header "NETTOYAGE CACHE APT"
    local before after
    before=$(_disk_free)
    echo -e "  ${YLW}[1/3] Suppression des paquets inutiles (autoremove)...${NC}\n"
    apt-get autoremove -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[2/3] Nettoyage du cache apt (autoclean)...${NC}\n"
    apt-get autoclean -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[3/3] Suppression du cache complet (clean)...${NC}\n"
    apt-get clean 2>&1 | while IFS= read -r l; do echo "  $l"; done
    after=$(_disk_free)
    echo -e "\n  ${GRN}[✓] Cache APT nettoye. Espace libere : $((after - before)) Mo${NC}"
    _pause
}

cl_temp() {
    clear
    _draw_header "NETTOYAGE FICHIERS TEMPORAIRES"
    local before after user
    before=$(_disk_free)
    user="${SUDO_USER:-$(logname 2>/dev/null)}"
    echo -e "  ${YLW}[1/4] Nettoyage /tmp...${NC}"
    find /tmp -mindepth 1 -mtime +1 -delete 2>/dev/null
    echo -e "  ${GRN}      [✓] /tmp nettoye${NC}"
    echo -e "  ${YLW}[2/4] Nettoyage /var/tmp...${NC}"
    find /var/tmp -mindepth 1 -mtime +7 -delete 2>/dev/null
    echo -e "  ${GRN}      [✓] /var/tmp nettoye${NC}"
    echo -e "  ${YLW}[3/4] Nettoyage ~/.cache ($user)...${NC}"
    find "/home/$user/.cache" -mindepth 1 -not -path "*/mozilla/*" -delete 2>/dev/null || true
    echo -e "  ${GRN}      [✓] ~/.cache nettoye${NC}"
    echo -e "  ${YLW}[4/4] Nettoyage miniatures (~/.cache/thumbnails)...${NC}"
    rm -rf "/home/$user/.cache/thumbnails/"* 2>/dev/null || true
    echo -e "  ${GRN}      [✓] Miniatures supprimees${NC}"
    after=$(_disk_free)
    echo -e "\n  ${GRN}[✓] Termine. Espace libere : $((after - before)) Mo${NC}"
    _pause
}

cl_dns() {
    clear
    _draw_header "VIDAGE CACHE DNS"
    if command -v resolvectl &>/dev/null; then
        resolvectl flush-caches 2>/dev/null \
            && echo -e "  ${GRN}[✓] Cache DNS vide (systemd-resolved)${NC}" \
            || echo -e "  ${YLW}[!] Echec resolvectl${NC}"
    fi
    if command -v systemd-resolve &>/dev/null; then
        systemd-resolve --flush-caches 2>/dev/null || true
    fi
    if systemctl is-active nscd &>/dev/null; then
        systemctl restart nscd 2>/dev/null
        echo -e "  ${GRN}[✓] Cache DNS vide (nscd)${NC}"
    fi
    echo -e "  ${YLW}[ DNS actifs apres vidage ]${NC}"
    resolvectl status 2>/dev/null | grep "DNS Servers" | while IFS= read -r l; do echo "  $l"; done \
        || grep nameserver /etc/resolv.conf | while IFS= read -r l; do echo "  $l"; done
    _pause
}

cl_logs() {
    clear
    _draw_header "NETTOYAGE ANCIENS LOGS"
    local before after
    before=$(_disk_free)
    echo -e "  ${YLW}[1/3] Journaux systemd > 7 jours...${NC}\n"
    journalctl --vacuum-time=7d 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[2/3] Journaux systemd > 200 Mo...${NC}\n"
    journalctl --vacuum-size=200M 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[3/3] Anciens fichiers .log dans /var/log...${NC}"
    find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null
    find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null
    echo -e "  ${GRN}      [✓] Anciens logs comprimes supprimes${NC}"
    after=$(_disk_free)
    echo -e "\n  ${GRN}[✓] Logs nettoyes. Espace libere : $((after - before)) Mo${NC}"
    _pause
}

cl_trash() {
    clear
    _draw_header "VIDAGE CORBEILLE"
    local user before after
    user="${SUDO_USER:-$(logname 2>/dev/null)}"
    before=$(_disk_free)
    local trash_dirs=(
        "/home/$user/.local/share/Trash/files"
        "/home/$user/.local/share/Trash/info"
        "/root/.local/share/Trash/files"
        "/root/.local/share/Trash/info"
    )
    for d in "${trash_dirs[@]}"; do
        if [ -d "$d" ]; then
            local count
            count=$(find "$d" -mindepth 1 | wc -l)
            rm -rf "$d"/* 2>/dev/null
            echo -e "  ${GRN}[✓] $d — $count elements supprimes${NC}"
        fi
    done
    after=$(_disk_free)
    echo -e "\n  ${GRN}[✓] Corbeille videe. Espace libere : $((after - before)) Mo${NC}"
    _pause
}

cl_orphans() {
    clear
    _draw_header "SUPPRESSION PAQUETS ORPHELINS"
    echo -e "  ${YLW}[ Paquets installes automatiquement non utilises ]${NC}\n"
    local list
    list=$(apt-get --dry-run autoremove 2>/dev/null | grep "^Remv" | awk '{print "  "$2}')
    if [ -z "$list" ]; then
        echo -e "  ${GRN}[✓] Aucun paquet orphelin trouve.${NC}"
        _pause; return
    fi
    echo "$list"
    local count; count=$(echo "$list" | wc -l)
    echo -e "\n  ${YLW}$count paquets a supprimer.${NC}"
    MENU_OPTS=("Confirmer la suppression" "--- Annuler")
    AutoMenu "SUPPRIMER LES ORPHELINS ?" || return
    [ $MENU_CHOICE -ne 0 ] && return
    echo ""
    apt-get autoremove -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
    apt-get autoclean -y 2>/dev/null
    echo -e "\n  ${GRN}[✓] Orphelins supprimes.${NC}"
    _pause
}

cl_browser() {
    clear
    _draw_header "NETTOYAGE CACHES NAVIGATEURS"
    local user before after
    user="${SUDO_USER:-$(logname 2>/dev/null)}"
    before=$(_disk_free)
    local -A browsers=(
        ["Firefox"]="/home/$user/.cache/mozilla/firefox"
        ["Chromium"]="/home/$user/.cache/chromium"
        ["Chrome"]="/home/$user/.cache/google-chrome"
        ["Brave"]="/home/$user/.cache/BraveSoftware/Brave-Browser"
        ["Opera"]="/home/$user/.cache/opera"
        ["Vivaldi"]="/home/$user/.cache/vivaldi"
    )
    for name in "${!browsers[@]}"; do
        local path="${browsers[$name]}"
        if [ -d "$path" ]; then
            local sz
            sz=$(du -sh "$path" 2>/dev/null | cut -f1)
            find "$path" -mindepth 1 -delete 2>/dev/null
            echo -e "  ${GRN}[✓] $name — $sz liberes${NC}"
        fi
    done
    after=$(_disk_free)
    echo -e "\n  ${GRN}[✓] Caches navigateurs nettoyes. Total : $((after - before)) Mo${NC}"
    _pause
}

cl_snap() {
    clear
    _draw_header "NETTOYAGE ANCIENNES VERSIONS SNAP"
    if ! command -v snap &>/dev/null; then
        echo -e "  ${GRY}Snap non installe sur ce systeme.${NC}"
        _pause; return
    fi
    echo -e "  ${YLW}[ Revisions snap installees ]${NC}\n"
    snap list --all 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo ""
    echo -e "  ${YLW}[~] Suppression des anciennes revisions...${NC}\n"
    snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read -r name rev; do
        snap remove "$name" --revision="$rev" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    done
    echo -e "\n  ${GRN}[✓] Anciennes revisions snap supprimees.${NC}"
    _pause
}

cl_pip_npm() {
    clear
    _draw_header "NETTOYAGE CACHES PIP / NPM"
    local before after
    before=$(_disk_free)
    if command -v pip3 &>/dev/null; then
        echo -e "  ${YLW}[~] Nettoyage cache pip...${NC}"
        pip3 cache purge 2>&1 | while IFS= read -r l; do echo "  $l"; done
    fi
    if command -v pip &>/dev/null; then
        pip cache purge 2>/dev/null || true
    fi
    if command -v npm &>/dev/null; then
        echo -e "\n  ${YLW}[~] Nettoyage cache npm...${NC}"
        npm cache clean --force 2>&1 | while IFS= read -r l; do echo "  $l"; done
    fi
    if command -v yarn &>/dev/null; then
        echo -e "\n  ${YLW}[~] Nettoyage cache yarn...${NC}"
        yarn cache clean 2>&1 | while IFS= read -r l; do echo "  $l"; done
    fi
    after=$(_disk_free)
    echo -e "\n  ${GRN}[✓] Espace libere : $((after - before)) Mo${NC}"
    _pause
}

sys_startup() {
    clear
    _draw_header "GESTIONNAIRE DE DEMARRAGE (SYSTEMD)"
    echo -e "  ${YLW}[ Services actifs au boot ]${NC}\n"
    systemctl list-unit-files --state=enabled --type=service --no-legend 2>/dev/null \
        | while IFS= read -r l; do echo -e "  ${GRN}$l${NC}"; done
    echo ""
    echo -e "  ${YLW}[ Services desactives ]${NC}\n"
    systemctl list-unit-files --state=disabled --type=service --no-legend 2>/dev/null \
        | head -20 | while IFS= read -r l; do echo -e "  ${GRY}$l${NC}"; done
    echo ""
    MENU_OPTS=(
        "Activer un service"
        "Desactiver un service"
        "Voir les services qui ralentissent le boot"
        "--- Retour"
    )
    AutoMenu "ACTION" || return
    case $MENU_CHOICE in
        0)
            echo -e "\n  ${YLW}Nom du service a activer (ex: bluetooth.service) :${NC}"
            echo -e "  ${GRY}(tape le nom exact)${NC} "
            read -r svc
            systemctl enable "$svc" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        1)
            echo -e "\n  ${YLW}Nom du service a desactiver :${NC} "
            read -r svc
            systemctl disable "$svc" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        2)
            echo ""
            systemd-analyze blame 2>/dev/null | head -20 | while IFS= read -r l; do echo "  $l"; done
            ;;
        *) return ;;
    esac
    _pause
}

sys_tweaks() {
    clear
    _draw_header "OPTIMISATIONS SYSTEME"
    local swappiness
    swappiness=$(cat /proc/sys/vm/swappiness)
    echo -e "  ${YLW}[ Etat actuel ]${NC}"
    echo -e "  Swappiness     : ${WHT}${swappiness}${NC} ${GRY}(60 = defaut, 10 = desktop optimal)${NC}"
    echo -e "  CPU governor   : ${WHT}$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')${NC}"
    echo -e "  I/O scheduler  : ${WHT}$(cat /sys/block/sda/queue/scheduler 2>/dev/null | grep -o '\[.*\]' || echo 'N/A')${NC}"
    echo ""
    MENU_OPTS=(
        "Swappiness → 10  (desktop, RAM preferee)"
        "Swappiness → 60  (defaut systeme)"
        "Swappiness → 1   (minimum, RAM max)"
        "CPU → performance  (vitesse max)"
        "CPU → ondemand     (equilibre)"
        "CPU → powersave    (economie batterie)"
        "Desactiver IPv6    (si inutilise)"
        "Appliquer tous les tweaks desktop optimaux"
        "--- Retour"
    )
    AutoMenu "OPTIMISATIONS" || return
    case $MENU_CHOICE in
        0) sysctl -w vm.swappiness=10 && echo -e "  ${GRN}[✓] Swappiness = 10${NC}" ;;
        1) sysctl -w vm.swappiness=60 && echo -e "  ${GRN}[✓] Swappiness = 60${NC}" ;;
        2) sysctl -w vm.swappiness=1  && echo -e "  ${GRN}[✓] Swappiness = 1${NC}" ;;
        3) for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
               echo "performance" > "$cpu" 2>/dev/null; done
           echo -e "  ${GRN}[✓] CPU governor = performance${NC}" ;;
        4) for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
               echo "ondemand" > "$cpu" 2>/dev/null; done
           echo -e "  ${GRN}[✓] CPU governor = ondemand${NC}" ;;
        5) for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
               echo "powersave" > "$cpu" 2>/dev/null; done
           echo -e "  ${GRN}[✓] CPU governor = powersave${NC}" ;;
        6) sysctl -w net.ipv6.conf.all.disable_ipv6=1 2>/dev/null
           sysctl -w net.ipv6.conf.default.disable_ipv6=1 2>/dev/null
           echo -e "  ${GRN}[✓] IPv6 desactive (temporaire, jusqu au prochain reboot)${NC}" ;;
        7)
            sysctl -w vm.swappiness=10
            sysctl -w vm.vfs_cache_pressure=50
            sysctl -w kernel.nmi_watchdog=0
            sysctl -w net.core.netdev_max_backlog=16384
            echo -e "  ${GRN}[✓] Tweaks desktop appliques (swappiness=10, vfs_cache=50, watchdog off)${NC}"
            echo -e "  ${GRY}    Persistance : ajoute dans /etc/sysctl.d/99-aleex.conf pour survivre au reboot${NC}"
            ;;
        *) return ;;
    esac
    _pause
}

cl_all() {
    clear
    _draw_header "NETTOYAGE COMPLET"
    local before after
    before=$(_disk_free)
    echo -e "  ${YLW}[1/7] Cache APT...${NC}"
    apt-get autoremove -y -q 2>/dev/null && apt-get clean -q 2>/dev/null
    echo -e "  ${GRN}      [✓] Cache APT${NC}"
    echo -e "  ${YLW}[2/7] Fichiers temporaires...${NC}"
    find /tmp -mindepth 1 -mtime +1 -delete 2>/dev/null
    find /var/tmp -mindepth 1 -mtime +7 -delete 2>/dev/null
    echo -e "  ${GRN}      [✓] /tmp et /var/tmp${NC}"
    echo -e "  ${YLW}[3/7] Cache DNS...${NC}"
    resolvectl flush-caches 2>/dev/null || true
    echo -e "  ${GRN}      [✓] DNS${NC}"
    echo -e "  ${YLW}[4/7] Journaux systemd...${NC}"
    journalctl --vacuum-time=7d -q 2>/dev/null
    echo -e "  ${GRN}      [✓] Logs > 7j${NC}"
    echo -e "  ${YLW}[5/7] Corbeille...${NC}"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    rm -rf "/home/$user/.local/share/Trash/files/"* 2>/dev/null || true
    echo -e "  ${GRN}      [✓] Corbeille${NC}"
    echo -e "  ${YLW}[6/7] Miniatures...${NC}"
    rm -rf "/home/$user/.cache/thumbnails/"* 2>/dev/null || true
    echo -e "  ${GRN}      [✓] Miniatures${NC}"
    echo -e "  ${YLW}[7/7] Anciennes revisions Snap...${NC}"
    snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read -r name rev; do
        snap remove "$name" --revision="$rev" -q 2>/dev/null || true
    done
    echo -e "  ${GRN}      [✓] Snap${NC}"
    after=$(_disk_free)
    echo ""
    echo -e "  ┌─────────────────────────────────────────┐"
    printf  "  │  Espace total libere : %-17s│\n" "$((after - before)) Mo"
    echo -e "  └─────────────────────────────────────────┘"
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 3 : NETTOYAGE
# ----------------------------------------------------------------
menu_nettoyage() {
    while true; do
        MENU_OPTS=(
            "Nettoyage Complet            — Tout en une fois"
            "Cache APT                    — autoremove + autoclean + clean"
            "Fichiers Temporaires         — /tmp, /var/tmp, ~/.cache"
            "Cache DNS                    — systemd-resolved flush"
            "Anciens Logs                 — journalctl vacuum + /var/log"
            "Corbeille                    — Vider la corbeille"
            "Paquets Orphelins            — autoremove avec confirmation"
            "Caches Navigateurs           — Firefox, Chrome, Brave..."
            "Anciennes Versions Snap      — Revisions desactivees"
            "Caches Pip / NPM / Yarn      — Outils de dev"
            "Gestionnaire Demarrage       — Activer/desactiver services"
            "Optimisations Systeme        — Swappiness, CPU, tweaks"
            "--- Retour au menu principal"
        )
        AutoMenu "NETTOYAGE & OPTIMISATION" || return
        case $MENU_CHOICE in
            0)  cl_all ;;
            1)  cl_apt ;;
            2)  cl_temp ;;
            3)  cl_dns ;;
            4)  cl_logs ;;
            5)  cl_trash ;;
            6)  cl_orphans ;;
            7)  cl_browser ;;
            8)  cl_snap ;;
            9)  cl_pip_npm ;;
            10) sys_startup ;;
            11) sys_tweaks ;;
            12) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 5 : DISQUE
# ================================================================

disk_usage() {
    clear
    _draw_header "UTILISATION DISQUE"
    echo -e "  ${YLW}[ Partitions montees (df) ]${NC}\n"
    df -h --output=source,size,used,avail,pcent,target 2>/dev/null \
        | grep -v "^tmpfs\|^udev\|^/dev/loop" \
        | while IFS= read -r l; do
            if echo "$l" | grep -qE "9[0-9]%|100%"; then
                echo -e "  ${RED}$l${NC}"
            elif echo "$l" | grep -qE "[7-8][0-9]%"; then
                echo -e "  ${YLW}$l${NC}"
            else
                echo -e "  ${GRN}$l${NC}"
            fi
        done
    echo -e "\n  ${YLW}[ Top 15 dossiers les plus lourds (/) ]${NC}\n"
    du -hx --max-depth=3 / 2>/dev/null \
        | sort -rh | head -15 \
        | while IFS= read -r l; do echo "  $l"; done
    _pause
}

disk_smart() {
    clear
    _draw_header "SANTE DISQUES — RAPPORT SMART COMPLET"
    _require smartctl smartmontools || return
    local disks
    mapfile -t disks < <(lsblk -dn -o NAME 2>/dev/null | grep -E "^sd|^nvme|^hd|^vd")
    if [ ${#disks[@]} -eq 0 ]; then
        echo -e "  ${YLW}Aucun disque compatible detecte.${NC}"; _pause; return
    fi
    MENU_OPTS=()
    for d in "${disks[@]}"; do
        local sz tp
        sz=$(lsblk -dno SIZE "/dev/$d" 2>/dev/null)
        tp=$(lsblk -dno TRAN "/dev/$d" 2>/dev/null)
        MENU_OPTS+=("/dev/$d  [$tp]  $sz")
    done
    MENU_OPTS+=("Rapport de tous les disques" "--- Annuler")
    AutoMenu "CHOISIR UN DISQUE" || return
    local idx=$MENU_CHOICE
    clear
    _draw_header "RAPPORT SMART"
    if [ $idx -eq ${#disks[@]} ]; then
        for d in "${disks[@]}"; do
            echo -e "  ${YLW}══ /dev/$d ══${NC}"
            smartctl -a "/dev/$d" 2>/dev/null | grep -E "Model|Serial|Firmware|Capacity|Health|Power_On|Reallocated|Pending|Uncorrectable|Temperature|SMART overall" \
                | while IFS= read -r l; do echo "  $l"; done
            echo ""
        done
    elif [ $idx -lt ${#disks[@]} ]; then
        local target="/dev/${disks[$idx]}"
        smartctl -a "$target" 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    else
        return
    fi
    _pause
}

disk_manager() {
    clear
    _draw_header "GESTIONNAIRE DE DISQUE"
    echo -e "  ${YLW}[ Disques et partitions ]${NC}\n"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL,UUID 2>/dev/null \
        | while IFS= read -r l; do echo "  $l"; done
    echo ""
    MENU_OPTS=(
        "Informations detaillees (blkid)"
        "Verifier un systeme de fichiers (fsck)"
        "Formater une partition"
        "Creer une table de partitions (fdisk)"
        "Monter une partition"
        "Demonter une partition"
        "--- Retour"
    )
    AutoMenu "GESTIONNAIRE DISQUE" || return
    case $MENU_CHOICE in
        0)
            clear; _draw_header "BLKID — DETAILS PARTITIONS"
            blkid 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
            _pause ;;
        1)
            clear; _draw_header "VERIFICATION FILESYSTEM"
            echo -e "  ${GRY}(La partition doit etre demontee)${NC}\n"
            lsblk -lno NAME,TYPE,MOUNTPOINT | awk '$2=="part" && $3==""' | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${YLW}Partition a verifier (ex: sdb1) :${NC} "; read -r dev
            fsck -V -y "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            _pause ;;
        2)
            clear; _draw_header "FORMATAGE PARTITION"
            echo -e "  ${RED}[!] ATTENTION : toutes les donnees seront perdues.${NC}\n"
            lsblk -lno NAME,SIZE,TYPE,MOUNTPOINT | awk '$3=="part"' | while IFS= read -r l; do echo "  $l"; done
            echo ""
            MENU_OPTS=("ext4" "xfs" "btrfs" "ntfs (Windows)" "fat32 (USB)" "--- Annuler")
            AutoMenu "FORMAT" || return
            local fmt
            case $MENU_CHOICE in
                0) fmt="ext4" ;; 1) fmt="xfs" ;; 2) fmt="btrfs" ;;
                3) fmt="ntfs" ;; 4) fmt="vfat" ;; *) return ;;
            esac
            echo -e "\n  ${YLW}Partition a formater (ex: sdb1) :${NC} "; read -r dev
            echo -e "  ${RED}Confirme : formater /dev/$dev en $fmt ? (tape OUI en majuscules) :${NC} "
            read -r confirm
            if [ "$confirm" = "OUI" ]; then
                case $fmt in
                    ext4)  mkfs.ext4 -F "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
                    xfs)   mkfs.xfs  -f "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
                    btrfs) mkfs.btrfs -f "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
                    ntfs)  _require mkntfs ntfs-3g
                           mkntfs -f "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
                    vfat)  mkfs.vfat "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
                esac
                echo -e "\n  ${GRN}[✓] /dev/$dev formate en $fmt.${NC}"
            else
                echo -e "  ${GRY}Annule.${NC}"
            fi
            _pause ;;
        3)
            clear; _draw_header "FDISK — TABLE DE PARTITIONS"
            echo -e "  ${YLW}Disque cible (ex: sdb) :${NC} "; read -r dev
            fdisk "/dev/$dev"
            _pause ;;
        4)
            clear; _draw_header "MONTER UNE PARTITION"
            lsblk -lno NAME,SIZE,TYPE,MOUNTPOINT | awk '$3=="part" && $4==""' \
                | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${YLW}Partition (ex: sdb1) :${NC} "; read -r dev
            echo -e "  ${YLW}Point de montage (ex: /mnt/data) :${NC} "; read -r mnt
            mkdir -p "$mnt"
            mount "/dev/$dev" "$mnt" 2>&1 | while IFS= read -r l; do echo "  $l"; done \
                && echo -e "  ${GRN}[✓] /dev/$dev monte sur $mnt${NC}"
            _pause ;;
        5)
            clear; _draw_header "DEMONTER UNE PARTITION"
            lsblk -lno NAME,MOUNTPOINT | awk '$2!="" && $2!="/" && $2!="/boot"' \
                | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${YLW}Point de montage a demonter (ex: /mnt/data) :${NC} "; read -r mnt
            umount "$mnt" 2>&1 | while IFS= read -r l; do echo "  $l"; done \
                && echo -e "  ${GRN}[✓] $mnt demonte.${NC}"
            _pause ;;
        *) return ;;
    esac
}

disk_bench() {
    clear
    _draw_header "BENCHMARK I/O DISQUE"
    echo -e "  ${YLW}[ Disques detectes ]${NC}"
    lsblk -dno NAME,SIZE,TRAN 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo ""
    MENU_OPTS=(
        "Test ecriture sequentielle (dd — 512Mo)"
        "Test lecture sequentielle  (hdparm)"
        "Test lecture + ecriture    (dd complet)"
        "--- Annuler"
    )
    AutoMenu "TYPE DE BENCHMARK" || return
    case $MENU_CHOICE in
        0)
            clear; _draw_header "BENCHMARK ECRITURE"
            echo -e "  ${YLW}[~] Test ecriture 512Mo sur /tmp...${NC}\n"
            dd if=/dev/zero of=/tmp/bench_write bs=1M count=512 conv=fdatasync 2>&1 \
                | while IFS= read -r l; do echo "  $l"; done
            rm -f /tmp/bench_write
            echo -e "\n  ${GRN}[✓] Test termine.${NC}"
            ;;
        1)
            _require hdparm || return
            clear; _draw_header "BENCHMARK LECTURE"
            echo -e "  ${YLW}Disque a tester (ex: sda) :${NC} "; read -r dev
            echo -e "\n  ${YLW}[~] Test lecture /dev/$dev...${NC}\n"
            hdparm -Tt "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        2)
            clear; _draw_header "BENCHMARK LECTURE + ECRITURE"
            echo -e "  ${YLW}[~] Ecriture 256Mo...${NC}\n"
            dd if=/dev/zero of=/tmp/bench bs=1M count=256 conv=fdatasync 2>&1 \
                | while IFS= read -r l; do echo "  $l"; done
            echo -e "\n  ${YLW}[~] Lecture 256Mo...${NC}\n"
            echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
            dd if=/tmp/bench of=/dev/null bs=1M 2>&1 \
                | while IFS= read -r l; do echo "  $l"; done
            rm -f /tmp/bench
            echo -e "\n  ${GRN}[✓] Benchmark termine.${NC}"
            ;;
        *) return ;;
    esac
    _pause
}

disk_wipe() {
    clear
    _draw_header "EFFACEMENT SECURISE (SHRED)"
    echo -e "  ${RED}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${RED}║  DANGER — DONNEES IRRECUPERABLES APRES OPERATION    ║${NC}"
    echo -e "  ${RED}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${YLW}[ Disques disponibles ]${NC}\n"
    lsblk -dno NAME,SIZE,TYPE 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo ""
    echo -e "  ${YLW}Disque ou partition a effacer (ex: sdb) :${NC} "; read -r dev
    echo -e "  ${RED}Tape EFFACER pour confirmer l effacement de /dev/$dev :${NC} "
    read -r confirm
    [ "$confirm" != "EFFACER" ] && echo -e "  ${GRY}Annule.${NC}" && _pause && return
    MENU_OPTS=(
        "Rapide  — 1 passe zeros   (SSD recommande)"
        "Standard — 3 passes aleatoires (HDD)"
        "Complet  — 7 passes aleatoires (securite max)"
        "--- Annuler"
    )
    AutoMenu "NIVEAU D EFFACEMENT" || return
    local passes
    case $MENU_CHOICE in
        0) passes=1 ;;  1) passes=3 ;; 2) passes=7 ;; *) return ;;
    esac
    echo -e "\n  ${YLW}[~] Effacement de /dev/$dev ($passes passes)...${NC}"
    echo -e "  ${GRY}    Peut prendre plusieurs heures selon la taille.${NC}\n"
    shred -v -n "$passes" -z "/dev/$dev" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Effacement termine.${NC}"
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 5 : DISQUE
# ----------------------------------------------------------------
menu_disque() {
    while true; do
        MENU_OPTS=(
            "Utilisation Disque           — df + top dossiers lourds"
            "Sante SMART                  — Rapport smartctl complet"
            "Gestionnaire de Disque       — format, fsck, mount, fdisk"
            "Benchmark I/O                — Test lecture/ecriture"
            "Effacement Securise          — shred (1/3/7 passes)"
            "--- Retour au menu principal"
        )
        AutoMenu "DISQUE" || return
        case $MENU_CHOICE in
            0) disk_usage ;;
            1) disk_smart ;;
            2) disk_manager ;;
            3) disk_bench ;;
            4) disk_wipe ;;
            5) return ;;
            *) return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 9 : PERSONNALISATION
# ================================================================

sys_theme() {
    clear
    _draw_header "THEME SYSTEME (DARK / LIGHT)"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-inconnu}}"
    echo -e "  Bureau detecte : ${WHT}${de}${NC}\n"

    MENU_OPTS=(
        "Mode Sombre  (Dark)"
        "Mode Clair   (Light)"
        "--- Retour"
    )
    AutoMenu "CHOISIR LE THEME" || return

    case "${de,,}" in
        *gnome*)
            case $MENU_CHOICE in
                0) su -c "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
                          gsettings set org.gnome.desktop.interface color-scheme prefer-dark && \
                          gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark" "$user" 2>/dev/null
                   echo -e "  ${GRN}[✓] GNOME → Dark${NC}" ;;
                1) su -c "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
                          gsettings set org.gnome.desktop.interface color-scheme default && \
                          gsettings set org.gnome.desktop.interface gtk-theme Adwaita" "$user" 2>/dev/null
                   echo -e "  ${GRN}[✓] GNOME → Light${NC}" ;;
                *) return ;;
            esac ;;
        *kde*|*plasma*)
            case $MENU_CHOICE in
                0) su -c "lookandfeeltool -a org.kde.breezedark.desktop" "$user" 2>/dev/null \
                       && echo -e "  ${GRN}[✓] KDE → Breeze Dark${NC}" ;;
                1) su -c "lookandfeeltool -a org.kde.breeze.desktop" "$user" 2>/dev/null \
                       && echo -e "  ${GRN}[✓] KDE → Breeze Light${NC}" ;;
                *) return ;;
            esac ;;
        *xfce*)
            case $MENU_CHOICE in
                0) su -c "xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita-dark" "$user" 2>/dev/null
                   echo -e "  ${GRN}[✓] XFCE → Dark${NC}" ;;
                1) su -c "xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita" "$user" 2>/dev/null
                   echo -e "  ${GRN}[✓] XFCE → Light${NC}" ;;
                *) return ;;
            esac ;;
        *)
            echo -e "  ${YLW}[!] Bureau non supporte pour le changement de theme automatique.${NC}"
            echo -e "  ${GRY}    Bureaux supportes : GNOME, KDE Plasma, XFCE${NC}" ;;
    esac
    _pause
}

sys_aliases() {
    clear
    _draw_header "ALIAS BASH UTILES"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local rc="/home/$user/.bashrc"
    [ -f "/home/$user/.zshrc" ] && rc="/home/$user/.zshrc"

    echo -e "  ${YLW}[ Fichier cible : $rc ]${NC}\n"

    local -A aliases=(
        ["ll"]="ls -alh --color=auto"
        ["la"]="ls -A --color=auto"
        ["l"]="ls -CF --color=auto"
        [".."]="cd .."
        ["..."]="cd ../.."
        ["...."]="cd ../../.."
        ["grep"]="grep --color=auto"
        ["df"]="df -h"
        ["du"]="du -h"
        ["free"]="free -h"
        ["ports"]="ss -tulpn"
        ["myip"]="curl -s ifconfig.me"
        ["update"]="sudo apt update && sudo apt upgrade -y"
        ["clean"]="sudo apt autoremove -y && sudo apt autoclean"
        ["gs"]="git status"
        ["gp"]="git pull"
        ["gc"]="git commit -m"
        ["gco"]="git checkout"
        ["mkcd"]='f(){ mkdir -p "$1" && cd "$1"; }; f'
        ["path"]='echo $PATH | tr ":" "\n"'
        ["cls"]="clear"
        ["reload"]="source ~/.bashrc"
    )

    echo -e "  ${YLW}Alias qui seront ajoutes :${NC}\n"
    for alias_name in "${!aliases[@]}"; do
        printf "  ${CYN}%-12s${NC} = %s\n" "$alias_name" "${aliases[$alias_name]}"
    done | sort

    echo ""
    MENU_OPTS=("Ajouter tous ces alias dans $rc" "Voir les alias actuels" "--- Annuler")
    AutoMenu "ACTION" || return

    case $MENU_CHOICE in
        0)
            echo "" >> "$rc"
            echo "# === Alias AleexLeDev ===" >> "$rc"
            for alias_name in "${!aliases[@]}"; do
                echo "alias ${alias_name}='${aliases[$alias_name]}'" >> "$rc"
            done
            chown "$user:$user" "$rc"
            echo -e "  ${GRN}[✓] ${#aliases[@]} alias ajoutes dans $rc${NC}"
            echo -e "  ${GRY}    Lance : source $rc  pour les activer maintenant${NC}"
            ;;
        1)
            echo ""
            grep "^alias" "$rc" 2>/dev/null | while IFS= read -r l; do echo "  $l"; done \
                || echo -e "  ${GRY}Aucun alias dans $rc${NC}"
            ;;
        *) return ;;
    esac
    _pause
}

sys_gaming_mode() {
    clear
    _draw_header "MODE GAMING"
    echo -e "  ${YLW}[ Optimisations gaming en cours... ]${NC}\n"

    echo -e "  ${YLW}[1/5] CPU → governor performance...${NC}"
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null
    done
    echo -e "  ${GRN}      [✓] Tous les coeurs CPU en mode performance${NC}"

    echo -e "  ${YLW}[2/5] Swappiness → 1 (RAM prioritaire)...${NC}"
    sysctl -w vm.swappiness=1 -q 2>/dev/null
    echo -e "  ${GRN}      [✓] swappiness = 1${NC}"

    echo -e "  ${YLW}[3/5] Latence reseau → optimisation...${NC}"
    sysctl -w net.core.netdev_max_backlog=16384 -q 2>/dev/null
    sysctl -w net.ipv4.tcp_fastopen=3 -q 2>/dev/null
    sysctl -w net.core.rmem_max=16777216 -q 2>/dev/null
    sysctl -w net.core.wmem_max=16777216 -q 2>/dev/null
    echo -e "  ${GRN}      [✓] Buffers reseau augmentes${NC}"

    echo -e "  ${YLW}[4/5] Processus → priorite haute...${NC}"
    sysctl -w kernel.sched_latency_ns=1000000 -q 2>/dev/null || true
    echo -e "  ${GRN}      [✓] Scheduler ajuste${NC}"

    echo -e "  ${YLW}[5/5] GameMode (si installe)...${NC}"
    if command -v gamemoded &>/dev/null; then
        systemctl --user start gamemoded 2>/dev/null \
            && echo -e "  ${GRN}      [✓] GameMode active${NC}" \
            || echo -e "  ${GRY}      (GameMode non demarre)${NC}"
    else
        echo -e "  ${GRY}      GameMode non installe. Optionnel : sudo apt install gamemode${NC}"
    fi

    echo ""
    echo -e "  ${GRN}┌─────────────────────────────────────────┐${NC}"
    echo -e "  ${GRN}│  Mode Gaming ACTIF                      │${NC}"
    echo -e "  ${GRN}│  CPU perf + RAM max + reseau optimise   │${NC}"
    echo -e "  ${GRN}│  Temporaire : reset au prochain reboot  │${NC}"
    echo -e "  ${GRN}└─────────────────────────────────────────┘${NC}"
    _pause
}

sys_hostname() {
    clear
    _draw_header "CHANGER LE NOM DE LA MACHINE"
    local current
    current=$(hostname)
    echo -e "  Hostname actuel : ${WHT}${current}${NC}\n"

    echo -e "  ${YLW}Nouveau hostname (lettres, chiffres, tirets uniquement) :${NC}"
    echo -n "  > "; read -r newname

    if [[ ! "$newname" =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo -e "  ${RED}[✗] Nom invalide. Utilise uniquement lettres, chiffres et tirets.${NC}"
        _pause; return
    fi

    hostnamectl set-hostname "$newname" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    sed -i "s/127\.0\.1\.1\s*${current}/127.0.1.1\t${newname}/g" /etc/hosts 2>/dev/null
    echo -e "  ${GRN}[✓] Hostname change : ${current} → ${newname}${NC}"
    echo -e "  ${GRY}    Reconnecte-toi pour voir le changement dans le prompt.${NC}"
    _pause
}

sys_prompt() {
    clear
    _draw_header "PERSONNALISER LE PROMPT BASH"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local rc="/home/$user/.bashrc"

    MENU_OPTS=(
        "Prompt couleur simple    [user@host:dir]$"
        "Prompt avec git branch   [user@host:dir (branch)]$"
        "Prompt minimaliste       dir >"
        "Prompt heure + couleur   [HH:MM user@host:dir]$"
        "Restaurer le defaut"
        "--- Annuler"
    )
    AutoMenu "CHOISIR UN STYLE" || return

    local ps1=""
    case $MENU_CHOICE in
        0) ps1='PS1='"'"'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"'" ;;
        1) ps1='parse_git_branch() { git branch 2>/dev/null | grep "*" | sed "s/* //"; }
PS1='"'"'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(b=$(parse_git_branch); [ -n "$b" ] && echo " ($b)")\[\033[00m\]\$ '"'" ;;
        2) ps1='PS1='"'"'\[\033[01;34m\]\W\[\033[00m\] > '"'" ;;
        3) ps1='PS1='"'"'[\[\033[01;36m\]\t\[\033[00m\] \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]]\$ '"'" ;;
        4) ps1='unset PS1' ;;
        *) return ;;
    esac

    # Supprimer l'ancien PS1 custom et ajouter le nouveau
    sed -i '/# === Prompt AleexLeDev/,/^$/d' "$rc" 2>/dev/null
    echo "" >> "$rc"
    echo "# === Prompt AleexLeDev ===" >> "$rc"
    echo "$ps1" >> "$rc"
    chown "$user:$user" "$rc"
    echo -e "  ${GRN}[✓] Prompt mis a jour dans $rc${NC}"
    echo -e "  ${GRY}    Lance : source $rc  pour l activer maintenant${NC}"
    _pause
}

sys_autostart() {
    clear
    _draw_header "APPLICATIONS AU DEMARRAGE"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local dir="/home/$user/.config/autostart"
    mkdir -p "$dir"

    echo -e "  ${YLW}[ Applications au demarrage de la session ]${NC}\n"
    if ls "$dir"/*.desktop &>/dev/null; then
        for f in "$dir"/*.desktop; do
            local name exec
            name=$(grep "^Name=" "$f" | head -1 | cut -d= -f2)
            exec=$(grep "^Exec=" "$f" | head -1 | cut -d= -f2)
            printf "  ${GRN}%-30s${GRY} %s${NC}\n" "$name" "$exec"
        done
    else
        echo -e "  ${GRY}  Aucune application configuree en autostart.${NC}"
    fi

    echo ""
    MENU_OPTS=(
        "Ajouter une application en autostart"
        "Supprimer une entree autostart"
        "--- Retour"
    )
    AutoMenu "ACTION" || return

    case $MENU_CHOICE in
        0)
            echo -e "\n  ${YLW}Nom de l application :${NC} "; read -r appname
            echo -e "  ${YLW}Commande a lancer (ex: /usr/bin/spotify) :${NC} "; read -r appcmd
            local desktop="$dir/${appname// /_}.desktop"
            cat > "$desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${appname}
Exec=${appcmd}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
            chown "$user:$user" "$desktop"
            echo -e "  ${GRN}[✓] $appname ajoute en autostart.${NC}"
            ;;
        1)
            local files=("$dir"/*.desktop)
            if [ ! -f "${files[0]}" ]; then
                echo -e "  ${GRY}Rien a supprimer.${NC}"; _pause; return
            fi
            MENU_OPTS=()
            for f in "${files[@]}"; do
                MENU_OPTS+=("$(basename "$f")")
            done
            MENU_OPTS+=("--- Annuler")
            AutoMenu "SUPPRIMER" || return
            local idx=$MENU_CHOICE
            [ $idx -ge ${#files[@]} ] && return
            rm -f "${files[$idx]}"
            echo -e "  ${GRN}[✓] Supprime : $(basename "${files[$idx]}")${NC}"
            ;;
        *) return ;;
    esac
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 9 : PERSONNALISATION
# ----------------------------------------------------------------
menu_personnalisation() {
    while true; do
        MENU_OPTS=(
            "Theme Systeme          — Dark / Light mode"
            "Alias Bash             — Ajouter ~20 alias utiles"
            "Mode Gaming            — CPU perf + reseau optimise"
            "Changer Hostname       — Modifier le nom machine"
            "Personnaliser Prompt   — Style du prompt bash"
            "Apps au Demarrage      — Autostart de session"
            "--- Retour au menu principal"
        )
        AutoMenu "PERSONNALISATION" || return
        case $MENU_CHOICE in
            0) sys_theme ;;
            1) sys_aliases ;;
            2) sys_gaming_mode ;;
            3) sys_hostname ;;
            4) sys_prompt ;;
            5) sys_autostart ;;
            6) return ;;
            *) return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 10 : MATERIEL
# ================================================================

hw_full_report() {
    clear
    _draw_header "RAPPORT MATERIEL COMPLET (lshw)"
    _require lshw || return
    echo -e "  ${YLW}[~] Collecte des informations materiel...${NC}\n"
    lshw -short 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    _pause
}

hw_cpu() {
    clear
    _draw_header "INFORMATIONS CPU"

    echo -e "  ${YLW}[ Modele & Architecture ]${NC}"
    grep -E "model name|vendor_id|cpu MHz|cache size|cpu cores|siblings|flags" /proc/cpuinfo \
        | sort -u | head -10 | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Resume lscpu ]${NC}"
    lscpu 2>/dev/null | grep -E "Architecture|CPU\(s\)|Thread|Core|Socket|Model name|MHz|Cache|Virtuali" \
        | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Frequences actuelles par coeur ]${NC}"
    local core=0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        [ -f "$f" ] || continue
        local freq mhz gov
        freq=$(cat "$f" 2>/dev/null)
        mhz=$((freq / 1000))
        gov=$(cat "${f%scaling_cur_freq}scaling_governor" 2>/dev/null || echo "?")
        printf "  Core %-3s : ${WHT}%s MHz${NC}  [%s]\n" "$core" "$mhz" "$gov"
        ((core++))
    done

    echo -e "\n  ${YLW}[ Temperature CPU ]${NC}"
    if command -v sensors &>/dev/null; then
        sensors 2>/dev/null | grep -iE "core|cpu|temp|°C" | while IFS= read -r l; do echo "  $l"; done
    else
        for zone in /sys/class/thermal/thermal_zone*/; do
            local ztype ztemp
            ztype=$(cat "$zone/type" 2>/dev/null)
            ztemp=$(cat "$zone/temp" 2>/dev/null || echo "0")
            echo "$ztype" | grep -qi "cpu\|x86\|acpi" \
                && printf "  %-20s : ${WHT}%d°C${NC}\n" "$ztype" "$((ztemp / 1000))"
        done
    fi
    _pause
}

hw_gpu() {
    clear
    _draw_header "INFORMATIONS GPU"

    echo -e "  ${YLW}[ GPUs detectes (lspci) ]${NC}"
    lspci | grep -iE "vga|3d|display|render" | while IFS= read -r l; do
        echo -e "  ${WHT}$l${NC}"
    done

    echo -e "\n  ${YLW}[ Driver charge ]${NC}"
    lspci -k | grep -A3 -iE "vga|3d|display" | grep -iE "driver|module" \
        | while IFS= read -r l; do echo "  $l"; done

    if command -v nvidia-smi &>/dev/null; then
        echo -e "\n  ${YLW}[ NVIDIA — nvidia-smi ]${NC}"
        nvidia-smi --query-gpu=name,driver_version,temperature.gpu,memory.used,memory.total,utilization.gpu \
            --format=csv,noheader 2>/dev/null \
            | while IFS=',' read -r name drv temp mu mt util; do
                echo -e "  Modele    : ${WHT}$name${NC}"
                echo -e "  Driver    : ${WHT}$drv${NC}"
                echo -e "  Temp      : ${WHT}$temp°C${NC}"
                echo -e "  VRAM      : ${WHT}$mu / $mt${NC}"
                echo -e "  Utilisation: ${WHT}$util${NC}"
            done
    fi

    if command -v glxinfo &>/dev/null; then
        echo -e "\n  ${YLW}[ OpenGL ]${NC}"
        glxinfo 2>/dev/null | grep -E "vendor|renderer|version" | head -5 \
            | while IFS= read -r l; do echo "  $l"; done
    fi

    if command -v vainfo &>/dev/null; then
        echo -e "\n  ${YLW}[ VA-API (acceleration video) ]${NC}"
        vainfo 2>/dev/null | head -10 | while IFS= read -r l; do echo "  $l"; done
    fi
    _pause
}

hw_ram() {
    clear
    _draw_header "INFORMATIONS RAM"

    echo -e "  ${YLW}[ Utilisation memoire ]${NC}"
    free -h | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Slots physiques (dmidecode) ]${NC}"
    if command -v dmidecode &>/dev/null; then
        dmidecode --type memory 2>/dev/null \
            | grep -E "^Memory Device$|Size:|Type:|Speed:|Manufacturer:|Part Number:|Locator:|Form Factor:" \
            | grep -v "No Module\|Unknown\|Not Specified\|None" \
            | while IFS= read -r l; do echo "  $l"; done
    else
        _require dmidecode
    fi

    echo -e "\n  ${YLW}[ Statistiques vmstat ]${NC}"
    vmstat -s 2>/dev/null | grep -E "total memory|free memory|used memory|buff|cache|swap" \
        | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Top 10 processus consommateurs RAM ]${NC}"
    ps aux --sort=-%mem 2>/dev/null | head -11 \
        | awk 'NR==1{printf "  %-10s %-6s %-6s %s\n",$1,$2,$4,$11}
               NR>1 {printf "  %-10s %-6s %-6s %s\n",$1,$2,$4,$11}'
    _pause
}

hw_smart() {
    clear
    _draw_header "INFORMATIONS DISQUES"

    echo -e "  ${YLW}[ Vue d ensemble ]${NC}\n"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL,TRAN,ROTA 2>/dev/null \
        | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Details par disque ]${NC}"
    local disks
    mapfile -t disks < <(lsblk -dno NAME 2>/dev/null | grep -E "^sd|^nvme|^hd|^vd|^mmcblk")
    for disk in "${disks[@]}"; do
        local size tran rota model
        size=$(lsblk -dno SIZE "/dev/$disk" 2>/dev/null)
        tran=$(lsblk -dno TRAN "/dev/$disk" 2>/dev/null || echo "?")
        rota=$(lsblk -dno ROTA "/dev/$disk" 2>/dev/null)
        model=$(lsblk -dno MODEL "/dev/$disk" 2>/dev/null || echo "?")
        local dtype="HDD"
        [ "$rota" = "0" ] && dtype="SSD/NVMe"
        printf "\n  ${WHT}/dev/%-8s${NC} %-8s %-6s %-8s %s\n" "$disk" "$size" "$dtype" "$tran" "$model"
        if command -v smartctl &>/dev/null; then
            smartctl -H "/dev/$disk" 2>/dev/null | grep -E "SMART overall|result" \
                | while IFS= read -r l; do
                    echo "$l" | grep -qi "passed\|ok" \
                        && echo -e "  ${GRN}  $l${NC}" \
                        || echo -e "  ${RED}  $l${NC}"
                done
        fi
    done
    _pause
}

hw_usb() {
    clear
    _draw_header "PERIPHERIQUES USB"
    _require lsusb usbutils || return
    echo -e "  ${YLW}[ Appareils USB connectes ]${NC}\n"
    lsusb 2>/dev/null | while IFS= read -r l; do echo -e "  ${WHT}$l${NC}"; done
    echo -e "\n  ${YLW}[ Arbre USB ]${NC}\n"
    lsusb -t 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    _pause
}

hw_pci() {
    clear
    _draw_header "PERIPHERIQUES PCI"
    echo -e "  ${YLW}[ Tous les peripheriques PCI ]${NC}\n"
    lspci -v 2>/dev/null | grep -E "^[0-9a-f]|Subsystem|Driver|Kernel driver" \
        | while IFS= read -r l; do
            echo "$l" | grep -qE "^[0-9a-f]" \
                && echo -e "\n  ${WHT}$l${NC}" \
                || echo -e "  ${GRY}  $l${NC}"
        done
    _pause
}

hw_audio() {
    clear
    _draw_header "PERIPHERIQUES AUDIO"
    echo -e "  ${YLW}[ Cartes son (ALSA) ]${NC}"
    aplay -l 2>/dev/null | while IFS= read -r l; do echo "  $l"; done \
        || echo -e "  ${GRY}  aplay non disponible${NC}"
    echo -e "\n  ${YLW}[ Peripheriques audio (PulseAudio/PipeWire) ]${NC}"
    if command -v pactl &>/dev/null; then
        pactl list short sinks 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
        echo ""
        pactl list short sources 2>/dev/null | grep -v monitor | while IFS= read -r l; do echo "  $l"; done
    fi
    if command -v pw-cli &>/dev/null; then
        echo -e "\n  ${YLW}[ PipeWire actif ]${NC}"
        pw-cli info 2>/dev/null | head -5 | while IFS= read -r l; do echo "  $l"; done
    fi
    _pause
}

hw_bluetooth() {
    clear
    _draw_header "BLUETOOTH"
    if ! command -v bluetoothctl &>/dev/null; then
        _require bluetoothctl bluez || return
    fi
    echo -e "  ${YLW}[ Statut service Bluetooth ]${NC}"
    systemctl status bluetooth 2>/dev/null | head -8 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ Controleurs ]${NC}"
    bluetoothctl list 2>/dev/null | while IFS= read -r l; do echo -e "  ${WHT}$l${NC}"; done
    echo -e "\n  ${YLW}[ Appareils appaires ]${NC}"
    bluetoothctl paired-devices 2>/dev/null | while IFS= read -r l; do echo -e "  ${GRN}$l${NC}"; done \
        || echo -e "  ${GRY}  Aucun appareil appaire${NC}"
    _pause
}

# Gouverneur CPU
_set_governor() {
    local gov="$1"
    local count=0
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$gov" > "$cpu" 2>/dev/null && ((count++))
    done
    echo -e "  ${GRN}[✓] Governor = ${WHT}${gov}${NC} sur $count coeur(s)${NC}"
}

pp_current() {
    clear
    _draw_header "PLAN D ALIMENTATION ACTUEL"
    echo -e "  ${YLW}[ Governor par coeur ]${NC}\n"
    local core=0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$f" ] || continue
        local gov freq_cur freq_min freq_max
        gov=$(cat "$f" 2>/dev/null)
        freq_cur=$(cat "${f%scaling_governor}scaling_cur_freq" 2>/dev/null || echo "0")
        freq_min=$(cat "${f%scaling_governor}scaling_min_freq" 2>/dev/null || echo "0")
        freq_max=$(cat "${f%scaling_governor}scaling_max_freq" 2>/dev/null || echo "0")
        printf "  Core %-3s : ${WHT}%-12s${NC} cur=%-6s min=%-6s max=%s MHz\n" \
            "$core" "$gov" "$((freq_cur/1000))" "$((freq_min/1000))" "$((freq_max/1000))"
        ((core++))
    done
    echo -e "\n  ${YLW}[ Governors disponibles ]${NC}"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null \
        | tr ' ' '\n' | while IFS= read -r l; do echo "  $l"; done
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 10 : MATERIEL
# ----------------------------------------------------------------
menu_materiel() {
    while true; do
        MENU_OPTS=(
            "Rapport Materiel Complet   — lshw -short"
            "Infos CPU                  — Freq, coeurs, temp, governor"
            "Infos GPU                  — Detection + NVIDIA/AMD/Intel"
            "Infos RAM                  — Slots, vitesse, usage, top procs"
            "Infos Disques              — lsblk + SMART summary"
            "Peripheriques USB          — lsusb + arbre"
            "Peripheriques PCI          — lspci -v"
            "Audio                      — ALSA + PulseAudio/PipeWire"
            "Bluetooth                  — Controleurs + appareils appaires"
            "--- Governor CPU"
            "  Mode Performance         — governor = performance"
            "  Mode Equilibre           — governor = ondemand"
            "  Mode Economie Batterie   — governor = powersave"
            "  Plan Actuel              — Voir governor + frequences"
            "--- Retour au menu principal"
        )
        AutoMenu "MATERIEL & ALIMENTATION" || return
        case $MENU_CHOICE in
            0)  hw_full_report ;;
            1)  hw_cpu ;;
            2)  hw_gpu ;;
            3)  hw_ram ;;
            4)  hw_smart ;;
            5)  hw_usb ;;
            6)  hw_pci ;;
            7)  hw_audio ;;
            8)  hw_bluetooth ;;
            10) _set_governor "performance" && _pause ;;
            11) _set_governor "ondemand"    && _pause ;;
            12) _set_governor "powersave"   && _pause ;;
            13) pp_current ;;
            14) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 6 : APPLICATIONS
# ================================================================

app_update() {
    clear
    _draw_header "MISE A JOUR DE TOUT LE SYSTEME"

    # [1/4] APT — sortie directe sans pipe (plus rapide)
    echo -e "  ${YLW}[1/4] APT — mise a jour des paquets...${NC}\n"
    apt-get update
    echo ""
    apt-get upgrade -y
    echo -e "\n  ${GRN}[✓] APT termine.${NC}"

    # [2/4] Snap — verif rapide avant de lancer le refresh
    echo -e "\n  ${YLW}[2/4] Snap — mise a jour...${NC}\n"
    if command -v snap &>/dev/null; then
        pending=$(snap refresh --list 2>/dev/null)
        if [ -z "$pending" ]; then
            echo -e "  ${GRY}  Aucune mise a jour Snap disponible.${NC}"
        else
            echo "$pending"
            echo ""
            timeout 120 snap refresh || echo -e "  ${RED}[!] Snap: timeout ou erreur, ignore.${NC}"
        fi
    else
        echo -e "  ${GRY}  Snap non installe, ignore.${NC}"
    fi
    echo -e "  ${GRN}[✓] Snap termine.${NC}"

    # [3/4] Flatpak — verif rapide avant update
    echo -e "\n  ${YLW}[3/4] Flatpak — mise a jour...${NC}\n"
    if command -v flatpak &>/dev/null; then
        pending_fp=$(flatpak remote-ls --updates 2>/dev/null)
        if [ -z "$pending_fp" ]; then
            echo -e "  ${GRY}  Aucune mise a jour Flatpak disponible.${NC}"
        else
            timeout 180 flatpak update -y || echo -e "  ${RED}[!] Flatpak: timeout ou erreur, ignore.${NC}"
        fi
    else
        echo -e "  ${GRY}  Flatpak non installe, ignore.${NC}"
    fi
    echo -e "  ${GRN}[✓] Flatpak termine.${NC}"

    # [4/4] Pip — batch en une seule commande
    echo -e "\n  ${YLW}[4/4] Pip — mise a jour des paquets globaux...${NC}\n"
    if command -v pip3 &>/dev/null; then
        outdated=$(pip3 list --outdated --format=freeze 2>/dev/null | cut -d= -f1 | tr '\n' ' ')
        if [ -n "$outdated" ]; then
            pip3 install --upgrade $outdated
            echo -e "  ${GRN}[✓] Pip mis a jour.${NC}"
        else
            echo -e "  ${GRY}  Aucune mise a jour pip disponible.${NC}"
        fi
    else
        echo -e "  ${GRY}  pip3 non installe, ignore.${NC}"
    fi

    echo -e "\n  ${GRN}[✓] Systeme entierement mis a jour.${NC}"
    _pause
}

app_list() {
    clear
    _draw_header "APPLICATIONS INSTALLEES"

    MENU_OPTS=(
        "Paquets APT installes manuellement"
        "Tous les paquets APT"
        "Applications Snap"
        "Applications Flatpak"
        "--- Retour"
    )
    AutoMenu "SOURCE" || return

    case $MENU_CHOICE in
        0)
            clear; _draw_header "PAQUETS APT — INSTALLATION MANUELLE"
            echo -e "  ${GRY}(paquets que tu as installes toi-meme, pas les dependances)${NC}\n"
            apt-mark showmanual 2>/dev/null | sort | while IFS= read -r l; do echo "  $l"; done
            ;;
        1)
            clear; _draw_header "TOUS LES PAQUETS APT"
            dpkg -l 2>/dev/null | grep "^ii" | awk '{printf "  %-35s %s\n", $2, $3}' \
                | while IFS= read -r l; do echo "$l"; done
            ;;
        2)
            clear; _draw_header "APPLICATIONS SNAP"
            if command -v snap &>/dev/null; then
                snap list 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
            else
                echo -e "  ${GRY}Snap non installe.${NC}"
            fi
            ;;
        3)
            clear; _draw_header "APPLICATIONS FLATPAK"
            if command -v flatpak &>/dev/null; then
                flatpak list --app 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
            else
                echo -e "  ${GRY}Flatpak non installe.${NC}"
            fi
            ;;
        *) return ;;
    esac
    _pause
}

app_search() {
    clear
    _draw_header "RECHERCHER UN PAQUET"

    echo -e "  ${YLW}Nom ou mot-cle a rechercher :${NC}"
    echo -n "  > "; read -r query

    if [ -z "$query" ]; then return; fi

    clear
    _draw_header "RESULTATS POUR : $query"

    echo -e "  ${YLW}[ APT ]${NC}\n"
    apt-cache search "$query" 2>/dev/null | sort | head -30 \
        | while IFS= read -r l; do
            echo "  $l" | awk '{printf "  \033[1;37m%-30s\033[0m %s\n", $1, substr($0, index($0,$2))}'
        done

    if command -v snap &>/dev/null; then
        echo -e "\n  ${YLW}[ Snap ]${NC}\n"
        snap find "$query" 2>/dev/null | head -10 | while IFS= read -r l; do echo "  $l"; done
    fi

    if command -v flatpak &>/dev/null; then
        echo -e "\n  ${YLW}[ Flatpak ]${NC}\n"
        flatpak search "$query" 2>/dev/null | head -10 | while IFS= read -r l; do echo "  $l"; done
    fi
    _pause
}

app_remove() {
    clear
    _draw_header "SUPPRIMER UNE APPLICATION"

    echo -e "  ${YLW}Nom du paquet a supprimer :${NC}"
    echo -n "  > "; read -r pkg

    if [ -z "$pkg" ]; then return; fi

    echo -e "\n  ${YLW}[ Info paquet ]${NC}"
    dpkg -l "$pkg" 2>/dev/null | grep "^ii" | awk '{printf "  %-30s %s\n", $2, $5}' \
        || echo -e "  ${GRY}  Paquet non trouve dans APT.${NC}"

    MENU_OPTS=(
        "Supprimer (garde les configs)"
        "Supprimer + configs (purge)"
        "Supprimer + configs + dependances"
        "--- Annuler"
    )
    AutoMenu "MODE DE SUPPRESSION" || return

    echo ""
    case $MENU_CHOICE in
        0) apt-get remove -y "$pkg" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
        1) apt-get purge -y "$pkg" 2>&1 | while IFS= read -r l; do echo "  $l"; done ;;
        2) apt-get purge -y "$pkg" 2>&1 | while IFS= read -r l; do echo "  $l"; done
           apt-get autoremove -y 2>&1 | tail -3 | while IFS= read -r l; do echo "  $l"; done ;;
        *) return ;;
    esac
    echo -e "\n  ${GRN}[✓] Suppression terminee.${NC}"
    _pause
}

app_info() {
    clear
    _draw_header "INFORMATIONS PAQUET"

    echo -e "  ${YLW}Nom du paquet :${NC}"
    echo -n "  > "; read -r pkg

    if [ -z "$pkg" ]; then return; fi

    clear
    _draw_header "INFO : $pkg"

    echo -e "  ${YLW}[ APT ]${NC}\n"
    apt-cache show "$pkg" 2>/dev/null \
        | grep -E "^Package|^Version|^Installed-Size|^Depends|^Description|^Homepage|^Section|^Maintainer" \
        | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Statut installation ]${NC}"
    dpkg -l "$pkg" 2>/dev/null | grep "^ii\|^rc" | while IFS= read -r l; do echo "  $l"; done \
        || echo -e "  ${GRY}  Non installe${NC}"

    echo -e "\n  ${YLW}[ Fichiers installes ]${NC}"
    dpkg -L "$pkg" 2>/dev/null | head -20 | while IFS= read -r l; do echo "  $l"; done
    _pause
}

# Installateur rapide par categorie
app_install() {
    while true; do
        MENU_OPTS=(
            "Navigateurs Web"
            "Developpement"
            "Multimedia"
            "Bureautique"
            "Utilitaires Terminal"
            "Securite & Reseau"
            "Communication"
            "Virtualisation"
            "Installer un paquet manuellement"
            "--- Retour"
        )
        AutoMenu "INSTALLATEUR RAPIDE — CATEGORIE" || return
        local cat=$MENU_CHOICE

        local -a pkgs=()
        local title=""

        case $cat in
            0)
                title="NAVIGATEURS WEB"
                MENU_OPTS=(
                    "Firefox            — Navigateur Mozilla"
                    "Chromium           — Chrome open-source"
                    "Brave              — Navigateur prive (Snap)"
                    "Vivaldi            — Navigateur personnalisable"
                    "Lynx               — Navigateur terminal"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) pkgs=("firefox") ;;
                    1) pkgs=("chromium-browser" "chromium") ;;
                    2) _install_snap "brave" ; continue ;;
                    3) _install_vivaldi ; continue ;;
                    4) pkgs=("lynx") ;;
                    *) continue ;;
                esac ;;
            1)
                title="DEVELOPPEMENT"
                MENU_OPTS=(
                    "VSCode             — Editeur Microsoft (Snap)"
                    "Git                — Gestionnaire de versions"
                    "Node.js + npm      — Runtime JavaScript"
                    "Python3 + pip      — Python et outils"
                    "Docker             — Containerisation"
                    "Vim / Neovim       — Editeur terminal"
                    "Build essentials   — gcc, make, cmake..."
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) _install_snap "code --classic" ; continue ;;
                    1) pkgs=("git") ;;
                    2) pkgs=("nodejs" "npm") ;;
                    3) pkgs=("python3" "python3-pip" "python3-venv") ;;
                    4) _install_docker ; continue ;;
                    5) MENU_OPTS=("Vim" "Neovim" "--- Retour")
                       AutoMenu "EDITEUR" || continue
                       [ $MENU_CHOICE -eq 0 ] && pkgs=("vim")
                       [ $MENU_CHOICE -eq 1 ] && pkgs=("neovim") ;;
                    6) pkgs=("build-essential" "cmake" "pkg-config") ;;
                    *) continue ;;
                esac ;;
            2)
                title="MULTIMEDIA"
                MENU_OPTS=(
                    "VLC                — Lecteur video universel"
                    "mpv                — Lecteur video leger"
                    "Audacity           — Editeur audio"
                    "GIMP               — Retouche photo"
                    "Kdenlive           — Montage video"
                    "OBS Studio         — Capture/streaming (Flatpak)"
                    "Spotify            — Musique en streaming (Snap)"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) pkgs=("vlc") ;;
                    1) pkgs=("mpv") ;;
                    2) pkgs=("audacity") ;;
                    3) pkgs=("gimp") ;;
                    4) pkgs=("kdenlive") ;;
                    5) _install_flatpak "com.obsproject.Studio" ; continue ;;
                    6) _install_snap "spotify" ; continue ;;
                    *) continue ;;
                esac ;;
            3)
                title="BUREAUTIQUE"
                MENU_OPTS=(
                    "LibreOffice        — Suite bureautique complete"
                    "Thunderbird        — Client mail"
                    "Okular             — Lecteur PDF"
                    "Evince             — Visionneuse documents"
                    "Calibre            — Gestion ebooks"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) pkgs=("libreoffice") ;;
                    1) pkgs=("thunderbird") ;;
                    2) pkgs=("okular") ;;
                    3) pkgs=("evince") ;;
                    4) pkgs=("calibre") ;;
                    *) continue ;;
                esac ;;
            4)
                title="UTILITAIRES TERMINAL"
                MENU_OPTS=(
                    "htop               — Moniteur de processus"
                    "btop               — Moniteur ressources avance"
                    "neofetch           — Infos systeme stylisees"
                    "tmux               — Multiplexeur terminal"
                    "bat                — cat ameliore avec couleurs"
                    "fzf                — Recherche floue interactif"
                    "ripgrep            — grep ultra-rapide"
                    "tree               — Affichage arborescence"
                    "ncdu               — Analyseur espace disque TUI"
                    "Tous les utilitaires"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) pkgs=("htop") ;;
                    1) pkgs=("btop") ;;
                    2) pkgs=("neofetch") ;;
                    3) pkgs=("tmux") ;;
                    4) pkgs=("bat") ;;
                    5) pkgs=("fzf") ;;
                    6) pkgs=("ripgrep") ;;
                    7) pkgs=("tree") ;;
                    8) pkgs=("ncdu") ;;
                    9) pkgs=("htop" "btop" "neofetch" "tmux" "bat" "fzf" "ripgrep" "tree" "ncdu") ;;
                    *) continue ;;
                esac ;;
            5)
                title="SECURITE & RESEAU"
                MENU_OPTS=(
                    "nmap               — Scanner reseau"
                    "Wireshark          — Analyseur de trafic"
                    "ClamAV             — Antivirus"
                    "ufw                — Pare-feu simplifie"
                    "fail2ban           — Protection brute-force"
                    "aircrack-ng        — Audit WiFi"
                    "netcat             — Couteau suisse reseau"
                    "curl + wget        — Transferts HTTP"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) pkgs=("nmap") ;;
                    1) pkgs=("wireshark") ;;
                    2) pkgs=("clamav" "clamav-daemon") ;;
                    3) pkgs=("ufw") ;;
                    4) pkgs=("fail2ban") ;;
                    5) pkgs=("aircrack-ng") ;;
                    6) pkgs=("netcat-openbsd") ;;
                    7) pkgs=("curl" "wget") ;;
                    *) continue ;;
                esac ;;
            6)
                title="COMMUNICATION"
                MENU_OPTS=(
                    "Discord            — Chat gaming (Deb officiel)"
                    "Telegram           — Messagerie (Snap)"
                    "Signal             — Messagerie chiffree (Snap)"
                    "Slack              — Messagerie pro (Snap)"
                    "Zoom               — Videoconference (Snap)"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) _install_discord ; continue ;;
                    1) _install_snap "telegram-desktop" ; continue ;;
                    2) _install_snap "signal-desktop" ; continue ;;
                    3) _install_snap "slack --classic" ; continue ;;
                    4) _install_snap "zoom-client" ; continue ;;
                    *) continue ;;
                esac ;;
            7)
                title="VIRTUALISATION"
                MENU_OPTS=(
                    "VirtualBox         — Virtualisation complete"
                    "QEMU + KVM         — Virtualisation native"
                    "Virt-Manager       — Interface QEMU/KVM"
                    "--- Retour"
                )
                AutoMenu "$title" || continue
                case $MENU_CHOICE in
                    0) pkgs=("virtualbox") ;;
                    1) pkgs=("qemu-kvm" "libvirt-daemon-system") ;;
                    2) pkgs=("qemu-kvm" "libvirt-daemon-system" "virt-manager" "bridge-utils") ;;
                    *) continue ;;
                esac ;;
            8)
                clear; _draw_header "INSTALLER UN PAQUET MANUELLEMENT"
                echo -e "  ${YLW}Nom du paquet APT :${NC}"
                echo -n "  > "; read -r pkg
                [ -z "$pkg" ] && continue
                pkgs=("$pkg")
                ;;
            *) return ;;
        esac

        if [ ${#pkgs[@]} -gt 0 ]; then
            clear
            _draw_header "INSTALLATION : ${pkgs[*]}"
            echo -e "  ${YLW}[~] Installation de : ${WHT}${pkgs[*]}${NC}\n"
            apt-get update -qq 2>/dev/null
            DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" 2>&1 \
                | while IFS= read -r l; do echo "  $l"; done
            if command -v "${pkgs[0]}" &>/dev/null || dpkg -l "${pkgs[0]}" &>/dev/null; then
                echo -e "\n  ${GRN}[✓] Installation reussie : ${pkgs[*]}${NC}"
            fi
            _pause
        fi
    done
}

# Helpers installateurs speciaux
_install_snap() {
    local pkg="$1"
    clear; _draw_header "INSTALLATION SNAP : $pkg"
    _require snap snapd || return
    snap install $pkg 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] $pkg installe via Snap.${NC}"
    _pause
}

_install_flatpak() {
    local appid="$1"
    clear; _draw_header "INSTALLATION FLATPAK : $appid"
    _require flatpak || return
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null
    flatpak install flathub "$appid" -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] $appid installe via Flatpak.${NC}"
    _pause
}

_install_docker() {
    clear; _draw_header "INSTALLATION DOCKER"
    echo -e "  ${YLW}[~] Installation Docker officielle...${NC}\n"
    apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null | tail -2 \
        | while IFS= read -r l; do echo "  $l"; done
    apt-get install -y ca-certificates curl gnupg 2>/dev/null | tail -2 \
        | while IFS= read -r l; do echo "  $l"; done
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list
    apt-get update -qq 2>/dev/null
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>&1 \
        | while IFS= read -r l; do echo "  $l"; done
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    usermod -aG docker "$user" 2>/dev/null
    systemctl enable --now docker 2>/dev/null
    echo -e "\n  ${GRN}[✓] Docker installe. $user ajoute au groupe docker.${NC}"
    echo -e "  ${GRY}    Reconnecte-toi pour utiliser docker sans sudo.${NC}"
    _pause
}

_install_discord() {
    clear; _draw_header "INSTALLATION DISCORD"
    echo -e "  ${YLW}[~] Telechargement du paquet officiel...${NC}\n"
    local tmp="/tmp/discord.deb"
    curl -L "https://discord.com/api/download?platform=linux&format=deb" -o "$tmp" 2>&1 \
        | while IFS= read -r l; do echo "  $l"; done
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp" 2>&1 \
        | while IFS= read -r l; do echo "  $l"; done
    rm -f "$tmp"
    echo -e "\n  ${GRN}[✓] Discord installe.${NC}"
    _pause
}

_install_vivaldi() {
    clear; _draw_header "INSTALLATION VIVALDI"
    echo -e "  ${YLW}[~] Ajout du depot officiel Vivaldi...${NC}\n"
    curl -fsSL https://repo.vivaldi.com/archive/linux_signing_key.pub \
        | gpg --dearmor -o /usr/share/keyrings/vivaldi-browser.gpg 2>/dev/null
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] \
https://repo.vivaldi.com/archive/deb/ stable main" \
        > /etc/apt/sources.list.d/vivaldi.list
    apt-get update -qq 2>/dev/null
    DEBIAN_FRONTEND=noninteractive apt-get install -y vivaldi-stable 2>&1 \
        | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Vivaldi installe.${NC}"
    _pause
}

app_snap_mgr() {
    clear
    _draw_header "GESTIONNAIRE SNAP"
    _require snap snapd || return
    echo -e "  ${YLW}[ Snaps installes ]${NC}\n"
    snap list 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo ""
    MENU_OPTS=(
        "Mettre a jour tous les snaps"
        "Supprimer un snap"
        "Voir les anciennes revisions"
        "--- Retour"
    )
    AutoMenu "ACTION SNAP" || return
    case $MENU_CHOICE in
        0)
            echo ""
            snap refresh 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        1)
            echo -e "\n  ${YLW}Nom du snap a supprimer :${NC} "; read -r pkg
            snap remove "$pkg" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        2)
            snap list --all 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
            ;;
        *) return ;;
    esac
    _pause
}

app_flatpak_mgr() {
    clear
    _draw_header "GESTIONNAIRE FLATPAK"
    _require flatpak || return
    echo -e "  ${YLW}[ Applications Flatpak installees ]${NC}\n"
    flatpak list --app 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo ""
    MENU_OPTS=(
        "Mettre a jour tous les flatpaks"
        "Supprimer une application"
        "Ajouter le depot Flathub"
        "Nettoyer les runtimes inutilises"
        "--- Retour"
    )
    AutoMenu "ACTION FLATPAK" || return
    case $MENU_CHOICE in
        0)
            echo ""
            flatpak update -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        1)
            echo -e "\n  ${YLW}ID de l application (ex: com.spotify.Client) :${NC} "; read -r pkg
            flatpak remove -y "$pkg" 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        2)
            flatpak remote-add --if-not-exists flathub \
                https://flathub.org/repo/flathub.flatpakrepo 2>&1 \
                | while IFS= read -r l; do echo "  $l"; done
            echo -e "  ${GRN}[✓] Flathub ajoute.${NC}"
            ;;
        3)
            flatpak uninstall --unused -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
            ;;
        *) return ;;
    esac
    _pause
}

# ----------------------------------------------------------------
#  MENU CATEGORIE 6 : APPLICATIONS
# ----------------------------------------------------------------
menu_applications() {
    while true; do
        MENU_OPTS=(
            "Tout Mettre a Jour       — apt + snap + flatpak + pip"
            "Liste des Applications   — APT / Snap / Flatpak"
            "Rechercher un Paquet     — apt-cache + snap + flatpak"
            "Installateur Rapide      — Par categorie (browsers, dev...)"
            "Supprimer une App        — apt remove / purge"
            "Infos sur un Paquet      — apt-cache show + dpkg"
            "Gestionnaire Snap        — list, update, remove"
            "Gestionnaire Flatpak     — list, update, remove"
            "--- Retour au menu principal"
        )
        AutoMenu "APPLICATIONS" || return
        case $MENU_CHOICE in
            0) app_update ;;
            1) app_list ;;
            2) app_search ;;
            3) app_install ;;
            4) app_remove ;;
            5) app_info ;;
            6) app_snap_mgr ;;
            7) app_flatpak_mgr ;;
            8) return ;;
            *) return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 4 : RESEAU & CYBER
#  Workflows guidés : chaque étape s'enchaîne sur les résultats
# ================================================================

# Contexte partagé entre les étapes du workflow
declare -g NET_TARGET="" NET_OPEN_PORTS="" NET_WIFI_SSID="" NET_WIFI_BSSID="" NET_WIFI_CHAN=""

# ----------------------------------------------------------------
#  WORKFLOW LAN / PENTEST
#  Etape 1 : Info locale + scan LAN  →  sélection cible
#  Etape 2 : Scan ports sur cible    →  actions selon ports trouvés
# ----------------------------------------------------------------
net_workflow_lan() {
    while true; do
        # --- Etape 1 : Info réseau local ---
        clear
        _draw_header "RESEAU & PENTEST LAN"

        _require nmap nmap || return

        local iface subnet local_ip gw
        iface=$(ip route | awk '/default/{print $5; exit}')
        local_ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')
        subnet=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{print $2; exit}')
        gw=$(ip route | awk '/default/{print $3; exit}')

        echo -e "  ${YLW}[ Réseau local ]${NC}"
        echo -e "  Interface   : ${WHT}${iface}${NC}"
        echo -e "  IP locale   : ${WHT}${local_ip}${NC}"
        echo -e "  Passerelle  : ${WHT}${gw}${NC}"
        echo -e "  Sous-réseau : ${WHT}${subnet}${NC}\n"

        if [ -z "$subnet" ]; then
            echo -e "  ${RED}[✗] Impossible de détecter le sous-réseau.${NC}"; _pause; return
        fi

        echo -e "  ${YLW}[~] Scan ping LAN en cours...${NC}\n"
        echo -e "  ${GRY}(les hôtes apparaissent au fur et à mesure)${NC}\n"

        # Scan en temps réel : affiche la progression + sauvegarde pour parsing
        local nmap_tmp="/tmp/aleex_nmap_$$.txt"
        nmap -sn -v "$subnet" 2>/dev/null | tee "$nmap_tmp" | \
            grep --line-buffered -E "report for|MAC Address|Initiating|Completed|Stats:" | \
            while IFS= read -r l; do
                if [[ "$l" == *"report for"* ]]; then
                    echo -e "  ${GRN}  ●${NC}  ${l#*report for }"
                else
                    echo -e "  ${GRY}  $l${NC}"
                fi
            done

        local nmap_out
        nmap_out=$(cat "$nmap_tmp")
        rm -f "$nmap_tmp"
        echo ""

        local -a hosts_display hosts_ips
        local cur_ip="" cur_hostname="" cur_mac="" cur_vendor=""

        _flush_host() {
            [ -z "$cur_ip" ] && return
            [[ "$cur_ip" == "$local_ip" ]] && return
            hosts_ips+=("$cur_ip")
            local vshort="${cur_vendor:0:18}"
            hosts_display+=("$(printf '%-15s  %-17s  %-18s  %s' \
                "$cur_ip" "${cur_mac:--}" "${vshort:--}" "${cur_hostname}")")
        }

        while IFS= read -r line; do
            if [[ "$line" == *"Nmap scan report for"* ]]; then
                _flush_host
                local info="${line#*Nmap scan report for }"
                if [[ "$info" == *"("*")"* ]]; then
                    cur_hostname="${info% (*}"
                    cur_ip="${info##*(}"; cur_ip="${cur_ip%)*}"
                else
                    cur_ip="$info"; cur_hostname=""
                fi
                cur_mac=""; cur_vendor=""
            elif [[ "$line" == *"MAC Address:"* ]]; then
                cur_mac=$(echo "$line" | awk '{print $3}')
                cur_vendor=$(echo "$line" | sed 's/.*MAC Address: [^ ]* //' | tr -d '()')
            fi
        done <<< "$nmap_out"
        _flush_host
        unset -f _flush_host

        if [ ${#hosts_ips[@]} -eq 0 ]; then
            echo -e "  ${GRY}Aucun hôte trouvé sur ${subnet}.${NC}"; _pause; return
        fi

        # Tableau récapitulatif
        echo -e "  ${GRN}[✓] ${#hosts_ips[@]} hôte(s) trouvé(s) :${NC}\n"
        printf "  ${YLW}%-15s  %-17s  %-18s  %s${NC}\n" "IP" "MAC" "FABRICANT" "NOM"
        echo -e "  ${GRY}$(printf '─%.0s' {1..65})${NC}"
        for h in "${hosts_display[@]}"; do echo -e "  ${WHT}$h${NC}"; done
        echo ""

        # --- Etape 2 : Sélection de la cible ---
        MENU_OPTS=("${hosts_display[@]}" "--- Retour")
        AutoMenu "SELECTIONNER CIBLE" || return
        [ $MENU_CHOICE -ge ${#hosts_ips[@]} ] && return

        NET_TARGET="${hosts_ips[$MENU_CHOICE]}"

        # --- Etape 3 : Scan ports automatique sur la cible ---
        clear
        _draw_header "CIBLE : ${NET_TARGET}"
        echo -e "  ${YLW}[~] Scan des ports (top 200, SYN -T4)...${NC}\n"

        local port_out
        port_out=$(nmap -sS -T4 --top-ports 200 "$NET_TARGET" 2>/dev/null)
        echo "$port_out" | grep -E "^PORT|open|filtered" | while IFS= read -r l; do echo "  $l"; done

        NET_OPEN_PORTS=$(echo "$port_out" | awk '/open/{split($1,a,"/"); printf a[1]","}')
        local port_count
        port_count=$(echo "$port_out" | grep -c "open" 2>/dev/null || echo 0)

        echo -e "\n  ${GRN}[✓] ${port_count} port(s) ouvert(s) : ${NET_OPEN_PORTS%,}${NC}\n"

        # --- Etape 4 : Menu d'actions adapté aux ports trouvés ---
        local -a action_labels action_keys
        action_labels+=("Enum Services détaillée  — nmap -sV sur la cible")
        action_keys+=("enum")
        action_labels+=("Check Vulnérabilités     — SMB, FTP anon, SSH")
        action_keys+=("vuln")
        if echo "$NET_OPEN_PORTS" | grep -qE "^(80|443|8080|8443),|,(80|443|8080|8443),|,(80|443|8080|8443)$"; then
            action_labels+=("Web Interface Hunt       — Ports 80/443/8080/8443")
            action_keys+=("web")
        fi
        if echo "$NET_OPEN_PORTS" | grep -qE "22,|,22,|,22$|^22$"; then
            action_labels+=("SSH Audit               — Version + méthodes auth")
            action_keys+=("ssh")
        fi
        action_labels+=("Choisir une autre cible")
        action_keys+=("back")

        MENU_OPTS=("${action_labels[@]}" "--- Retour au menu réseau")
        AutoMenu "ACTION SUR ${NET_TARGET}" || return

        local action="${action_keys[$MENU_CHOICE]}"

        case "$action" in
            enum)
                clear; _draw_header "ENUM SERVICES : ${NET_TARGET}"
                echo -e "  ${YLW}[~] nmap -sV (détection de version)...${NC}\n"
                nmap -sS -T4 -sV "$NET_TARGET" 2>&1 | while IFS= read -r l; do echo "  $l"; done
                _pause ;;
            vuln)
                clear; _draw_header "VULNERABILITES : ${NET_TARGET}"
                echo -e "  ${YLW}[1/3] Partages SMB...${NC}\n"
                nmap -sS -T4 -p 139,445 --script smb-enum-shares,smb-security-mode "$NET_TARGET" 2>&1 \
                    | grep -Ev "^Starting|^Warning" | while IFS= read -r l; do echo "  $l"; done
                echo -e "\n  ${YLW}[2/3] FTP anonyme...${NC}\n"
                nmap -sS -T4 -p 21 --script ftp-anon "$NET_TARGET" 2>&1 \
                    | grep -Ev "^Starting|^Warning" | while IFS= read -r l; do echo "  $l"; done
                echo -e "\n  ${YLW}[3/3] SSH auth methods...${NC}\n"
                nmap -sS -T4 -p 22 --script ssh-auth-methods "$NET_TARGET" 2>&1 \
                    | grep -Ev "^Starting|^Warning" | while IFS= read -r l; do echo "  $l"; done
                _pause ;;
            web)
                clear; _draw_header "WEB HUNT : ${NET_TARGET}"
                echo -e "  ${YLW}[~] Interfaces web trouvées :${NC}\n"
                nmap -sS -T4 -p 80,443,8080,8443 --open "$NET_TARGET" 2>&1 \
                    | while IFS= read -r l; do echo "  $l"; done
                _pause ;;
            ssh)
                clear; _draw_header "SSH AUDIT : ${NET_TARGET}"
                nmap -sS -T4 -p 22 --script ssh-auth-methods,ssh2-enum-algos "$NET_TARGET" 2>&1 \
                    | while IFS= read -r l; do echo "  $l"; done
                _pause ;;
            back)
                # Reboucle pour choisir une autre cible (retour au scan LAN)
                continue ;;
            *)
                return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  WORKFLOW WIFI
#  Etape 1 : Scan des réseaux  →  sélection SSID
#  Etape 2 : Affichage détails →  Analyser ou Cracker (BSSID/chan pré-remplis)
# ----------------------------------------------------------------
net_workflow_wifi() {
    while true; do
        clear
        _draw_header "WIFI — SCAN & ANALYSE"

        if ! command -v nmcli &>/dev/null; then
            _require nmcli network-manager || return
        fi

        echo -e "  ${YLW}[~] Scan WiFi en cours...${NC}\n"
        nmcli dev wifi rescan 2>/dev/null
        sleep 1

        # Collecte des réseaux
        local -a w_ssids w_bssids w_chans w_signals w_secs w_menu

        while IFS= read -r raw; do
            [[ -z "$raw" ]] && continue
            # Format nmcli -t : SSID:AA\:BB\:CC\:DD\:EE\:FF:CHAN:SIGNAL:SECURITY
            # On remplace les \: (dans BSSID) par | pour éviter la confusion avec le séparateur
            local line
            line=$(echo "$raw" | sed 's/\\:/|/g')
            local ssid bssid chan signal sec
            ssid="${line%%:*}"
            local rest="${line#*:}"
            bssid="${rest%%:*}"; bssid="${bssid//|/:}"
            rest="${rest#*:}"
            chan="${rest%%:*}"
            rest="${rest#*:}"
            signal="${rest%%:*}"
            sec="${rest#*:}"

            [[ -z "$bssid" ]] && continue
            w_ssids+=("${ssid:-(caché)}")
            w_bssids+=("$bssid")
            w_chans+=("$chan")
            w_signals+=("$signal")
            w_secs+=("$sec")
            w_menu+=("$(printf '%-25s  ch:%-3s  sig:%-4s  %s' "${ssid:-(caché)}" "$chan" "$signal" "$sec")")
        done < <(nmcli -t -f SSID,BSSID,CHAN,SIGNAL,SECURITY dev wifi list 2>/dev/null)

        if [ ${#w_ssids[@]} -eq 0 ]; then
            echo -e "  ${GRY}Aucun réseau WiFi détecté.${NC}"; _pause; return
        fi

        echo -e "  ${GRN}[✓] ${#w_ssids[@]} réseau(x) trouvé(s).${NC}\n"

        # Sélection du réseau
        MENU_OPTS=("${w_menu[@]}" "--- Retour")
        AutoMenu "SELECTIONNER RESEAU" || return
        [ $MENU_CHOICE -ge ${#w_ssids[@]} ] && return

        local idx=$MENU_CHOICE
        NET_WIFI_SSID="${w_ssids[$idx]}"
        NET_WIFI_BSSID="${w_bssids[$idx]}"
        NET_WIFI_CHAN="${w_chans[$idx]}"

        # Affichage des détails (automatique)
        clear
        _draw_header "WIFI : ${NET_WIFI_SSID}"
        echo -e "  SSID      : ${WHT}${NET_WIFI_SSID}${NC}"
        echo -e "  BSSID     : ${WHT}${NET_WIFI_BSSID}${NC}"
        echo -e "  Canal     : ${WHT}${NET_WIFI_CHAN}${NC}"
        echo -e "  Signal    : ${WHT}${w_signals[$idx]}${NC}"
        echo -e "  Sécurité  : ${WHT}${w_secs[$idx]}${NC}\n"

        # Affichage nmcli complet si disponible
        if [ -n "$NET_WIFI_BSSID" ]; then
            echo -e "  ${YLW}[ Détails nmcli ]${NC}\n"
            nmcli -f all dev wifi list bssid "$NET_WIFI_BSSID" 2>/dev/null \
                | while IFS= read -r l; do echo "  $l"; done
            echo ""
        fi

        # Actions
        MENU_OPTS=(
            "Cracker (WPA2)   — Aircrack-ng (BSSID + canal pré-remplis)"
            "Rafraîchir       — Rescanner et choisir un autre réseau"
            "--- Retour"
        )
        AutoMenu "ACTION" || return

        case $MENU_CHOICE in
            0) _wifi_crack_workflow "$NET_WIFI_BSSID" "$NET_WIFI_CHAN" ;;
            1) continue ;;  # rescanner
            *) return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  SOUS-FONCTION : crack WPA2 avec BSSID et canal déjà connus
# ----------------------------------------------------------------
_wifi_crack_workflow() {
    local bssid="$1" channel="$2"
    clear
    _draw_header "WPA2 CRACK — AIRCRACK-NG"
    echo -e "  ${RED}╔══════════════════════════════════════════╗${NC}"
    echo -e "  ${RED}║  USAGE LÉGAL UNIQUEMENT                  ║${NC}"
    echo -e "  ${RED}║  Ton propre réseau ou autorisation.       ║${NC}"
    echo -e "  ${RED}╚══════════════════════════════════════════╝${NC}\n"

    # Avertissement WiFi AVANT toute action
    echo -e "  ${YLW}⚠  ATTENTION : Le mode monitor va couper ton WiFi.${NC}"
    echo -e "  ${YLW}   NetworkManager sera arrêté pendant la capture,${NC}"
    echo -e "  ${YLW}   puis redémarré automatiquement à la fin.${NC}\n"

    MENU_OPTS=(
        "Continuer   — Je comprends, mon WiFi va se couper"
        "--- Annuler"
    )
    AutoMenu "CONFIRMATION" || return
    [ $MENU_CHOICE -ne 0 ] && return

    _require aircrack-ng aircrack-ng || return
    _require airmon-ng  aircrack-ng  || return
    _require airodump-ng aircrack-ng || return

    local -a ifaces
    while IFS= read -r l; do ifaces+=("$l"); done < <(iw dev 2>/dev/null | awk '/Interface/{print $2}')
    if [ ${#ifaces[@]} -eq 0 ]; then
        echo -e "  ${RED}[✗] Aucune interface WiFi détectée.${NC}"; _pause; return
    fi

    local iface
    if [ ${#ifaces[@]} -eq 1 ]; then
        iface="${ifaces[0]}"
        echo -e "  ${GRY}Interface : ${WHT}${iface}${NC}\n"
    else
        MENU_OPTS=("${ifaces[@]}" "--- Annuler")
        AutoMenu "INTERFACE WIFI" || return
        [ $MENU_CHOICE -ge ${#ifaces[@]} ] && return
        iface="${ifaces[$MENU_CHOICE]}"
    fi

    echo -e "  BSSID : ${WHT}${bssid}${NC}  |  Canal : ${WHT}${channel}${NC}\n"

    # Nettoyage garanti même sur Ctrl+C
    local mon=""
    local cap="/tmp/aleex_cap_$$"
    _crack_cleanup() {
        [ -n "$mon" ] && airmon-ng stop "$mon" 2>/dev/null
        rm -f "${cap}"* 2>/dev/null
        echo -e "\n  ${YLW}[~] Restauration du WiFi (NetworkManager)...${NC}"
        systemctl restart NetworkManager 2>/dev/null
        sleep 2
        echo -e "  ${GRN}[✓] WiFi restauré.${NC}"
    }
    trap '_crack_cleanup' EXIT INT TERM

    # [1/4] Tuer les processus qui bloquent le mode monitor
    echo -e "  ${YLW}[1/4] Arrêt des processus interférents...${NC}"
    airmon-ng check kill 2>&1 | grep -E "Killing|process" | while IFS= read -r l; do echo "  ${GRY}$l${NC}"; done

    # [2/4] Mode monitor — récupère le vrai nom de l'interface créée
    echo -e "\n  ${YLW}[2/4] Activation mode monitor sur ${iface}...${NC}"
    local airmon_out
    airmon_out=$(airmon-ng start "$iface" 2>&1)
    echo "$airmon_out" | grep -E "monitor mode|enabled|phy" | while IFS= read -r l; do echo "  ${GRY}$l${NC}"; done

    # Détection robuste du nom de l'interface monitor
    mon=$(echo "$airmon_out" | grep -oE '\[phy[0-9]+\][a-z0-9]+mon' | awk -F']' '{print $2}' | head -1)
    [ -z "$mon" ] && mon="${iface}mon"
    [ -z "$(iw dev 2>/dev/null | grep "$mon")" ] && mon=$(iw dev 2>/dev/null | awk '/Interface/{print $2}' | grep mon | head -1)

    if [ -z "$mon" ]; then
        echo -e "  ${RED}[✗] Interface monitor introuvable.${NC}"
        _pause; return
    fi
    echo -e "  ${GRN}[✓] Interface monitor : ${WHT}${mon}${NC}\n"

    # [3/4] Capture handshake
    echo -e "  ${YLW}[3/4] Capture handshake (60s max)...${NC}"
    echo -e "  ${GRY}  → Sur un autre PC du réseau : aireplay-ng --deauth 5 -a ${bssid} ${mon}${NC}\n"
    timeout 60 airodump-ng -c "$channel" --bssid "$bssid" -w "$cap" "$mon" 2>/dev/null

    local capfile
    capfile=$(ls ${cap}*.cap 2>/dev/null | head -1)
    if [ -z "$capfile" ]; then
        echo -e "  ${RED}[✗] Aucun handshake capturé (timeout ou pas de client).${NC}"
        _pause; return
    fi
    echo -e "\n  ${GRN}[✓] Handshake capturé : $(basename "$capfile")${NC}\n"

    # [4/4] Crack
    echo -e "  ${YLW}[4/4] Chemin wordlist :${NC}"
    echo -e "  ${GRY}  (ex: /usr/share/wordlists/rockyou.txt)${NC}"
    echo -n "  > "; read -r wordlist

    if [ -f "$wordlist" ]; then
        echo -e "\n  ${YLW}[~] Crack en cours...${NC}\n"
        aircrack-ng -w "$wordlist" "$capfile"
    else
        echo -e "  ${RED}[✗] Wordlist introuvable.${NC}"
    fi

    # Le trap EXIT appellera _crack_cleanup automatiquement
    trap - EXIT INT TERM
    _crack_cleanup
    _pause
}

# ----------------------------------------------------------------
#  OUTILS STANDALONE (DNS, info, ports)
# ----------------------------------------------------------------
dns_display() {
    clear
    _draw_header "DNS ACTUELS"
    echo -e "  ${YLW}[ systemd-resolved ]${NC}\n"
    if command -v resolvectl &>/dev/null; then
        resolvectl status 2>/dev/null | grep -E "DNS|Link|Interface" | while IFS= read -r l; do echo "  $l"; done
    fi
    echo -e "\n  ${YLW}[ /etc/resolv.conf ]${NC}\n"
    grep -v "^#" /etc/resolv.conf 2>/dev/null | while IFS= read -r l; do [ -n "$l" ] && echo "  $l"; done
    echo -e "\n  ${YLW}[ Test resolution ]${NC}"
    echo -n "  google.com → "
    host -W 2 google.com 2>/dev/null | head -1 || echo "pas de reponse"
    _pause
}

dns_manager() {
    clear
    _draw_header "GESTIONNAIRE DNS"
    echo -e "  ${YLW}[ DNS actuel ]${NC}\n"
    grep "^nameserver" /etc/resolv.conf 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo ""
    MENU_OPTS=(
        "Cloudflare   — 1.1.1.1 / 1.0.0.1          (rapide, prive)"
        "Google       — 8.8.8.8 / 8.8.4.4           (fiable)"
        "Quad9        — 9.9.9.9 / 149.112.112.112   (securise)"
        "AdGuard      — 94.140.14.14 / 94.140.15.15 (bloque pub)"
        "OpenDNS      — 208.67.222.222 / 208.67.220.220"
        "Personnalise — Saisir manuellement"
        "--- Annuler"
    )
    AutoMenu "CHOISIR DNS" || return

    local dns1 dns2
    case $MENU_CHOICE in
        0) dns1="1.1.1.1";         dns2="1.0.0.1" ;;
        1) dns1="8.8.8.8";         dns2="8.8.4.4" ;;
        2) dns1="9.9.9.9";         dns2="149.112.112.112" ;;
        3) dns1="94.140.14.14";    dns2="94.140.15.15" ;;
        4) dns1="208.67.222.222";  dns2="208.67.220.220" ;;
        5)
            echo -e "\n  ${YLW}DNS primaire :${NC} "; read -r dns1
            echo -e "  ${YLW}DNS secondaire (vide si aucun) :${NC} "; read -r dns2
            ;;
        *) return ;;
    esac

    echo -e "\n  ${YLW}[~] Application : ${dns1}${dns2:+ / $dns2}${NC}\n"
    if systemctl is-active systemd-resolved &>/dev/null; then
        mkdir -p /etc/systemd/resolved.conf.d
        {
            echo "[Resolve]"
            echo "DNS=${dns1}${dns2:+ $dns2}"
            echo "FallbackDNS="
        } > /etc/systemd/resolved.conf.d/aleex-dns.conf
        systemctl restart systemd-resolved
    else
        {
            echo "nameserver $dns1"
            [ -n "$dns2" ] && echo "nameserver $dns2"
        } > /etc/resolv.conf
    fi
    echo -e "  ${GRN}[✓] DNS applique avec succes.${NC}"
    _pause
}

net_ip_info() {
    clear
    _draw_header "INFORMATIONS IP"
    local gw iface pub
    iface=$(ip route | awk '/default/{print $5; exit}')
    gw=$(ip route | awk '/default/{print $3; exit}')

    echo -e "  ${YLW}[ Interfaces reseau (IPv4) ]${NC}\n"
    ip -4 addr show | grep -E "^[0-9]|inet " | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[ Passerelle par defaut ]${NC}"
    echo -e "  Interface : ${WHT}${iface}${NC}  |  Gateway : ${WHT}${gw}${NC}"

    echo -e "\n  ${YLW}[ IP Publique ]${NC}"
    echo -n "  "
    pub=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null || curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    [ -n "$pub" ] && echo -e "${WHT}${pub}${NC}" || echo -e "${RED}Non disponible${NC}"

    echo -e "\n  ${YLW}[ Table de routage ]${NC}\n"
    ip route | while IFS= read -r l; do echo "  $l"; done
    _pause
}

net_ports() {
    clear
    _draw_header "PORTS OUVERTS & CONNEXIONS"
    echo -e "  ${YLW}[ Ports en ecoute (ss -tulpn) ]${NC}\n"
    ss -tulpn 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ Connexions etablies ]${NC}\n"
    ss -tnp state established 2>/dev/null | head -30 | while IFS= read -r l; do echo "  $l"; done
    _pause
}

net_arp() {
    clear
    _draw_header "TABLE ARP — APPAREILS LAN"
    echo -e "  ${YLW}[ Voisins connus (ip neigh) ]${NC}\n"
    ip neigh show 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ arp -n ]${NC}\n"
    arp -n 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    _pause
}

cyber_lan() {
    clear
    _draw_header "SCAN LAN — HOTES ACTIFS"
    _require nmap nmap || return
    local iface subnet
    iface=$(ip route | awk '/default/{print $5; exit}')
    subnet=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{print $2; exit}')
    [ -z "$subnet" ] && { echo -e "  ${RED}[✗] Sous-reseau non detecte.${NC}"; _pause; return; }
    echo -e "  ${GRY}Sous-reseau : ${WHT}${subnet}${NC}\n"
    echo -e "  ${YLW}[~] nmap -sn (ping scan)...${NC}\n"
    nmap -sn "$subnet" 2>/dev/null | grep -E "Nmap scan|Host is|report for|MAC Address" \
        | while IFS= read -r l; do echo "  $l"; done
    _pause
}

cyber_ports() {
    clear
    _draw_header "SCAN DE PORTS — HOTE CIBLE"
    _require nmap nmap || return
    echo -e "  ${YLW}IP ou hostname cible :${NC} "
    read -r target
    [ -z "$target" ] && return

    MENU_OPTS=(
        "Scan rapide      — Top 1000 ports (SYN -T4)"
        "Scan complet     — Tous les ports 1-65535"
        "Scan services    — Detection version (-sV)"
        "Scan OS          — Detection OS + services (-A)"
        "Ports communs    — 22,80,443,445,3306,3389..."
        "--- Annuler"
    )
    AutoMenu "TYPE DE SCAN" || return

    local opts
    case $MENU_CHOICE in
        0) opts="-sS -T4" ;;
        1) opts="-sS -T4 -p-" ;;
        2) opts="-sS -T4 -sV" ;;
        3) opts="-A -T4" ;;
        4) opts="-sS -T4 -p 21,22,23,25,53,80,110,143,443,445,3306,3389,5432,5900,8080,8443" ;;
        *) return ;;
    esac
    clear
    _draw_header "SCAN : ${target}"
    echo -e "  ${YLW}[~] nmap ${opts} ${target}${NC}\n"
    nmap $opts "$target" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    _pause
}

cyber_dns_leak() {
    clear
    _draw_header "DNS LEAK TEST"
    _require curl curl || return
    echo -e "  ${YLW}[ DNS resolv.conf ]${NC}"
    grep "^nameserver" /etc/resolv.conf 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ DNS systemd-resolved ]${NC}"
    if command -v resolvectl &>/dev/null; then
        resolvectl status 2>/dev/null | grep "DNS Servers" | head -5 | while IFS= read -r l; do echo "  $l"; done
    fi
    echo -e "\n  ${YLW}[ Resolution externe ]${NC}"
    for domain in one.one.one.one dns.google; do
        echo -n "  $domain → "
        host -W 2 "$domain" 2>/dev/null | head -1 || echo "pas de reponse"
    done
    echo -e "\n  ${YLW}[ IP Publique ]${NC}"
    echo -n "  "
    curl -s --max-time 5 https://ifconfig.me 2>/dev/null || echo "non disponible"
    echo ""
    echo -e "\n  ${GRY}Si l IP publique ne correspond pas a ton VPN → fuite detectee.${NC}"
    _pause
}

net_wifi_scan() {
    clear
    _draw_header "SCAN WIFI — RESEAUX DISPONIBLES"
    echo -e "  ${YLW}[~] Scan en cours...${NC}\n"
    if command -v nmcli &>/dev/null; then
        nmcli -f SSID,BSSID,CHAN,SIGNAL,SECURITY dev wifi list 2>/dev/null \
            | while IFS= read -r l; do echo "  $l"; done
    elif command -v iwlist &>/dev/null; then
        local iface
        iface=$(iw dev 2>/dev/null | awk '/Interface/{print $2; exit}')
        iwlist "$iface" scan 2>/dev/null | grep -E "Cell|ESSID|Quality|Encryption|Channel" \
            | while IFS= read -r l; do echo "  $l"; done
    else
        _require nmcli network-manager
    fi
    _pause
}

net_wifi_target() {
    clear
    _draw_header "ANALYSER UN RESEAU WIFI CIBLE"
    echo -e "  ${YLW}SSID cible :${NC} "
    read -r ssid
    [ -z "$ssid" ] && return
    echo -e "\n  ${YLW}[ Details : ${ssid} ]${NC}\n"
    if command -v nmcli &>/dev/null; then
        nmcli -f all dev wifi list 2>/dev/null | grep -i "$ssid" \
            | while IFS= read -r l; do echo "  $l"; done
    fi
    echo -e "\n  ${YLW}[ Profil enregistre (NM) ]${NC}\n"
    for f in /etc/NetworkManager/system-connections/*; do
        grep -q "ssid=$ssid" "$f" 2>/dev/null && cat "$f" | while IFS= read -r l; do echo "  $l"; done
    done
    _pause
}

net_wifi_crack() {
    clear
    _draw_header "WPA2 HANDSHAKE — AIRCRACK-NG"
    echo -e "  ${RED}╔══════════════════════════════════════════════╗${NC}"
    echo -e "  ${RED}║  USAGE LEGAL UNIQUEMENT                      ║${NC}"
    echo -e "  ${RED}║  Ton propre reseau ou autorisation ecrite.   ║${NC}"
    echo -e "  ${RED}╚══════════════════════════════════════════════╝${NC}\n"

    _require aircrack-ng aircrack-ng || return
    _require airmon-ng aircrack-ng   || return
    _require airodump-ng aircrack-ng || return

    local ifaces=()
    while IFS= read -r l; do ifaces+=("$l"); done < <(iw dev 2>/dev/null | awk '/Interface/{print $2}')
    if [ ${#ifaces[@]} -eq 0 ]; then
        echo -e "  ${RED}[✗] Aucune interface WiFi detectee.${NC}"; _pause; return
    fi

    MENU_OPTS=("${ifaces[@]}" "--- Annuler")
    AutoMenu "INTERFACE WIFI" || return
    [ $MENU_CHOICE -ge ${#ifaces[@]} ] && return
    local iface="${ifaces[$MENU_CHOICE]}"

    echo -e "\n  ${YLW}[1/4] Mode monitor sur ${iface}...${NC}"
    airmon-ng start "$iface" 2>&1 | tail -3
    local mon="${iface}mon"

    echo -e "\n  ${YLW}[2/4] Scan des AP — Ctrl+C quand la cible est visible${NC}\n"
    airodump-ng "$mon" 2>/dev/null

    echo -e "\n  ${YLW}BSSID cible (ex: AA:BB:CC:DD:EE:FF) :${NC} "; read -r bssid
    echo -e "  ${YLW}Canal (CHANNEL) :${NC} "; read -r channel
    if [ -z "$bssid" ] || [ -z "$channel" ]; then
        airmon-ng stop "$mon" 2>/dev/null; return
    fi

    local cap="/tmp/aleex_cap_$$"
    echo -e "\n  ${YLW}[3/4] Capture handshake (60s max)...${NC}"
    echo -e "  ${GRY}    Autre terminal : aireplay-ng --deauth 5 -a ${bssid} ${mon}${NC}\n"
    timeout 60 airodump-ng -c "$channel" --bssid "$bssid" -w "$cap" "$mon" 2>/dev/null

    local capfile
    capfile=$(ls ${cap}*.cap 2>/dev/null | head -1)
    if [ -z "$capfile" ]; then
        echo -e "  ${RED}[✗] Aucun fichier de capture.${NC}"
        airmon-ng stop "$mon" 2>/dev/null; _pause; return
    fi

    echo -e "\n  ${YLW}[4/4] Chemin wordlist (ex: /usr/share/wordlists/rockyou.txt) :${NC} "
    read -r wordlist
    if [ -f "$wordlist" ]; then
        aircrack-ng -w "$wordlist" "$capfile"
    else
        echo -e "  ${RED}[✗] Wordlist introuvable.${NC}"
    fi

    airmon-ng stop "$mon" 2>/dev/null
    rm -f "${cap}"* 2>/dev/null
    _pause
}

net_discover() {
    clear
    _draw_header "DECOUVERTE LAN — IP / NOM / MAC"
    _require nmap nmap || return
    local iface subnet
    iface=$(ip route | awk '/default/{print $5; exit}')
    subnet=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{print $2; exit}')
    [ -z "$subnet" ] && { echo -e "  ${RED}[✗] Sous-reseau non detecte.${NC}"; _pause; return; }
    echo -e "  ${GRY}Sous-reseau : ${WHT}${subnet}${NC}\n"
    echo -e "  ${YLW}[~] Scan avec resolution nom et MAC...${NC}\n"
    nmap -sn "$subnet" 2>/dev/null | grep -E "report for|Host is|MAC Address|Nmap scan" \
        | while IFS= read -r l; do echo "  $l"; done
    _pause
}

net_enum() {
    clear
    _draw_header "ENUMERATION SERVICES RESEAU"
    _require nmap nmap || return
    echo -e "  ${YLW}Cible (IP ou plage, ex: 192.168.1.0/24) :${NC} "
    read -r target
    [ -z "$target" ] && return
    echo -e "\n  ${YLW}[~] SSH, Telnet, RDP, FTP, VNC, SMB, DB...${NC}\n"
    nmap -sS -T4 -sV -p 21,22,23,25,53,80,110,135,139,143,443,445,587,993,995,1433,3306,3389,5432,5900,5985,8080 \
        "$target" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    _pause
}

net_web_hunt() {
    clear
    _draw_header "WEB INTERFACE HUNT"
    _require nmap nmap || return
    local iface subnet
    iface=$(ip route | awk '/default/{print $5; exit}')
    subnet=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{print $2; exit}')
    echo -e "  ${YLW}Cible (vide = sous-reseau local ${subnet}) :${NC} "
    read -r target
    target="${target:-$subnet}"
    echo -e "\n  ${YLW}[~] Ports 80, 443, 8080, 8443 — hotes ouverts...${NC}\n"
    nmap -sS -T4 -p 80,443,8080,8443 --open "$target" 2>&1 \
        | grep -E "report for|open|Nmap scan" \
        | while IFS= read -r l; do echo "  $l"; done
    _pause
}

net_vuln() {
    clear
    _draw_header "VERIFICATION VULNERABILITES"
    _require nmap nmap || return
    echo -e "  ${YLW}Cible (IP ou plage) :${NC} "
    read -r target
    [ -z "$target" ] && return

    echo -e "\n  ${YLW}[1/3] Partages SMB...${NC}\n"
    nmap -sS -T4 -p 139,445 --script smb-enum-shares,smb-security-mode "$target" 2>&1 \
        | grep -Ev "^Starting|^Warning" | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[2/3] FTP anonyme...${NC}\n"
    nmap -sS -T4 -p 21 --script ftp-anon "$target" 2>&1 \
        | grep -Ev "^Starting|^Warning" | while IFS= read -r l; do echo "  $l"; done

    echo -e "\n  ${YLW}[3/3] SSH version + auth...${NC}\n"
    nmap -sS -T4 -p 22 --script ssh-auth-methods,ssh2-enum-algos "$target" 2>&1 \
        | grep -Ev "^Starting|^Warning" | while IFS= read -r l; do echo "  $l"; done
    _pause
}

menu_net_cyber() {
    while true; do
        MENU_OPTS=(
            "Scan & Pentest LAN       — Workflow guidé : réseau → cible → ports → enum"
            "Wifi — Scan & Crack      — Workflow guidé : scan → sélection → crack WPA2"
            "--- ─────────────────────── OUTILS ─────────────────────────"
            "Info IP                  — IP locale, publique, gateway"
            "Ports Ouverts            — ss -tulpn connexions actives"
            "Table ARP                — Appareils détectés sur LAN"
            "Gestionnaire DNS         — Changer DNS (Cloudflare, Google...)"
            "Afficher DNS             — DNS actuels et résolveurs"
            "DNS Leak Test            — Vérifier fuite VPN/DNS"
            "--- Retour au menu principal"
        )
        AutoMenu "RESEAU & CYBER" || return
        case $MENU_CHOICE in
            0)  net_workflow_lan ;;
            1)  net_workflow_wifi ;;
            3)  net_ip_info ;;
            4)  net_ports ;;
            5)  net_arp ;;
            6)  dns_manager ;;
            7)  dns_display ;;
            8)  cyber_dns_leak ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 8 : EXTRACTION & SAUVEGARDE
# ================================================================

sys_hw_export() {
    clear
    _draw_header "INVENTAIRE MATERIEL — lshw"
    _require lshw lshw || return
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local out="/home/$user/Desktop/hardware_$(date +%Y%m%d_%H%M%S).txt"
    echo -e "  ${YLW}[~] Inventaire complet...${NC}\n"
    lshw -short 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    lshw -short 2>/dev/null > "$out"
    chown "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Rapport sauvegarde : ${out}${NC}"
    _pause
}

sys_drivers() {
    clear
    _draw_header "MODULES KERNEL CHARGES"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local out="/home/$user/Desktop/modules_$(date +%Y%m%d_%H%M%S).txt"
    echo -e "  ${YLW}[ lsmod — Modules actifs ]${NC}\n"
    lsmod 2>/dev/null | while IFS= read -r l; do echo "  $l"; done
    lsmod 2>/dev/null > "$out"
    chown "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Liste sauvegardee : ${out}${NC}"
    _pause
}

sys_export_software() {
    clear
    _draw_header "EXPORTER LISTE APPLICATIONS"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local out="/home/$user/Desktop/pkg_list_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "=== APT — Paquets installes manuellement ==="
        apt-mark showmanual 2>/dev/null | sort
        echo ""
        if command -v snap &>/dev/null; then
            echo "=== SNAP ==="
            snap list 2>/dev/null
            echo ""
        fi
        if command -v flatpak &>/dev/null; then
            echo "=== FLATPAK ==="
            flatpak list --app 2>/dev/null
            echo ""
        fi
        if command -v pip3 &>/dev/null; then
            echo "=== PIP3 ==="
            pip3 list 2>/dev/null
        fi
    } | tee "$out" | while IFS= read -r l; do echo "  $l"; done

    chown "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Liste exportee : ${out}${NC}"
    _pause
}

dump_wifi() {
    clear
    _draw_header "EXPORT PROFILS WIFI"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local out="/home/$user/Desktop/wifi_export_$(date +%Y%m%d_%H%M%S).txt"
    local nm_dir="/etc/NetworkManager/system-connections"

    echo -e "  ${YLW}[ Profils NetworkManager ]${NC}\n"
    if [ -d "$nm_dir" ]; then
        local found=0
        for f in "$nm_dir"/*; do
            [ -f "$f" ] || continue
            local ssid psk security
            ssid=$(grep "^ssid=" "$f" 2>/dev/null | cut -d= -f2-)
            psk=$(grep "^psk=" "$f" 2>/dev/null | cut -d= -f2-)
            security=$(grep "^key-mgmt=" "$f" 2>/dev/null | cut -d= -f2-)
            [ -z "$ssid" ] && continue
            printf "  ${WHT}%-35s${NC} ${GRN}%s${NC} ${GRY}(%s)${NC}\n" \
                "$ssid" "${psk:-<aucun>}" "${security:-open}"
            ((found++))
        done
        [ $found -eq 0 ] && echo -e "  ${GRY}Aucun profil trouve.${NC}"
    else
        echo -e "  ${GRY}NetworkManager non configure.${NC}"
    fi

    if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
        echo -e "\n  ${YLW}[ wpa_supplicant.conf ]${NC}\n"
        grep -E "ssid=|psk=" /etc/wpa_supplicant/wpa_supplicant.conf \
            | while IFS= read -r l; do echo "  $l"; done
    fi

    {
        echo "=== WiFi Export — $(date) ==="
        for f in "$nm_dir"/*; do
            [ -f "$f" ] || continue
            ssid=$(grep "^ssid=" "$f" 2>/dev/null | cut -d= -f2-)
            psk=$(grep "^psk=" "$f" 2>/dev/null | cut -d= -f2-)
            [ -n "$ssid" ] && echo "SSID: $ssid | PSK: ${psk:-<aucun>}"
        done
    } > "$out" 2>/dev/null
    chown "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Export sauvegarde : ${out}${NC}"
    _pause
}

sys_loot_all() {
    clear
    _draw_header "EXTRACTION COMPLETE — LOOT"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local out="/home/$user/Desktop/loot_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$out"

    echo -e "  ${YLW}[1/5] WiFi passwords...${NC}"
    {
        echo "=== WiFi Export ==="
        for f in /etc/NetworkManager/system-connections/*; do
            [ -f "$f" ] || continue
            ssid=$(grep "^ssid=" "$f" 2>/dev/null | cut -d= -f2-)
            psk=$(grep "^psk=" "$f" 2>/dev/null | cut -d= -f2-)
            [ -n "$ssid" ] && echo "SSID: $ssid | PSK: ${psk:-<aucun>}"
        done
    } > "$out/wifi.txt" 2>/dev/null
    echo -e "  ${GRN}    [✓] wifi.txt${NC}"

    echo -e "  ${YLW}[2/5] Comptes systeme...${NC}"
    cp /etc/passwd "$out/passwd.txt" 2>/dev/null
    cp /etc/shadow "$out/shadow.txt" 2>/dev/null
    echo -e "  ${GRN}    [✓] passwd.txt + shadow.txt${NC}"

    echo -e "  ${YLW}[3/5] Historiques shell...${NC}"
    for home_dir in /home/* /root; do
        local uname
        uname=$(basename "$home_dir")
        [ -f "$home_dir/.bash_history" ] && cp "$home_dir/.bash_history" "$out/history_${uname}_bash.txt" 2>/dev/null
        [ -f "$home_dir/.zsh_history"  ] && cp "$home_dir/.zsh_history"  "$out/history_${uname}_zsh.txt"  2>/dev/null
    done
    echo -e "  ${GRN}    [✓] historiques${NC}"

    echo -e "  ${YLW}[4/5] Cles SSH...${NC}"
    find /home /root -maxdepth 3 \( -name "id_rsa" -o -name "id_ed25519" -o -name "id_ecdsa" \) 2>/dev/null \
        | while read -r k; do
            cp "$k" "$out/ssh_$(echo "$k" | tr '/' '_').key" 2>/dev/null
        done
    echo -e "  ${GRN}    [✓] cles SSH${NC}"

    echo -e "  ${YLW}[5/5] Info systeme...${NC}"
    {
        echo "=== UNAME ===" && uname -a
        echo "=== HOSTNAME ===" && hostname
        echo "=== NETWORK ===" && ip addr
        echo "=== USERS ===" && cat /etc/passwd | grep -v nologin | grep -v false
        echo "=== SUDO ===" && cat /etc/sudoers 2>/dev/null
    } > "$out/sysinfo.txt" 2>/dev/null
    echo -e "  ${GRN}    [✓] sysinfo.txt${NC}"

    chown -R "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Loot complet : ${out}/${NC}"
    _pause
}

sys_export_dotfiles() {
    clear
    _draw_header "SAUVEGARDE DOTFILES & CONFIG"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local home="/home/$user"
    local archive="/home/$user/Desktop/dotfiles_$(date +%Y%m%d_%H%M%S).tar.gz"

    echo -e "  ${YLW}[~] Fichiers trouves :${NC}\n"
    local items=()
    for f in .bashrc .zshrc .profile .bash_aliases .gitconfig .vimrc .tmux.conf .config/starship.toml; do
        [ -e "$home/$f" ] && items+=("$home/$f") && echo -e "  ${GRN}[✓]${NC} $f"
    done
    for d in .ssh .config/nvim .config/alacritty .config/kitty .config/scripts-aleex; do
        [ -d "$home/$d" ] && items+=("$home/$d") && echo -e "  ${GRN}[✓]${NC} $d/"
    done

    if [ ${#items[@]} -eq 0 ]; then
        echo -e "  ${GRY}Aucun fichier de config trouve.${NC}"; _pause; return
    fi

    tar czf "$archive" "${items[@]}" 2>/dev/null
    chown "$user:$user" "$archive" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Archive : ${archive}${NC}"
    echo -e "  ${GRY}    ${#items[@]} element(s) sauvegardes.${NC}"
    _pause
}

sys_win_key() {
    clear
    _draw_header "CLE DE LICENCE SYSTEME"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    echo -e "  ${YLW}[ Machine ID Linux ]${NC}\n"
    cat /etc/machine-id 2>/dev/null | while IFS= read -r l; do echo -e "  ${WHT}$l${NC}"; done
    echo -e "\n  ${YLW}[ Cle OEM Windows (ACPI MSDM — si dual-boot) ]${NC}\n"
    if [ -f /sys/firmware/acpi/tables/MSDM ]; then
        strings /sys/firmware/acpi/tables/MSDM 2>/dev/null | grep -E "^[A-Z0-9]{5}-" \
            | while IFS= read -r l; do echo -e "  ${GRN}${WHT}$l${NC}"; done \
            || cat /sys/firmware/acpi/tables/MSDM 2>/dev/null | tr -dc '[:print:]' \
            | grep -oE "[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}" \
            | while IFS= read -r l; do echo -e "  ${GRN}${WHT}$l${NC}"; done
    else
        echo -e "  ${GRY}  Aucune cle ACPI MSDM (pas de licence OEM Windows).${NC}"
    fi
    echo -e "\n  ${YLW}[ Partitions Windows detectees ]${NC}\n"
    blkid 2>/dev/null | grep -iE "ntfs" | while IFS= read -r l; do echo -e "  ${GRY}$l${NC}"; done \
        || echo -e "  ${GRY}  Aucune partition NTFS.${NC}"
    local out="/home/$user/Desktop/license_$(date +%Y%m%d_%H%M%S).txt"
    { echo "Machine-ID: $(cat /etc/machine-id 2>/dev/null)"
      strings /sys/firmware/acpi/tables/MSDM 2>/dev/null | grep -E "^[A-Z0-9]{5}-" \
          | head -1 | xargs -I{} echo "MSDM-Key: {}"
    } > "$out" 2>/dev/null
    chown "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Rapport sauvegarde : ${out}${NC}"
    _pause
}

sys_export_wifi_apps() {
    clear
    _draw_header "EXPORT WIFI ET APPLICATIONS"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local out="/home/$user/Desktop/wifi_apps_$(date +%Y%m%d_%H%M%S).txt"
    echo -e "  ${YLW}[1/2] Export profils WiFi...${NC}\n"
    {
        echo "=== WiFi Export — $(date) ==="
        for f in /etc/NetworkManager/system-connections/*; do
            [ -f "$f" ] || continue
            local ssid psk
            ssid=$(grep "^ssid=" "$f" 2>/dev/null | cut -d= -f2-)
            psk=$(grep "^psk=" "$f" 2>/dev/null | cut -d= -f2-)
            [ -n "$ssid" ] && echo "SSID: $ssid | PSK: ${psk:-<aucun>}"
        done
        echo ""
        echo "=== Applications installees — $(date) ==="
        echo "-- APT --"; apt-mark showmanual 2>/dev/null | sort; echo ""
        command -v snap &>/dev/null && { echo "-- SNAP --"; snap list 2>/dev/null; echo ""; }
        command -v flatpak &>/dev/null && { echo "-- FLATPAK --"; flatpak list --app 2>/dev/null; }
    } | tee "$out" | while IFS= read -r l; do echo "  $l"; done
    chown "$user:$user" "$out" 2>/dev/null
    echo -e "\n  ${GRN}[✓] Export sauvegarde : ${out}${NC}"
    _pause
}

scan_web_routes() {
    clear
    _draw_header "AUDIT ROUTES WEB — FICHIERS SENSIBLES EXPOSES"
    echo -e "  ${YLW}URL cible (ex: http://192.168.1.1) :${NC} "
    read -r target_url
    [ -z "$target_url" ] && return
    _require curl curl || return
    echo -e "\n  ${YLW}[~] Verification des routes sensibles sur ${target_url}...${NC}\n"
    local routes=(
        "/.env" "/.env.local" "/.env.production" "/wp-config.php"
        "/config.php" "/config.yml" "/config.json" "/settings.py"
        "/admin" "/admin.php" "/administrator" "/phpmyadmin"
        "/api" "/api/v1" "/api/v2" "/.git/config"
        "/backup" "/backup.zip" "/backup.sql" "/db.sql"
        "/.htaccess" "/robots.txt" "/sitemap.xml" "/server-status"
    )
    local found=0
    for route in "${routes[@]}"; do
        local url="${target_url%/}${route}"
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
        case "$code" in
            200)      echo -e "  ${RED}[!] EXPOSE  ${code}  ${url}${NC}"; ((found++)) ;;
            301|302|403) echo -e "  ${YLW}[~] ${code}       ${url}${NC}" ;;
            *)        echo -e "  ${GRY}    ${code}       ${url}${NC}" ;;
        esac
    done
    echo -e "\n  ${found} route(s) exposee(s) detectee(s)."
    _pause
}

menu_extraction() {
    while true; do
        MENU_OPTS=(
            "Info Materiel          — lshw inventaire complet"
            "Modules Kernel         — Pilotes et modules charges"
            "Exporter Apps          — APT + Snap + Flatpak + pip"
            "Exporter WiFi          — Passwords des profils WiFi"
            "Export WiFi et Apps    — Profils reseau et logiciels"
            "Extraction Loot        — WiFi + comptes + SSH + historiques"
            "Cle de Licence         — Machine ID et cle ACPI MSDM"
            "Passwords Navigateur   — Firefox / Chrome profils"
            "Historique Navigateur  — Firefox / Chrome / Chromium"
            "Fichiers Sensibles     — .key .pem .env credentials..."
            "Audit Routes Web       — .env, wp-config, /admin exposes"
            "Backup Dotfiles        — .bashrc, .ssh, .gitconfig..."
            "--- Retour au menu principal"
        )
        AutoMenu "EXTRACTION & SAUVEGARDE" || return
        case $MENU_CHOICE in
            0)  sys_hw_export ;;
            1)  sys_drivers ;;
            2)  sys_export_software ;;
            3)  dump_wifi ;;
            4)  sys_export_wifi_apps ;;
            5)  sys_loot_all ;;
            6)  sys_win_key ;;
            7)  dump_browser ;;
            8)  gather_browser_history ;;
            9)  search_sensitive_docs ;;
            10) scan_web_routes ;;
            11) sys_export_dotfiles ;;
            12) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  CATEGORIE 7 : COMPTES & SECURITE
# ================================================================

dump_browser() {
    clear
    _draw_header "MOTS DE PASSE NAVIGATEUR"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local home="/home/$user"

    echo -e "  ${YLW}[ Firefox — Logins sauvegardés ]${NC}\n"
    local found_ff=0
    for profile in "$home/.mozilla/firefox"/*.default* "$home/.mozilla/firefox"/*.default-release; do
        [ -d "$profile" ] || continue
        found_ff=1
        local login_count="0"
        if [ -f "$profile/logins.json" ] && command -v python3 &>/dev/null; then
            login_count=$(python3 -c "
import json
try:
    d=json.load(open('$profile/logins.json'))
    logins=d.get('logins',[])
    print(len(logins))
    for l in logins[:30]:
        print('    •',l.get('hostname','?'))
except: print('?')
" 2>/dev/null)
            echo -e "  ${GRN}Profil :${NC} $(basename "$profile")  ${GRY}(${login_count%%$'\n'*} logins)${NC}"
            echo "$login_count" | tail -n +2 | while IFS= read -r l; do echo -e "  ${GRY}$l${NC}"; done
        else
            echo -e "  ${GRN}Profil :${NC} $(basename "$profile")  ${GRY}(python3 requis pour lire logins.json)${NC}"
        fi
    done
    [ $found_ff -eq 0 ] && echo -e "  ${GRY}Aucun profil Firefox trouvé.${NC}"

    echo -e "\n  ${YLW}[ Chrome / Chromium / Brave ]${NC}\n"
    for chrome_dir in "$home/.config/google-chrome" "$home/.config/chromium" "$home/.config/brave-browser"; do
        [ -d "$chrome_dir" ] || continue
        local login_db="$chrome_dir/Default/Login Data"
        echo -e "  ${GRN}$(basename "$chrome_dir") :${NC}"
        if [ -f "$login_db" ] && command -v sqlite3 &>/dev/null; then
            local tmp_db="/tmp/aleex_chrome_$$.sqlite"
            cp "$login_db" "$tmp_db" 2>/dev/null
            sqlite3 "$tmp_db" "SELECT action_url FROM logins LIMIT 30;" 2>/dev/null \
                | while IFS= read -r l; do echo -e "  ${GRY}    • $l${NC}"; done
            rm -f "$tmp_db"
        else
            echo -e "  ${GRY}    (sqlite3 requis)${NC}"
        fi
    done

    echo -e "\n  ${GRY}Les mots de passe sont chiffrés. Pour déchiffrer Firefox : pip install firefox-decrypt${NC}"
    _pause
}

gather_browser_history() {
    clear
    _draw_header "HISTORIQUE NAVIGATEUR"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local home="/home/$user"

    _require sqlite3 sqlite3 || return

    echo -e "  ${YLW}[ Firefox — 50 dernières visites ]${NC}\n"
    local found=0
    for profile in "$home/.mozilla/firefox"/*.default* "$home/.mozilla/firefox"/*.default-release; do
        [ -f "$profile/places.sqlite" ] || continue
        found=1
        local tmp="/tmp/aleex_places_$$.sqlite"
        cp "$profile/places.sqlite" "$tmp" 2>/dev/null
        sqlite3 "$tmp" \
            "SELECT datetime(last_visit_date/1000000,'unixepoch','localtime'), url
             FROM moz_places WHERE last_visit_date IS NOT NULL
             ORDER BY last_visit_date DESC LIMIT 50;" 2>/dev/null \
            | while IFS= read -r l; do echo "  $l"; done
        rm -f "$tmp"
    done
    [ $found -eq 0 ] && echo -e "  ${GRY}Aucun profil Firefox trouvé.${NC}"

    echo -e "\n  ${YLW}[ Chrome / Chromium / Brave — 50 dernières visites ]${NC}\n"
    for chrome_dir in "$home/.config/google-chrome" "$home/.config/chromium" "$home/.config/brave-browser"; do
        local hist="$chrome_dir/Default/History"
        [ -f "$hist" ] || continue
        echo -e "  ${GRN}$(basename "$chrome_dir") :${NC}"
        local tmp="/tmp/aleex_hist_$$.sqlite"
        cp "$hist" "$tmp" 2>/dev/null
        sqlite3 "$tmp" \
            "SELECT datetime(last_visit_time/1000000-11644473600,'unixepoch','localtime'), url
             FROM urls ORDER BY last_visit_time DESC LIMIT 50;" 2>/dev/null \
            | while IFS= read -r l; do echo "  $l"; done
        rm -f "$tmp"
    done
    _pause
}

search_sensitive_docs() {
    clear
    _draw_header "FICHIERS SENSIBLES"
    echo -e "  ${YLW}[~] Recherche en cours...${NC}\n"

    local -a patterns=("*.key" "*.pem" "*.pfx" "*.p12" "*.ppk"
        "*password*" "*passwd*" "*credentials*" "*secret*"
        ".env" "*.env" "*.kdbx" "*.kdb" "*id_rsa*" "*id_ed25519*")

    for pat in "${patterns[@]}"; do
        local results
        results=$(find /home /root /tmp /var/www /srv 2>/dev/null \
            -name "$pat" -not -path "*/proc/*" -not -path "*/.git/*" 2>/dev/null)
        if [ -n "$results" ]; then
            echo -e "  ${RED}[!] ${pat}${NC}"
            echo "$results" | while IFS= read -r f; do
                local sz
                sz=$(stat -c "%s" "$f" 2>/dev/null)
                echo -e "  ${GRY}    ${WHT}${f}${GRY}  (${sz} bytes)${NC}"
            done
        fi
    done
    _pause
}

um_list() {
    clear
    _draw_header "LISTE DES UTILISATEURS"
    printf "  ${YLW}%-20s  %-6s  %-22s  %s${NC}\n" "NOM" "UID" "SHELL" "SUDO"
    echo -e "  ${GRY}$(printf '─%.0s' {1..62})${NC}"
    while IFS=: read -r name _ uid _ _ _ shell; do
        [[ "$uid" -lt 1000 || "$uid" -ge 65534 ]] && continue
        local sudo_flag
        groups "$name" 2>/dev/null | grep -qE '\bsudo\b|\bwheel\b|\badmin\b' \
            && sudo_flag="${GRN}[SUDO]${NC}" || sudo_flag="${GRY}  —  ${NC}"
        printf "  ${WHT}%-20s${NC}  ${GRY}%-6s${NC}  %-22s  " "$name" "$uid" "$shell"
        echo -e "$sudo_flag"
    done < /etc/passwd
    echo -e "\n  ${YLW}[ Membres sudo/wheel/admin ]${NC}"
    echo -e "  ${GRY}sudo :${NC}  $(getent group sudo  2>/dev/null | cut -d: -f4 || echo '—')"
    echo -e "  ${GRY}wheel :${NC} $(getent group wheel 2>/dev/null | cut -d: -f4 || echo '—')"
    echo -e "  ${GRY}admin :${NC} $(getent group admin 2>/dev/null | cut -d: -f4 || echo '—')"
    _pause
}

um_add() {
    clear
    _draw_header "CREER UN UTILISATEUR"
    echo -e "  ${YLW}Nom du nouvel utilisateur :${NC} "
    read -r newuser
    [[ ! "$newuser" =~ ^[a-z_][a-z0-9_-]*$ ]] && {
        echo -e "  ${RED}[✗] Nom invalide (minuscules, chiffres, _ - uniquement).${NC}"
        _pause; return
    }
    id "$newuser" &>/dev/null && {
        echo -e "  ${RED}[✗] L utilisateur '${newuser}' existe déjà.${NC}"; _pause; return
    }

    MENU_OPTS=(
        "Utilisateur standard   — sans sudo"
        "Utilisateur admin      — avec droits sudo"
        "--- Annuler"
    )
    AutoMenu "TYPE DE COMPTE" || return

    case $MENU_CHOICE in
        0) useradd -m -s /bin/bash "$newuser" ;;
        1) useradd -m -s /bin/bash -G sudo "$newuser" 2>/dev/null \
               || useradd -m -s /bin/bash -G wheel "$newuser" ;;
        *) return ;;
    esac

    echo -e "\n  ${YLW}[~] Définir le mot de passe :${NC}\n"
    passwd "$newuser"
    echo -e "\n  ${GRN}[✓] Utilisateur '${newuser}' créé.${NC}"
    _pause
}

um_del() {
    clear
    _draw_header "SUPPRIMER UN UTILISATEUR"

    local -a real_users
    while IFS=: read -r name _ uid _ _ _ _; do
        [[ "$uid" -ge 1000 && "$uid" -lt 65534 ]] && real_users+=("$name")
    done < /etc/passwd

    [ ${#real_users[@]} -eq 0 ] && { echo -e "  ${GRY}Aucun utilisateur.${NC}"; _pause; return; }

    MENU_OPTS=("${real_users[@]}" "--- Annuler")
    AutoMenu "CHOISIR UTILISATEUR" || return
    [ $MENU_CHOICE -ge ${#real_users[@]} ] && return
    local target="${real_users[$MENU_CHOICE]}"

    MENU_OPTS=(
        "Compte uniquement       — Garder /home/${target}"
        "Compte + /home          — Supprimer tout"
        "--- Annuler"
    )
    AutoMenu "CONFIRMER : ${target}" || return

    case $MENU_CHOICE in
        0) userdel "$target" ;;
        1) userdel -r "$target" ;;
        *) return ;;
    esac
    echo -e "  ${GRN}[✓] Utilisateur '${target}' supprimé.${NC}"
    _pause
}

um_reset() {
    clear
    _draw_header "CHANGER MOT DE PASSE"

    local -a real_users
    while IFS=: read -r name _ uid _ _ _ _; do
        [[ "$uid" -ge 1000 && "$uid" -lt 65534 ]] && real_users+=("$name")
    done < /etc/passwd
    real_users+=("root")

    MENU_OPTS=("${real_users[@]}" "--- Annuler")
    AutoMenu "CHOISIR UTILISATEUR" || return
    [ $MENU_CHOICE -ge ${#real_users[@]} ] && return
    local target="${real_users[$MENU_CHOICE]}"

    echo -e "\n  ${YLW}Nouveau mot de passe pour ${target} :${NC}\n"
    passwd "$target"
    _pause
}

um_admin() {
    clear
    _draw_header "DROITS SUDO"

    local -a real_users
    while IFS=: read -r name _ uid _ _ _ _; do
        [[ "$uid" -ge 1000 && "$uid" -lt 65534 ]] && real_users+=("$name")
    done < /etc/passwd
    [ ${#real_users[@]} -eq 0 ] && { _pause; return; }

    MENU_OPTS=("${real_users[@]}" "--- Annuler")
    AutoMenu "CHOISIR UTILISATEUR" || return
    [ $MENU_CHOICE -ge ${#real_users[@]} ] && return
    local target="${real_users[$MENU_CHOICE]}"

    local has_sudo=0
    groups "$target" 2>/dev/null | grep -qE '\bsudo\b|\bwheel\b|\badmin\b' && has_sudo=1

    clear
    _draw_header "SUDO : ${target}"
    echo -e "  Statut : $([ $has_sudo -eq 1 ] && echo -e "${GRN}SUDO ACTIF${NC}" || echo -e "${GRY}Pas de sudo${NC}")\n"

    MENU_OPTS=(
        "Accorder les droits sudo"
        "Retirer les droits sudo"
        "--- Annuler"
    )
    AutoMenu "ACTION" || return

    local sudo_group
    getent group sudo &>/dev/null && sudo_group="sudo" || sudo_group="wheel"

    case $MENU_CHOICE in
        0)
            usermod -aG "$sudo_group" "$target"
            echo -e "  ${GRN}[✓] ${target} a maintenant les droits sudo.${NC}" ;;
        1)
            gpasswd -d "$target" "$sudo_group" 2>/dev/null
            gpasswd -d "$target" admin 2>/dev/null
            gpasswd -d "$target" wheel 2>/dev/null
            echo -e "  ${GRN}[✓] Droits sudo retirés pour ${target}.${NC}" ;;
        *) return ;;
    esac
    _pause
}

sys_eicar() {
    clear
    _draw_header "TEST EICAR — REPONSE ANTIVIRUS"
    _require clamscan clamav || return

    local eicar_b64="WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCo="
    local eicar_file="/tmp/eicar_test_$$.com"
    echo "$eicar_b64" | base64 -d > "$eicar_file" 2>/dev/null

    echo -e "  ${YLW}[~] Scan ClamAV du fichier EICAR...${NC}\n"
    clamscan "$eicar_file" 2>&1 | while IFS= read -r l; do echo "  $l"; done

    if clamscan "$eicar_file" 2>/dev/null | grep -q "FOUND"; then
        echo -e "\n  ${GRN}[✓] Antivirus opérationnel — EICAR détecté.${NC}"
    else
        echo -e "\n  ${RED}[✗] EICAR non détecté — vérifier la configuration ClamAV.${NC}"
    fi
    rm -f "$eicar_file"
    _pause
}

um_remove_pwd() {
    clear
    _draw_header "SUPPRIMER LE MOT DE PASSE (AUTO-LOGIN)"
    echo -e "  ${RED}[!] L utilisateur pourra se connecter SANS mot de passe.${NC}\n"
    local -a real_users
    while IFS=: read -r name _ uid _ _ _ _; do
        [[ "$uid" -ge 1000 && "$uid" -lt 65534 ]] && real_users+=("$name")
    done < /etc/passwd
    [ ${#real_users[@]} -eq 0 ] && { echo -e "  ${GRY}Aucun utilisateur.${NC}"; _pause; return; }
    MENU_OPTS=("${real_users[@]}" "--- Annuler")
    AutoMenu "CHOISIR UTILISATEUR" || return
    [ $MENU_CHOICE -ge ${#real_users[@]} ] && return
    local target="${real_users[$MENU_CHOICE]}"
    MENU_OPTS=("Confirmer la suppression du mot de passe pour $target" "--- Annuler")
    AutoMenu "CONFIRMATION" || return
    [ $MENU_CHOICE -ne 0 ] && return
    passwd -d "$target" 2>&1
    echo -e "\n  ${GRN}[✓] Mot de passe supprime pour '${target}'.${NC}"
    echo -e "  ${GRY}    Auto-login sans mot de passe active.${NC}"
    _pause
}

um_superadmin() {
    clear
    _draw_header "SUPER ADMINISTRATEUR (COMPTE ROOT)"
    local root_locked
    passwd -S root 2>/dev/null | grep -q " L " && root_locked=1 || root_locked=0
    if [ $root_locked -eq 1 ]; then
        echo -e "  Statut : ${RED}VERROUILLE (desactive)${NC}\n"
    else
        echo -e "  Statut : ${GRN}ACTIF (connexion root possible)${NC}\n"
    fi
    MENU_OPTS=(
        "Activer le compte root — definir un mot de passe"
        "Desactiver le compte root — verrouiller"
        "--- Annuler"
    )
    AutoMenu "COMPTE ROOT" || return
    case $MENU_CHOICE in
        0)
            echo -e "\n  ${YLW}[~] Definir le mot de passe root :${NC}\n"
            passwd root
            echo -e "\n  ${GRN}[✓] Compte root active.${NC}" ;;
        1)
            passwd -l root 2>&1
            echo -e "  ${GRN}[✓] Compte root verrouille.${NC}" ;;
        *) return ;;
    esac
    _pause
}

wd_quick() {
    clear
    _draw_header "SCAN RAPIDE ANTIVIRUS (ClamAV)"
    _require clamscan clamav || return
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local home="/home/$user"
    echo -e "  ${YLW}[~] Scan rapide de ${home}...${NC}\n"
    clamscan -r --bell -i "$home" 2>&1 | while IFS= read -r l; do
        echo "$l" | grep -qiE "FOUND|Infected" \
            && echo -e "  ${RED}$l${NC}" || echo -e "  ${GRY}$l${NC}"
    done
    echo -e "\n  ${GRN}[✓] Scan rapide termine.${NC}"
    _pause
}

wd_full() {
    clear
    _draw_header "SCAN COMPLET ANTIVIRUS (ClamAV)"
    _require clamscan clamav || return
    echo -e "  ${RED}[!] Scan complet du systeme — peut prendre plusieurs minutes.${NC}\n"
    MENU_OPTS=("Lancer le scan complet (/)" "--- Annuler")
    AutoMenu "SCAN COMPLET" || return
    [ $MENU_CHOICE -ne 0 ] && return
    echo -e "\n  ${YLW}[~] Scan en cours...${NC}\n"
    clamscan -r --bell -i / \
        --exclude-dir="^/proc" --exclude-dir="^/sys" --exclude-dir="^/dev" 2>&1 \
        | while IFS= read -r l; do
            echo "$l" | grep -qiE "FOUND|Infected" \
                && echo -e "  ${RED}$l${NC}" || echo -e "  ${GRY}$l${NC}"
        done
    echo -e "\n  ${GRN}[✓] Scan complet termine.${NC}"
    _pause
}

wd_update() {
    clear
    _draw_header "MISE A JOUR SIGNATURES ANTIVIRUS"
    _require freshclam clamav || return
    echo -e "  ${YLW}[~] Mise a jour des signatures ClamAV...${NC}\n"
    freshclam 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Signatures mises a jour.${NC}"
    _pause
}

wd_status() {
    clear
    _draw_header "STATUT ANTIVIRUS (ClamAV)"
    echo -e "  ${YLW}[ Services ClamAV ]${NC}\n"
    for svc in clamav-daemon clamav-freshclam; do
        if systemctl is-active "$svc" &>/dev/null; then
            echo -e "  ${GRN}[✓] ${svc} : ACTIF${NC}"
        else
            echo -e "  ${RED}[✗] ${svc} : INACTIF${NC}"
        fi
    done
    echo -e "\n  ${YLW}[ Version ]${NC}\n"
    clamscan --version 2>/dev/null | head -1 | while IFS= read -r l; do echo -e "  ${WHT}$l${NC}"; done
    echo -e "\n  ${YLW}[ Signatures ]${NC}\n"
    local sig_dir="/var/lib/clamav"
    ls -lh "$sig_dir"/*.cvd "$sig_dir"/*.cld 2>/dev/null \
        | awk '{print "  "$5, $9}' | while IFS= read -r l; do echo -e "${GRY}$l${NC}"; done
    _pause
}

menu_comptes() {
    while true; do
        MENU_OPTS=(
            "--- ─────────────── MOTS DE PASSE & EXTRACTION ──────────"
            "WiFi Passwords       — Profils NetworkManager"
            "Passwords Navigateur — Firefox / Chrome logins"
            "Historique Web       — Firefox / Chrome / Chromium"
            "Fichiers Sensibles   — .key .pem .env credentials..."
            "--- ─────────────────── UTILISATEURS ───────────────────"
            "Lister Utilisateurs  — Comptes + groupes + sudo"
            "Creer Utilisateur    — Nouveau compte + mot de passe"
            "Supprimer Utilisateur — Compte et/ou dossier home"
            "Changer Mot de Passe — passwd interactif"
            "Droits Sudo          — Accorder / retirer sudo"
            "Supprimer le MDP     — Auto-login sans mot de passe"
            "Super Administrateur — Activer / desactiver root"
            "--- ─────────────────── ANTIVIRUS ───────────────────────"
            "Scan Rapide ClamAV   — Analyse securite rapide (home)"
            "Scan Complet ClamAV  — Analyse totale du systeme"
            "Mettre a jour ClamAV — Signatures virus (freshclam)"
            "Statut ClamAV        — Protection active ou non"
            "Test EICAR           — Verifier reponse antivirus"
            "--- Retour au menu principal"
        )
        AutoMenu "COMPTES & SECURITE" || return
        case $MENU_CHOICE in
            1)  dump_wifi ;;
            2)  dump_browser ;;
            3)  gather_browser_history ;;
            4)  search_sensitive_docs ;;
            6)  um_list ;;
            7)  um_add ;;
            8)  um_del ;;
            9)  um_reset ;;
            10) um_admin ;;
            11) um_remove_pwd ;;
            12) um_superadmin ;;
            14) wd_quick ;;
            15) wd_full ;;
            16) wd_update ;;
            17) wd_status ;;
            18) sys_eicar ;;
            19) return ;;
            *)  return ;;
        esac
    done
}

# ================================================================
#  FONCTIONS ALIAS WINDOWS → LINUX (noms identiques au script .bat)
# ================================================================

# --- NETTOYAGE aliases ---
sys_clean_unified()    { cl_all; }
sys_registry_cleanup() { cl_orphans; }
sys_tweaks_menu()      { sys_tweaks; }
sys_startup_manager()  { sys_startup; }
cl_wu()                { cl_apt; }
cl_disk() {
    clear; _draw_header "NETTOYAGE DISQUE"
    echo -e "  ${YLW}[1/2] Paquets orphelins...${NC}\n"
    apt-get autoremove -y 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[2/2] Anciennes revisions Snap...${NC}\n"
    if command -v snap &>/dev/null; then
        snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' \
            | while read name rev; do snap remove "$name" --revision="$rev" 2>/dev/null; done
        echo -e "  ${GRN}[✓] Snap nettoye.${NC}"
    fi
    _pause
}
cl_registry()   { sys_tweaks; }
cl_clipboard() {
    clear; _draw_header "VIDER LE PRESSE-PAPIERS"
    if command -v xclip &>/dev/null; then
        echo -n "" | xclip -selection clipboard 2>/dev/null
        echo -e "  ${GRN}[✓] Presse-papiers vide (xclip).${NC}"
    elif command -v xdotool &>/dev/null; then
        xdotool type "" 2>/dev/null
        echo -e "  ${GRN}[✓] Presse-papiers vide (xdotool).${NC}"
    else
        echo -e "  ${YLW}[~] Installation de xclip...${NC}"
        apt-get install -y xclip 2>/dev/null | tail -2
        echo -n "" | xclip -selection clipboard 2>/dev/null
    fi
    _pause
}
res_temp_clean()    { cl_temp; }
res_clean_browsers(){ cl_browser; }

# --- DNS / RESEAU aliases ---
show_dns_config()   { dns_display; }
net_flush_dns()     { cl_dns; }
net_display_dns() {
    clear; _draw_header "AFFICHER CACHE DNS"
    command -v resolvectl &>/dev/null \
        && resolvectl statistics 2>/dev/null | while IFS= read -r l; do echo "  $l"; done \
        || cat /etc/resolv.conf | while IFS= read -r l; do echo "  $l"; done
    _pause
}
net_clear_arp() {
    clear; _draw_header "VIDER CACHE ARP"
    ip neigh flush all 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "  ${GRN}[✓] Cache ARP vide.${NC}"; _pause
}
net_display_arp() {
    clear; _draw_header "TABLE ARP"
    ip neigh show 2>/dev/null | while IFS= read -r l; do echo "  $l"; done; _pause
}
net_renew_ip() {
    clear; _draw_header "RENOUVELER L IP"
    local iface; iface=$(ip route | awk '/default/{print $5; exit}')
    echo -e "  ${YLW}[~] Renouvellement sur ${iface}...${NC}\n"
    if command -v nmcli &>/dev/null; then
        nmcli device reapply "$iface" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    elif command -v dhclient &>/dev/null; then
        dhclient -r "$iface" 2>/dev/null; dhclient "$iface" 2>&1 \
            | while IFS= read -r l; do echo "  $l"; done
    fi
    echo -e "  ${GRN}[✓] IP renouvelee.${NC}"; _pause
}
net_reset_tcpip()    { res_net_reset; }
net_reset_winsock()  { res_net_reset; }
net_reset_all()      { res_net_reset; }
net_restart_adapters() {
    clear; _draw_header "REDEMARRER LES INTERFACES RESEAU"
    systemctl restart NetworkManager 2>&1 | while IFS= read -r l; do echo "  $l"; done
    sleep 2
    ip addr show 2>/dev/null | grep "inet " | grep -v "127.0.0.1" \
        | while IFS= read -r l; do echo "  $l"; done
    echo -e "  ${GRN}[✓] Interfaces relancees.${NC}"; _pause
}
net_fast_reset() {
    clear; _draw_header "SCRIPT URGENCE RESEAU"
    echo -e "  ${YLW}[1/5] Flush DNS...${NC}"; systemd-resolve --flush-caches 2>/dev/null || true
    echo -e "  ${YLW}[2/5] Vide ARP...${NC}"; ip neigh flush all 2>/dev/null || true
    echo -e "  ${YLW}[3/5] Release IP...${NC}"; dhclient -r 2>/dev/null || true
    echo -e "  ${YLW}[4/5] Restart NetworkManager...${NC}"; systemctl restart NetworkManager 2>/dev/null
    sleep 2
    echo -e "  ${YLW}[5/5] Renew IP...${NC}"; dhclient 2>/dev/null || true
    echo -e "\n  ${GRN}[✓] Reseau reinitialise.${NC}"; _pause
}

# --- CYBER aliases ---
cyber_triage() {
    clear; _draw_header "TRIAGE DE CONNECTIVITE"
    echo -e "  ${YLW}[ IP locale ]${NC}"
    ip -4 addr | grep "inet " | grep -v "127.0.0.1" | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ Gateway ]${NC}"
    ip route | grep default | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ DNS ]${NC}"
    grep nameserver /etc/resolv.conf | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ Ping 8.8.8.8 ]${NC}"
    ping -c 2 8.8.8.8 2>&1 | tail -2 | while IFS= read -r l; do echo "  $l"; done
    _pause
}
cyber_adapter_audit() {
    clear; _draw_header "AUDIT ADAPTATEURS RESEAU"
    ip -s link show 2>/dev/null | while IFS= read -r l; do echo "  $l"; done; _pause
}
cyber_lan_auto()       { net_workflow_lan; }
cyber_flux_analysis() {
    clear; _draw_header "ANALYSE FLUX RESEAU"
    ss -tulpn 2>/dev/null | while IFS= read -r l; do echo "  $l"; done; _pause
}
cyber_ip_grabber() {
    clear; _draw_header "SCANNER CIBLE DISTANTE"
    _require nmap nmap || return
    echo -e "  ${YLW}IP ou domaine cible :${NC} "; read -r target; [ -z "$target" ] && return
    echo -e "\n  ${YLW}[~] Scan rapide (top 100 ports)...${NC}\n"
    nmap -T4 --top-ports 100 "$target" 2>/dev/null | grep -E "open|PORT" \
        | while IFS= read -r l; do echo "  $l"; done
    _pause
}
cyber_exposure_audit() { search_sensitive_docs; }
cyber_wifi_audit() {
    clear; _draw_header "ANALYSEUR WI-FI (EVIL TWIN)"
    _require nmcli network-manager || return
    nmcli -f SSID,BSSID,CHAN,SIGNAL,SECURITY dev wifi list 2>/dev/null \
        | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${YLW}[ SSID en double (potentiel Evil Twin) ]${NC}\n"
    local dups; dups=$(nmcli -t -f SSID dev wifi list 2>/dev/null | sort | uniq -d)
    [ -n "$dups" ] && echo -e "  ${RED}[!] $dups${NC}" || echo -e "  ${GRN}  Aucun doublon.${NC}"
    _pause
}
net_fast_discover()  { net_discover; }
net_service_enum()   { net_enum; }
net_vuln_check()     { net_vuln; }

# --- APPLICATIONS aliases ---
update_single() {
    clear; _draw_header "METTRE A JOUR UNE APPLICATION"
    echo -e "  ${YLW}Nom du paquet :${NC} "; read -r pkg; [ -z "$pkg" ] && return
    apt-get install --only-upgrade -y "$pkg" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    _pause
}
update_all()            { app_update; }
app_install_chrome() {
    clear; _draw_header "INSTALLER GOOGLE CHROME"
    local tmp="/tmp/chrome_$$.deb"
    curl -L "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
        -o "$tmp" 2>&1 | tail -2
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp" 2>&1 \
        | while IFS= read -r l; do echo "  $l"; done
    rm -f "$tmp"; echo -e "\n  ${GRN}[✓] Chrome installe.${NC}"; _pause
}
app_install_vlc() {
    clear; _draw_header "INSTALLER VLC"
    apt-get install -y vlc 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] VLC installe.${NC}"; _pause
}
app_install_pdf() {
    clear; _draw_header "INSTALLER LECTEUR PDF"
    apt-get install -y okular 2>/dev/null || apt-get install -y evince 2>/dev/null
    echo -e "\n  ${GRN}[✓] Lecteur PDF installe.${NC}"; _pause
}
app_install_winrar() {
    clear; _draw_header "INSTALLER GESTIONNAIRE ARCHIVES (p7zip)"
    apt-get install -y p7zip-full p7zip-rar 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] p7zip installe.${NC}"; _pause
}
app_install_office() {
    clear; _draw_header "INSTALLER LIBREOFFICE"
    apt-get install -y libreoffice 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] LibreOffice installe.${NC}"; _pause
}
app_install_ps7() {
    clear; _draw_header "INSTALLER SHELL AVANCE (zsh)"
    apt-get install -y zsh 2>&1 | while IFS= read -r l; do echo "  $l"; done
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    chsh -s /bin/zsh "$user" 2>/dev/null
    echo -e "\n  ${GRN}[✓] zsh installe.${NC}"; _pause
}

# --- COMPTES aliases ---
dump_credman() {
    clear; _draw_header "CREDENTIAL MANAGER (GNOME Keyring)"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    echo -e "  ${YLW}[ GNOME Keyring / Secret Service ]${NC}\n"
    command -v secret-tool &>/dev/null \
        && secret-tool search service "" 2>/dev/null | while IFS= read -r l; do echo "  $l"; done \
        || echo -e "  ${GRY}  secret-tool non disponible.${NC}"
    echo -e "\n  ${YLW}[ Wallet KDE ]${NC}\n"
    find "/home/$user/.local/share/kwalletd" -name "*.kwl" 2>/dev/null \
        | while IFS= read -r f; do echo -e "  ${WHT}$f${NC}"; done || echo -e "  ${GRY}  Aucun.${NC}"
    _pause
}
sys_nirsoft_pw()   { dump_browser; }
wd_threats() {
    clear; _draw_header "MENACES DETECTEES (ClamAV)"
    _require clamscan clamav || return
    local log="/var/log/clamav/clamav.log"
    [ -f "$log" ] \
        && grep -iE "FOUND|Infected" "$log" 2>/dev/null | tail -30 \
            | while IFS= read -r l; do echo -e "  ${RED}$l${NC}"; done \
        || echo -e "  ${GRY}  Log ClamAV non trouve.${NC}"
    _pause
}
av_launcher_eicar(){ sys_eicar; }
av_launcher_heur() {
    clear; _draw_header "TEST HEURISTIQUE"
    _require clamscan clamav || return
    local f="/tmp/heur_test_$$.sh"
    printf '#!/bin/bash\ncat /etc/passwd > /tmp/dump\n' > "$f"; chmod +x "$f"
    clamscan --heuristic-alerts=yes "$f" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    rm -f "$f"; _pause
}
av_clean() {
    clear; _draw_header "NETTOYER FICHIERS TEST"
    find /tmp -name "eicar*" -o -name "heur_test*" 2>/dev/null \
        | while IFS= read -r f; do rm -f "$f" && echo -e "  ${GRN}[✓] $f${NC}"; done
    echo -e "\n  ${GRN}[✓] Nettoyage termine.${NC}"; _pause
}
dump_browser_local(){ dump_browser; }

# --- MATERIEL aliases ---
pp_balanced()  { clear; _draw_header "PLAN EQUILIBRE";        _set_governor "ondemand";    _pause; }
pp_saver()     { clear; _draw_header "PLAN ECONOMIES";        _set_governor "powersave";   _pause; }
pp_high()      { clear; _draw_header "PLAN HAUTES PERFS";     _set_governor "performance"; _pause; }
pp_ultimate()  { clear; _draw_header "PLAN PERFORMANCES MAX"; _set_governor "performance"; _pause; }
pp_current() {
    clear; _draw_header "PLAN ACTUEL"
    local core=0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$f" ] && printf "  Core %-3s : ${WHT}%s${NC}\n" "$core" "$(cat "$f" 2>/dev/null)"
        ((core++))
    done; _pause
}
pp_list() {
    clear; _draw_header "PLANS DISPONIBLES"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null \
        | tr ' ' '\n' | while IFS= read -r l; do echo -e "  ${WHT}$l${NC}"; done; _pause
}
hw_all() { hw_full_report; hw_winsat; hw_ram_test; }

# --- BOOT / WINRE aliases ---
winre_boot() {
    clear; _draw_header "REDEMARRER LE SYSTEME"
    MENU_OPTS=("Confirmer le redemarrage" "--- Annuler")
    AutoMenu "CONFIRMATION" || return
    [ $MENU_CHOICE -ne 0 ] && return; systemctl reboot
}
winre_bootmenu() {
    clear; _draw_header "AFFICHER MENU DE DEMARRAGE GRUB"
    sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub 2>/dev/null
    sed -i 's/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub 2>/dev/null
    update-grub 2>/dev/null | tail -3 | while IFS= read -r l; do echo "  $l"; done
    echo -e "\n  ${GRN}[✓] Menu GRUB active au prochain boot.${NC}"; _pause
}
winre_safe_network() {
    clear; _draw_header "MODE SANS ECHEC RESEAU"
    echo -e "  ${YLW}[ Instructions ]${NC}\n"
    echo -e "  1. Redemarrez et maintenez ${WHT}SHIFT${NC} pour le menu GRUB"
    echo -e "  2. Selectionnez 'Advanced options' > 'recovery mode'"
    echo -e "  3. Dans le menu recovery, choisissez 'network' puis 'root'"
    sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub 2>/dev/null
    update-grub 2>/dev/null | tail -2
    echo -e "\n  ${GRN}[✓] Menu GRUB active au prochain boot.${NC}"; _pause
}
winre_safe_cmd() {
    clear; _draw_header "MODE SANS ECHEC — INVITE DE COMMANDES"
    echo -e "  ${YLW}[ Instructions pour demarrer en shell root ]${NC}\n"
    echo -e "  1. Redemarrez et maintenez ${WHT}SHIFT${NC}"
    echo -e "  2. Selectionnez 'Advanced options' > noyau avec ${WHT}'recovery mode'${NC}"
    echo -e "  3. Choisissez ${WHT}'root — Drop to root shell prompt'${NC}"
    echo -e "\n  Alternative : ${WHT}sudo systemctl rescue${NC}"
    _pause
}
winre_nosign() {
    clear; _draw_header "SANS VERIFICATION SIGNATURES"
    echo -e "  ${YLW}[i] Equivalent Linux : desactiver Secure Boot.${NC}\n"
    echo -e "  ${WHT}sudo mokutil --disable-validation${NC}  — desactive Secure Boot"
    echo -e "  ${WHT}sudo modprobe -f <module>${NC}          — force le chargement d un module"
    _pause
}
res_gpedit() {
    clear; _draw_header "EDITEUR DE STRATEGIE (dconf-editor)"
    apt-get install -y dconf-editor 2>&1 | tail -3 | while IFS= read -r l; do echo "  $l"; done
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    sudo -u "$user" env DISPLAY="${DISPLAY:-:0}" dconf-editor 2>/dev/null &
    echo -e "\n  ${GRN}[✓] dconf-editor ouvert.${NC}"; _pause
}

# --- PERSONNALISATION aliases ---
activate_classic() {
    clear; _draw_header "MENU CONTEXTUEL CLASSIQUE"
    local user="${SUDO_USER:-$(logname 2>/dev/null)}"
    local dir="/home/$user/.local/share/nautilus/scripts"
    mkdir -p "$dir"
    cat > "$dir/Ouvrir Terminal Ici" << 'EOF'
#!/bin/bash
for t in gnome-terminal konsole xterm; do command -v "$t" &>/dev/null && exec "$t" && break; done
EOF
    chmod +x "$dir/Ouvrir Terminal Ici"
    chown -R "$user:$user" "$dir" 2>/dev/null
    echo -e "  ${GRN}[✓] Script 'Ouvrir Terminal Ici' ajoute dans Nautilus.${NC}"; _pause
}
restore_modern() {
    clear; _draw_header "MENU CONTEXTUEL MODERNE"
    dconf reset /org/gnome/nautilus/preferences/ 2>/dev/null
    echo -e "  ${GRN}[✓] Menu contextuel restaure.${NC}"; _pause
}
touch_restart() {
    clear; _draw_header "REDEMARRER PILOTE TACTILE"
    for m in $(lsmod 2>/dev/null | grep -iE "hid_multitouch|usbhid" | awk '{print $1}'); do
        modprobe -r "$m" 2>/dev/null; sleep 1; modprobe "$m" 2>/dev/null
        echo -e "  ${GRN}[✓] $m rechargé.${NC}"
    done; _pause
}
touch_disable() {
    clear; _draw_header "DESACTIVER ECRAN TACTILE"
    _require xinput || return
    local id; id=$(xinput list 2>/dev/null | grep -iE "touch|stylus" | grep -oP 'id=\K[0-9]+' | head -1)
    [ -z "$id" ] && { echo -e "  ${GRY}Aucun tactile detecte.${NC}"; _pause; return; }
    xinput disable "$id" 2>/dev/null && echo -e "  ${GRN}[✓] Tactile desactive (id=$id).${NC}"; _pause
}
touch_enable() {
    clear; _draw_header "ACTIVER ECRAN TACTILE"
    _require xinput || return
    local id; id=$(xinput list 2>/dev/null | grep -iE "touch|stylus" | grep -oP 'id=\K[0-9]+' | head -1)
    [ -z "$id" ] && { echo -e "  ${GRY}Aucun tactile detecte.${NC}"; _pause; return; }
    xinput enable "$id" 2>/dev/null && echo -e "  ${GRN}[✓] Tactile active (id=$id).${NC}"; _pause
}
print_list() {
    clear; _draw_header "LISTER LES IMPRIMANTES"
    lpstat -p 2>/dev/null | while IFS= read -r l; do echo "  $l"; done \
        || echo -e "  ${GRY}Aucune imprimante.${NC}"; _pause
}
print_clear_queue() {
    clear; _draw_header "VIDER LA FILE D ATTENTE"
    cancel -a 2>/dev/null && echo -e "  ${GRN}[✓] File videe.${NC}" \
        || echo -e "  ${GRY}Aucun job.${NC}"; _pause
}
print_remove() {
    clear; _draw_header "SUPPRIMER UNE IMPRIMANTE"
    local -a printers; mapfile -t printers < <(lpstat -p 2>/dev/null | awk '{print $2}')
    [ ${#printers[@]} -eq 0 ] && { echo -e "  ${GRY}Aucune imprimante.${NC}"; _pause; return; }
    MENU_OPTS=("${printers[@]}" "--- Annuler"); AutoMenu "CHOISIR" || return
    [ $MENU_CHOICE -ge ${#printers[@]} ] && return
    lpadmin -x "${printers[$MENU_CHOICE]}" 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "  ${GRN}[✓] Imprimante supprimee.${NC}"; _pause
}
print_restart_spooler() {
    clear; _draw_header "REDEMARRER LE SPOOLER CUPS"
    systemctl restart cups 2>&1 | while IFS= read -r l; do echo "  $l"; done
    echo -e "  ${GRN}[✓] CUPS redémarre.${NC}"; _pause
}

# ================================================================
#  MENUS — STRUCTURE IDENTIQUE AU SCRIPT WINDOWS
# ================================================================

# ----------------------------------------------------------------
#  DIAGNOSTIC → sys_diagnostic_menu
# ----------------------------------------------------------------
sys_diagnostic_menu() {
    while true; do
        MENU_OPTS=(
            "Rapport Systeme              — CPU, RAM, GPU, Stockage, Reseau"
            "Rapport de Temperature       — Capteurs CPU et GPU (lm-sensors)"
            "Test de Memoire RAM          — Modules, slots, vitesse"
            "Diagnostic Reseau            — Ping, traceroute, ports"
            "Rapport Batterie             — Usure et autonomie"
            "Etat Chiffrement Disque      — LUKS / dm-crypt"
            "Journal des Erreurs          — Evenements critiques (journalctl)"
            "Test Materiel                — CPU/RAM stress test (stress-ng)"
            "Etat Antivirus               — ClamAV / protection active"
            "Erreurs Critiques 24h        — journalctl -p crit"
            "Erreurs Critiques 7 jours    — Historique des pannes"
            "Erreurs Applications 24h     — Segfaults et crashs"
            "Alertes Disque               — smartctl health check"
            "--- Retour"
        )
        AutoMenu "ANALYSE ET DIAGNOSTIC SYSTEME" || return
        case $MENU_CHOICE in
            0)  sys_report ;;
            1)  sys_temp_report ;;
            2)  sys_ram_check ;;
            3)  sys_diag_network ;;
            4)  sys_battery_report ;;
            5)  sys_bitlocker_check ;;
            6)  sys_event_log ;;
            7)  sys_hw_test ;;
            8)  sys_defender ;;
            9)  sys_ev_critical "24 hours" "24H" ;;
            10) sys_ev_critical "7 days" "7J" ;;
            11) ev_app_24h ;;
            12) ev_disk_warn ;;
            13) return ;;
            *)  return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  REPARATION → sys_rescue_menu
# ----------------------------------------------------------------
sys_rescue_menu() {
    while true; do
        MENU_OPTS=(
            "SFC Scannow              — Reparer paquets (apt --fix-broken)"
            "DISM CheckHealth         — Verifier integrite (debsums)"
            "DISM RestoreHealth       — Restaurer paquets corrompus"
            "CHKDSK                   — Verifier et reparer le filesystem (fsck)"
            "Reset Mises a Jour       — Reinitialiser verrous APT / dpkg"
            "Redemarrer Bureau        — GNOME / KDE / XFCE"
            "Reinitialiser GPU        — Rechargement du module pilote"
            "Point de Restauration    — Snapshot Timeshift"
            "Editeur de Strategie     — Installer dconf-editor"
            "--- Retour"
        )
        AutoMenu "OUTIL REPARATION SYSTEME (RESCUE)" || return
        case $MENU_CHOICE in
            0) res_sfc ;;
            1) res_dism_check ;;
            2) res_dism_restore ;;
            3) res_chkdsk ;;
            4) res_wu_reset ;;
            5) res_explorer_restart ;;
            6) res_gpu_reset ;;
            7) res_restore_point ;;
            8) res_gpedit ;;
            9) return ;;
            *) return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  WINRE → sys_winre
# ----------------------------------------------------------------
sys_winre() {
    while true; do
        MENU_OPTS=(
            "Redemarrer Systeme           — Reboot immediat"
            "Redemarrer vers BIOS/UEFI    — Acces au firmware"
            "Menu de Demarrage            — Afficher entrees GRUB"
            "Mode Sans Echec Minimal      — GRUB recovery mode"
            "Mode Sans Echec Reseau       — Recovery avec reseau"
            "Mode Sans Echec Invite       — Shell root direct"
            "Sans Verification Signatures — (Secure Boot)"
            "Statut Demarrage             — Noyaux, GRUB, EFI"
            "Reinitialiser GRUB           — Restaurer par defaut"
            "--- Retour"
        )
        AutoMenu "MODE DEMARRAGE / GRUB (WINRE)" || return
        case $MENU_CHOICE in
            0) winre_boot ;;
            1) winre_bios ;;
            2) winre_bootmenu ;;
            3) winre_safe_minimal ;;
            4) winre_safe_network ;;
            5) winre_safe_cmd ;;
            6) winre_nosign ;;
            7) winre_status ;;
            8) winre_reset ;;
            9) return ;;
            *) return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  NETTOYAGE → sys_opti_menu
# ----------------------------------------------------------------
sys_opti_menu() {
    while true; do
        MENU_OPTS=(
            "Tout Nettoyer d un coup      — Nettoyage automatique complet"
            "Nettoyage Complet Unifie     — Temp, APT, DNS, disque..."
            "Nettoyer le Registre         — Paquets orphelins + configs"
            "Optimisations Avancees       — Swappiness, CPU, IPv6"
            "Gestionnaire Demarrage       — Services au boot (systemd)"
            "--- ───────────────────────────────────────────────────"
            "Vider les Temporaires        — /tmp, /var/tmp, ~/.cache"
            "Purger Cache APT             — apt clean + autoremove"
            "Vider Cache DNS              — systemd-resolved flush"
            "Nettoyage Disque             — Orphelins + snap old revisions"
            "Nettoyer le Registre         — Configs obsoletes"
            "Vider le Presse-papiers      — xclip clear"
            "Nettoyage Temp Complet       — Temp + cache APT"
            "Nettoyer Caches Navigateurs  — Firefox, Chrome, Brave..."
            "--- Retour"
        )
        AutoMenu "NETTOYEUR ET OPTIMISEUR SYSTEME" || return
        case $MENU_CHOICE in
            0)  cl_all ;;
            1)  sys_clean_unified ;;
            2)  sys_registry_cleanup ;;
            3)  sys_tweaks_menu ;;
            4)  sys_startup_manager ;;
            6)  cl_temp ;;
            7)  cl_wu ;;
            8)  cl_dns ;;
            9)  cl_disk ;;
            10) cl_registry ;;
            11) cl_clipboard ;;
            12) res_temp_clean ;;
            13) res_clean_browsers ;;
            14) return ;;
            *)  return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  RESEAU DEPANNAGE → sys_network_menu
# ----------------------------------------------------------------
sys_network_menu() {
    while true; do
        MENU_OPTS=(
            "Afficher DNS                — Configuration actuelle"
            "Vider Cache DNS             — systemd-resolved flush"
            "Afficher Cache DNS          — Statistiques resolveur"
            "Vider Cache ARP             — ip neigh flush all"
            "Afficher Table ARP          — ip neigh show"
            "Renouveler IP               — dhclient / nmcli renew"
            "Reset TCP/IP                — NetworkManager + IP"
            "Reset Sockets               — Reinitialisation reseau"
            "Reset Reseau Automatique    — DNS + ARP + TCP/IP + NM"
            "Redemarrer les Interfaces   — Ethernet et Wi-Fi"
            "Script Urgence Reseau       — 5 commandes de depannage"
            "--- Retour"
        )
        AutoMenu "MENU DEPANNAGE RESEAU" || return
        case $MENU_CHOICE in
            0)  show_dns_config ;;
            1)  net_flush_dns ;;
            2)  net_display_dns ;;
            3)  net_clear_arp ;;
            4)  net_display_arp ;;
            5)  net_renew_ip ;;
            6)  net_reset_tcpip ;;
            7)  net_reset_winsock ;;
            8)  net_reset_all ;;
            9)  net_restart_adapters ;;
            10) net_fast_reset ;;
            11) return ;;
            *)  return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  CYBER (sous-menus WiFi / Interne / Distant)
# ----------------------------------------------------------------
net_menu_wifi() {
    while true; do
        MENU_OPTS=(
            "Scan Reseaux Wi-Fi       — SSID, BSSID, signal, securite"
            "Analyser une Cible Wi-Fi — Details reseau selectionne"
            "Cracker la Cle Wi-Fi     — WPA2 handshake + aircrack-ng"
            "Analyseur Evil Twin      — Detection faux points d acces"
            "--- Retour"
        )
        AutoMenu "WI-FI — HORS CONNEXION" || return
        case $MENU_CHOICE in
            0) net_wifi_scan ;;
            1) net_wifi_target ;;
            2) net_wifi_crack ;;
            3) cyber_wifi_audit ;;
            4) return ;;
            *) return ;;
        esac
    done
}

net_menu_interne() {
    while true; do
        MENU_OPTS=(
            "Scanner LAN              — IP, Nom, MAC, Fabricant"
            "Analyse Flux Reseau      — Ports ouverts + processus"
            "Triage Connectivite      — IP, Gateway, DNS"
            "Audit Adaptateurs        — MAC, vitesse, statut"
            "Audit Exposition         — Fichiers sensibles exposes"
            "Test Fuite DNS           — Verifier anonymat VPN"
            "--- Retour"
        )
        AutoMenu "RESEAU INTERNE — CONNECTE" || return
        case $MENU_CHOICE in
            0) cyber_lan_auto ;;
            1) cyber_flux_analysis ;;
            2) cyber_triage ;;
            3) cyber_adapter_audit ;;
            4) cyber_exposure_audit ;;
            5) cyber_dns_leak ;;
            6) return ;;
            *) return ;;
        esac
    done
}

net_menu_distant() {
    while true; do
        MENU_OPTS=(
            "Scanner Cible Distante   — IP Grabber + scan ports"
            "Web Interface Hunt       — Ports 80/443/8080/8443"
            "Enumeration Services     — SSH, RDP, FTP, VNC, Telnet"
            "Verification Failles     — Partages et acces Guest"
            "Audit Routes Web         — .env, /admin, /api exposes"
            "--- Retour"
        )
        AutoMenu "RESEAU DISTANT" || return
        case $MENU_CHOICE in
            0) cyber_ip_grabber ;;
            1) net_web_hunt ;;
            2) net_service_enum ;;
            3) net_vuln_check ;;
            4) scan_web_routes ;;
            5) return ;;
            *) return ;;
        esac
    done
}

net_cyber_menu() {
    while true; do
        MENU_OPTS=(
            "--- ──────────────── WORKFLOWS GUIDES ────────────────────"
            "Wi-Fi Hors Connexion     — Recherche, audit et crack WiFi"
            "Reseau Interne           — Scanner LAN, flux, DNS local"
            "Reseau Distant           — Scanner WAN, IP Grabber"
            "--- ──────────────── OUTILS RAPIDES ──────────────────────"
            "Triage Connectivite      — Diagnostic rapide"
            "Audit Adaptateurs        — MAC, vitesse, statut"
            "Scanner le LAN           — IP, Nom, MAC, Fabricant"
            "Analyse Flux Reseau      — Ports ouverts + processus"
            "Test Fuite DNS           — Verifier anonymat DNS"
            "Scanner Cible Distante   — IP Grabber + scan ports"
            "--- ──────────────── OUTILS AVANCES ──────────────────────"
            "Audit Exposition         — Fichiers sensibles exposes"
            "Analyseur Evil Twin      — Detection faux AP"
            "Web Interface Hunt       — Ports 80/443/8080/8443"
            "Enumeration Services     — SSH, RDP, FTP, VNC"
            "Verification Failles     — Partages et acces Guest"
            "Scan WiFi                — SSID, BSSID, signal"
            "Analyser Cible WiFi      — Details reseau selectionne"
            "Cracker Cle WiFi         — WPA2 handshake + aircrack-ng"
            "--- Retour"
        )
        AutoMenu "SCANNER DE FAILLES ET PENTEST" || return
        case $MENU_CHOICE in
            1)  net_menu_wifi ;;
            2)  net_menu_interne ;;
            3)  net_menu_distant ;;
            5)  cyber_triage ;;
            6)  cyber_adapter_audit ;;
            7)  cyber_lan_auto ;;
            8)  cyber_flux_analysis ;;
            9)  cyber_dns_leak ;;
            10) cyber_ip_grabber ;;
            12) cyber_exposure_audit ;;
            13) cyber_wifi_audit ;;
            14) net_web_hunt ;;
            15) net_service_enum ;;
            16) net_vuln_check ;;
            17) net_wifi_scan ;;
            18) net_wifi_target ;;
            19) net_wifi_crack ;;
            20) return ;;
            *)  return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  APPLICATIONS → winget_manager + app_installer
# ----------------------------------------------------------------
winget_manager() {
    while true; do
        MENU_OPTS=(
            "Mettre a jour une application — Choisir l app"
            "Mettre a jour tout            — apt + snap + flatpak + pip"
            "--- Retour"
        )
        AutoMenu "MISES A JOUR D APPLICATIONS" || return
        case $MENU_CHOICE in
            0) update_single ;;
            1) update_all ;;
            2) return ;;
            *) return ;;
        esac
    done
}

app_installer() {
    while true; do
        MENU_OPTS=(
            "Google Chrome        — Navigateur web"
            "VLC Media Player     — Lecteur multimedia"
            "Lecteur PDF          — Okular / Evince"
            "Gestionnaire Archives— p7zip (WinRAR equiv)"
            "LibreOffice          — Suite bureautique (Office equiv)"
            "Shell Avance         — zsh (PowerShell 7 equiv)"
            "--- Retour"
        )
        AutoMenu "INSTALLATEUR D APPLICATIONS" || return
        case $MENU_CHOICE in
            0) app_install_chrome ;;
            1) app_install_vlc ;;
            2) app_install_pdf ;;
            3) app_install_winrar ;;
            4) app_install_office ;;
            5) app_install_ps7 ;;
            6) return ;;
            *) return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  COMPTES ET SECURITE
# ----------------------------------------------------------------
sys_passwords_menu() {
    while true; do
        MENU_OPTS=(
            "Credential Manager   — GNOME Keyring / secrets"
            "Mots de passe Wi-Fi  — Afficher ou exporter les SSID"
            "Extracteur Navigateurs — Logins Firefox / Chrome"
            "--- Retour"
        )
        AutoMenu "EXTRACTEURS DE MOTS DE PASSE" || return
        case $MENU_CHOICE in
            0) dump_credman ;;
            1) dump_wifi ;;
            2) sys_nirsoft_pw ;;
            3) return ;;
            *) return ;;
        esac
    done
}

sys_unlock_notes() {
    clear
    _draw_header "RECUPERATION DE COMPTE BLOQUE"
    echo -e "  ${YLW}[ Instructions pour reprendre le controle ]${NC}\n"
    echo -e "  ${WHT}Si vous avez oublie votre mot de passe :${NC}\n"
    echo -e "  1. Redemarrez et entrez dans ${WHT}GRUB${NC} (maintenez SHIFT)"
    echo -e "  2. Selectionnez '${WHT}Advanced options${NC}' > 'recovery mode'"
    echo -e "  3. Choisissez '${WHT}root — Drop to root shell${NC}'"
    echo -e "  4. Dans le shell root :"
    echo -e "     ${WHT}passwd <nom_utilisateur>${NC}  — redefinir le mot de passe"
    echo -e "     ${WHT}adduser <nom> sudo${NC}        — ajouter aux admins"
    echo -e ""
    echo -e "  ${WHT}Recuperation depuis un Live USB :${NC}\n"
    echo -e "  1. Bootez sur un Live USB Ubuntu/Debian"
    echo -e "  2. Montez votre partition : ${WHT}sudo mount /dev/sdXY /mnt${NC}"
    echo -e "  3. Chroot : ${WHT}sudo chroot /mnt${NC}"
    echo -e "  4. ${WHT}passwd <nom_utilisateur>${NC}"
    _pause
}

um_menu() {
    while true; do
        MENU_OPTS=(
            "Lister les utilisateurs     — Tous les comptes locaux"
            "Ajouter un utilisateur      — Creer nouveau compte"
            "Supprimer un utilisateur    — Effacer compte et donnees"
            "Gerer les droits            — Passer standard ou admin (sudo)"
            "Ajouter / Modifier MDP      — Changer mot de passe"
            "Supprimer le MDP (Auto-login)— Enlever le mot de passe"
            "Super Administrateur        — Activer / desactiver root"
            "--- Retour"
        )
        AutoMenu "GESTION UTILISATEURS LOCAUX" || return
        case $MENU_CHOICE in
            0) um_list ;;
            1) um_add ;;
            2) um_del ;;
            3) um_admin ;;
            4) um_reset ;;
            5) um_remove_pwd ;;
            6) um_superadmin ;;
            7) return ;;
            *) return ;;
        esac
    done
}

sys_av_test() {
    while true; do
        MENU_OPTS=(
            "--- ──────────────── SCAN ────────────────────────────────"
            "Scan Rapide ClamAV       — Analyse securite rapide (home)"
            "Scan Complet ClamAV      — Analyse totale du systeme"
            "Mettre a jour ClamAV     — Signatures virus (freshclam)"
            "Voir les Menaces         — Historique virus detectes"
            "Statut ClamAV            — Protection active ou non"
            "--- ──────────────── TESTS ───────────────────────────────"
            "Test EICAR Standard      — Fichier de test officiel"
            "Test Heuristique         — Detection comportementale"
            "Nettoyer Fichiers Test   — Supprimer les tests EICAR"
            "--- Retour"
        )
        AutoMenu "TEST ANTIVIRUS" || return
        case $MENU_CHOICE in
            1)  wd_quick ;;
            2)  wd_full ;;
            3)  wd_update ;;
            4)  wd_threats ;;
            5)  wd_status ;;
            7)  av_launcher_eicar ;;
            8)  av_launcher_heur ;;
            9)  av_clean ;;
            10) return ;;
            *)  return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  EXTRACTION ET SAUVEGARDE → sys_export_menu
# ----------------------------------------------------------------
sys_export_menu() {
    while true; do
        MENU_OPTS=(
            "Cle Systeme              — Machine ID et cle ACPI MSDM"
            "Export Pilotes           — Modules kernel (lsmod)"
            "Liste Logiciels          — apt + snap + flatpak"
            "Export Wi-Fi et Apps     — Profils reseau et logiciels"
            "Extraction Finale Loot   — Wi-Fi, comptes, SSH, historique"
            "Extracteur Navigateurs   — Logins Firefox / Chrome"
            "Analyse Historique       — URLs sensibles Chrome/Firefox"
            "Scan Documents Critiques — SSH, AWS, IBAN, credentials"
            "Audit Routes Web         — .env, wp-config, /admin exposes"
            "--- Retour"
        )
        AutoMenu "RECUPERATION DE DONNEES" || return
        case $MENU_CHOICE in
            0) sys_win_key ;;
            1) sys_drivers ;;
            2) sys_export_software ;;
            3) sys_export_wifi_apps ;;
            4) sys_loot_all ;;
            5) dump_browser_local ;;
            6) gather_browser_history ;;
            7) search_sensitive_docs ;;
            8) scan_web_routes ;;
            9) return ;;
            *) return ;;
        esac
    done
}

# ----------------------------------------------------------------
#  MATERIEL → touch_screen_manager, sys_print_manager, sys_power_plan
# ----------------------------------------------------------------
sys_power_plan() {
    while true; do
        MENU_OPTS=(
            "Plan Equilibre           — Usage quotidien (ondemand)"
            "Plan Economies d Energie — Autonomie maximale (powersave)"
            "Plan Hautes Performances — Maximum de puissance (performance)"
            "Plan Performances Ultimes— CPU governor = performance max"
            "Voir le Plan Actuel      — Afficher governor + frequences"
            "Lister tous les Plans    — Plans disponibles"
            "--- Retour"
        )
        AutoMenu "GESTIONNAIRE PLAN D ALIMENTATION" || return
        case $MENU_CHOICE in
            0) pp_balanced ;;
            1) pp_saver ;;
            2) pp_high ;;
            3) pp_ultimate ;;
            4) pp_current ;;
            5) pp_list ;;
            6) return ;;
            *) return ;;
        esac
    done
}

# ================================================================
#  MENU PRINCIPAL — STRUCTURE IDENTIQUE AU SCRIPT WINDOWS
# ================================================================
menu_principal() {
    while true; do
        MENU_OPTS=(
            "--- ────────────────── DIAGNOSTIC ──────────────────────────"
            "Analyse et Diagnostic Systeme   — 13 outils (CPU, RAM, Reseau...)"
            "--- ────────────────── REPARATION ──────────────────────────"
            "Outil Reparation Systeme (Rescue)— SFC, DISM, CHKDSK, Reset APT..."
            "Reparation Cache Icones          — Icones et miniatures corrompues"
            "Mode Demarrage / GRUB            — Sans echec, BIOS, recovery"
            "--- ────────────────── NETTOYAGE ET OPTIMISATION ───────────"
            "Nettoyeur et Optimiseur Systeme  — Cache, logs, orphelins, tweaks"
            "--- ────────────────── RESEAU ──────────────────────────────"
            "Gestionnaire DNS                 — Changer DNS Cloudflare/Google"
            "Menu Depannage Reseau            — DNS, ARP, TCP/IP, interfaces"
            "Scanner de failles et Pentest    — Vulnerabilites Web et Reseau"
            "--- ────────────────── DISQUE ──────────────────────────────"
            "Gestionnaire de Disque           — Formater, monter, fsck, bench"
            "--- ────────────────── APPLICATIONS ────────────────────────"
            "Mises a jour d applications      — apt, snap, flatpak, pip"
            "Installateur d applications      — Chrome, VLC, Office, zsh..."
            "--- ────────────────── COMPTES ET SECURITE ─────────────────"
            "Extracteurs de mots de passe     — Credentials, Wi-Fi"
            "Recuperation de Compte bloque    — Instructions reprendre controle"
            "Gestion utilisateurs locaux      — Admin, Pass, Ajouts"
            "Test Antivirus                   — Scanner ClamAV + Test EICAR"
            "--- ────────────────── EXTRACTION ET SAUVEGARDE ─────────────"
            "Recuperation de Donnees          — Cles, Wi-Fi, pilotes, historiques"
            "--- ────────────────── PERSONNALISATION ────────────────────"
            "Menu Contextuel                  — Scripts clic-droit Nautilus"
            "Dossier God Mode                 — Raccourci ultime des parametres"
            "Mode Gaming                      — Booster les perfs jeux"
            "Raccourcis Bureau 1-Clic         — Redemarrer / Eteindre / Veille"
            "Visionneuse d Images             — Changer visionneuse par defaut"
            "Lister et Rechercher             — Arborescence et recherche"
            "--- ────────────────── MATERIEL ────────────────────────────"
            "Gestionnaire Ecran Tactile       — Activer / Desactiver (xinput)"
            "Gestionnaire d Imprimantes       — CUPS / lpstat / file attente"
            "Gestionnaire Plan d Alimentation — Equilibre / Performances"
            "--- ──────────────────────────────────────────────────────────"
            "    Quitter"
        )
        AutoMenu "MAIN"
        case $MENU_CHOICE in
            1)  sys_diagnostic_menu ;;
            3)  sys_rescue_menu ;;
            4)  sys_repair_icons ;;
            5)  sys_winre ;;
            7)  sys_opti_menu ;;
            9)  dns_manager ;;
            10) sys_network_menu ;;
            11) net_cyber_menu ;;
            13) disk_manager ;;
            15) winget_manager ;;
            16) app_installer ;;
            18) sys_passwords_menu ;;
            19) sys_unlock_notes ;;
            20) um_menu ;;
            21) sys_av_test ;;
            23) sys_export_menu ;;
            25) context_menu ;;
            26) sys_god_mode ;;
            27) sys_gaming_mode ;;
            28) sys_shortcuts_bureau ;;
            29) photo_viewer_toggle ;;
            30) list_folder_menu ;;
            32) touch_screen_manager ;;
            33) sys_print_manager ;;
            34) sys_power_plan ;;
            36) clear; echo -e "${CYN}Au revoir !${NC}"; exit 0 ;;
            *)  clear; echo -e "${CYN}Au revoir !${NC}"; exit 0 ;;
        esac
    done
}

# ================================================================
#  ENTRYPOINT
# ================================================================
menu_principal
