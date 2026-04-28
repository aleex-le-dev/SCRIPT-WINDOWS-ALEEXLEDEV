#!/usr/bin/env bash
# =============================================================================
#   Boite a Scripts Linux - By ALEEXLEDEV  v1.0
# =============================================================================

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
FAV_FILE="$SCRIPT_DIR/favoris_linux.txt"
SHOW_LOGO=1
_MENU_RET=0
AUTOMENU_TARGET=""

# =============================================================================
#  COULEURS
# =============================================================================
C=$'\033[36m' W=$'\033[97m' DG=$'\033[90m'
G=$'\033[32m' R=$'\033[31m' Y=$'\033[33m' N=$'\033[0m'

# =============================================================================
#  ELEVATION SUDO
# =============================================================================
if [[ $EUID -ne 0 ]]; then
    clear
    printf '%s\n' \
        "  ▄▄▄▄▄▄▄ ▄▄       ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄    ▄▄       ▄▄▄▄▄▄▄    ▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ " \
        " █       █  █     █       █       █  █ █  █  █  █     █       █  █      ██       █  █ █  █" \
        " █   ▄   █  █     █    ▄▄▄█    ▄▄▄█  █▄█  █  █  █     █    ▄▄▄█  █  ▄    █    ▄▄▄█  █▄█  █" \
        " █  █▄█  █  █     █   █▄▄▄█   █▄▄▄█       █  █  █     █   █▄▄▄   █ █ █   █   █▄▄▄█       █" \
        " █       █  █▄▄▄▄▄█    ▄▄▄█    ▄▄▄█       █  █  █▄▄▄▄▄█    ▄▄▄█  █ █▄█   █    ▄▄▄█       █" \
        " █   ▄   █       █   █▄▄▄█   █▄▄▄█   ▄   █  █       █   █▄▄▄   █       █   █▄▄▄█   ▄   █" \
        " █▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█  █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█  █▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█" \
        ""
    echo "[ ! ] Elevation des privileges requise..."
    exec sudo bash "$SCRIPT_PATH" "$@"
fi

printf '\033]0;Boite a Scripts Linux - By ALEEXLEDEV (v1.0)\007'
printf '\033[8;60;120t' 2>/dev/null || true

# =============================================================================
#  LOGO
# =============================================================================
print_logo() {
    printf '%s\n' \
        "  ▄▄▄▄▄▄▄ ▄▄       ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄    ▄▄       ▄▄▄▄▄▄▄    ▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ " \
        " █       █  █     █       █       █  █ █  █  █  █     █       █  █      ██       █  █ █  █" \
        " █   ▄   █  █     █    ▄▄▄█    ▄▄▄█  █▄█  █  █  █     █    ▄▄▄█  █  ▄    █    ▄▄▄█  █▄█  █" \
        " █  █▄█  █  █     █   █▄▄▄█   █▄▄▄█       █  █  █     █   █▄▄▄   █ █ █   █   █▄▄▄█       █" \
        " █       █  █▄▄▄▄▄█    ▄▄▄█    ▄▄▄█       █  █  █▄▄▄▄▄█    ▄▄▄§  █ █▄█   █    ▄▄▄█       █" \
        " █   ▄   █       █   █▄▄▄█   █▄▄▄█   ▄   █  █       █   █▄▄▄   █       █   █▄▄▄█   ▄   █" \
        " █▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█  █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█  █▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█" \
        ""
}

# =============================================================================
#  DICTIONNAIRE D'OUTILS  t[N]
#  Format outil   : t[N]="label:Titre~Description"
#  Format entete  : t[N]="---:NOM CATEGORIE"
#  Sous-menu cache: t[N]="label:Titre~Description:HIDDEN"
# =============================================================================
declare -A t
declare -A map_label

# --- DIAGNOSTIC ---
t[1]="---:DIAGNOSTIC"
t[2]="sys_diagnostic_menu:Analyse et Diagnostic Systeme~Regroupe les outils d'analyse (Systeme, Reseau...)"

# --- REPARATION ---
t[3]="---:REPARATION"
t[4]="sys_rescue_menu:Outils de Reparation Linux~Menu multi-outils (fsck, dpkg, grub, systemd)"

# --- NETTOYAGE ET OPTIMISATION ---
t[5]="---:NETTOYAGE ET OPTIMISATION"
t[6]="sys_opti_menu:Nettoyeur et Optimiseur Systeme~Vider le cache, logs, et gagner en vitesse"

# --- RESEAU ---
t[7]="---:RESEAU"
t[8]="dns_manager:Gestionnaire DNS~Changer DNS Cloudflare / Google"
t[9]="sys_network_menu:Menu de Depannage Reseau~Outils avances (DNS, ARP, interfaces, IP)"
t[10]="net_cyber_menu:Scanner de Failles et Pentest~Recherche de vulnerabilites Web et Reseau"

# --- DISQUE ---
t[11]="---:DISQUE"
t[12]="disk_manager:Gestionnaire de Disques~lsblk, partitions, espace, formatage"

# --- APPLICATIONS ---
t[13]="---:APPLICATIONS"
t[14]="pkg_manager:Mises a Jour Applications~Mettre a jour les paquets installes"
t[15]="app_installer:Installateur d'Applications~Installer des logiciels par categorie"

# --- COMPTES ET SECURITE ---
t[16]="---:COMPTES ET SECURITE"
t[17]="sys_passwords_menu:Outils de Securite~SSH, historique, ports, tentatives de connexion"
t[18]="um_menu:Gestion Utilisateurs Locaux~Panneau de gestion (Admin, Pass, Ajouts)"
t[19]="sys_av_test:Test Antivirus (EICAR Safe)~Tester votre antivirus ClamAV"

# --- EXTRACTION ET SAUVEGARDE ---
t[20]="---:EXTRACTION ET SAUVEGARDE"
t[21]="sys_export_menu:Recuperation et Sauvegarde~Exporter les configs, paquets et cles SSH"

# --- PERSONNALISATION ---
t[22]="---:PERSONNALISATION"
t[23]="sys_aliases:Gestionnaire d'Alias~Creer et gerer les alias bash"
t[24]="sys_bashrc:Editer .bashrc~Modifier les parametres du shell"
t[25]="sys_hostname:Changer le Hostname~Nom de la machine (hostnamectl)"
t[26]="sys_cron:Gestionnaire Cron~Lister et editer les taches planifiees"

# --- MATERIEL ---
t[27]="---:MATERIEL"
t[28]="hw_manager:Tests des Composants PC~CPU, RAM, disques, rapport materiel complet"
t[29]="touch_screen_manager:Gestionnaire Ecran Tactile~Activer / Desactiver (xinput)"
t[30]="sys_power_plan:Gestionnaire d'Alimentation~Profils energetiques (cpupower / TLP)"

t[4]="sys_temp_report:Rapport de Temperatures~Capteurs CPU/GPU (lm-sensors):HIDDEN"
t[5]="sys_ram_info:Informations Memoire RAM~Analyse des barrettes et utilisation:HIDDEN"
t[6]="sys_net_diag:Diagnostic Reseau~Ping, traceroute, ports:HIDDEN"
t[7]="sys_battery_report:Rapport Batterie~Charge et sante batterie (upower):HIDDEN"
t[8]="sys_top_processes:Processus Actifs~Top 25 par CPU et RAM:HIDDEN"
t[9]="sys_journal_errors:Journal des Erreurs~Evenements critiques journald:HIDDEN"
t[10]="sys_uptime_load:Uptime et Charge~Temps de fonctionnement et load average:HIDDEN"
t[11]="ev_critical_24h:Erreurs Critiques 24h~Evenements systeme recents:HIDDEN"
t[12]="ev_critical_7d:Erreurs Critiques 7 Jours~Historique des erreurs:HIDDEN"
t[13]="ev_kernel_warn:Alertes Kernel~Avertissements dmesg:HIDDEN"
t[14]="ev_disk_warn:Alertes Disque~Erreurs I/O et SMART:HIDDEN"

# --- REPARATION ---
t[15]="---:REPARATION"
t[16]="sys_rescue_menu:Outils de Reparation Linux~Menu multi-outils (fsck, dpkg, grub, systemd)"
t[17]="res_fsck:Verifier les Systemes de Fichiers~Programmer fsck au prochain boot:HIDDEN"
t[18]="res_dpkg_fix:Reparer les Paquets~dpkg --configure -a:HIDDEN"
t[19]="res_apt_fix:Corriger les Dependances~apt --fix-broken install:HIDDEN"
t[20]="res_systemd_failed:Services en Echec~Lister et relancer les services:HIDDEN"
t[21]="res_journal_clean:Nettoyer les Journaux~journalctl --vacuum-time=7d:HIDDEN"
t[22]="res_grub_update:Mettre a Jour GRUB~Regenerer la configuration GRUB:HIDDEN"
t[23]="res_initrd_update:Regenerer initramfs~update-initramfs -u:HIDDEN"
t[24]="res_restore_point:Creer une Sauvegarde~Snapshot home avant reparation:HIDDEN"

# --- NETTOYAGE ET OPTIMISATION ---
t[25]="---:NETTOYAGE ET OPTIMISATION"
t[26]="sys_opti_menu:Nettoyeur et Optimiseur Systeme~Vider le cache, logs, et gagner en vitesse"
t[27]="cl_apt_cache:Vider le Cache APT~apt clean et autoclean:HIDDEN"
t[28]="cl_apt_autoremove:Supprimer Paquets Inutiles~apt autoremove:HIDDEN"
t[29]="cl_temp:Vider les Temporaires~Fichiers /tmp et ~/.cache:HIDDEN"
t[30]="cl_journal:Vider les Journaux~Journaux systemd > 7 jours:HIDDEN"
t[31]="cl_trash:Vider la Corbeille~Supprime ~/.local/share/Trash:HIDDEN"
t[32]="cl_thumbnails:Vider le Cache Miniatures~Regeneration des aperçus:HIDDEN"
t[33]="cl_dns:Vider le Cache DNS~systemd-resolve --flush-caches:HIDDEN"
t[34]="cl_all:Tout Nettoyer d'un Coup~Nettoyage automatique complet:HIDDEN"
t[35]="sys_startup_manager:Gestionnaire Demarrage~Services actives au boot (systemd):HIDDEN"

# --- RESEAU ---
t[36]="---:RESEAU"
t[37]="dns_manager:Gestionnaire DNS~Changer DNS Cloudflare / Google"
t[38]="sys_network_menu:Menu de Depannage Reseau~Outils avances (DNS, ARP, interfaces, IP)"
t[39]="net_cyber_menu:Scanner de Failles et Pentest~Recherche de vulnerabilites Web et Reseau"
t[40]="show_dns_config:Affichage Config DNS~Voir la configuration DNS actuelle:HIDDEN"
t[41]="install_cloudflare_full:DNS Cloudflare~1.1.1.1 et 1.0.0.1:HIDDEN"
t[42]="install_google_full:DNS Google~8.8.8.8 et 8.8.4.4:HIDDEN"
t[43]="restore_dns:Restauration DNS DHCP~Par defaut automatique:HIDDEN"
t[44]="net_flush_dns:Vider le Cache DNS~Forcer la resolution des noms:HIDDEN"
t[45]="net_display_arp:Afficher la Table ARP~ip neigh show:HIDDEN"
t[46]="net_clear_arp:Vider la Table ARP~ip neigh flush all:HIDDEN"
t[47]="net_renew_ip:Renouveler l'Adresse IP~dhclient release et renew:HIDDEN"
t[48]="net_restart_adapters:Redemarrer les Interfaces~ip link down et up:HIDDEN"
t[49]="net_reset_all:Reset Reseau Complet~Flush DNS, ARP, renouveler IP:HIDDEN"
t[50]="net_fast_reset:Script d'Urgence Reseau~Enchaine les reparations rapides:HIDDEN"
t[51]="net_menu_wifi:Wi-Fi - Outils~Scan, audit et analyse des reseaux Wi-Fi:HIDDEN"
t[52]="net_menu_interne:Reseau Interne - Connecte~Scanner LAN, flux, DNS, diagnostic local:HIDDEN"
t[53]="net_menu_distant:Reseau Distant~Scanner cible WAN, analyse:HIDDEN"
t[54]="net_wifi_scan:Scan Reseaux Wi-Fi~SSID, BSSID, signal, securite:HIDDEN"
t[55]="cyber_triage:Triage de Connectivite~Diagnostic rapide IP, Gateway et DNS:HIDDEN"
t[56]="cyber_adapter_audit:Audit des Interfaces Reseau~MAC, MTU, statut:HIDDEN"
t[57]="cyber_lan_auto:Scanner le Reseau Local (LAN)~Detecte les appareils connectes:HIDDEN"
t[58]="cyber_flux_analysis:Analyse des Flux Reseau~Ports ouverts et connexions actives:HIDDEN"
t[59]="cyber_dns_leak:Test de Fuite DNS~Verifier l'anonymat DNS avec VPN:HIDDEN"
t[60]="cyber_ip_grabber:Scanner une Cible Distante~whois, dig, nmap sur IP/domaine:HIDDEN"

# --- DISQUE ---
t[61]="---:DISQUE"
t[62]="disk_manager:Gestionnaire de Disques~lsblk, partitions, espace, formatage"
t[63]="disk_info:Infos Disques~Partitions, taille, systeme de fichiers:HIDDEN"
t[64]="disk_usage:Analyse Utilisation~Dossiers les plus lourds (du):HIDDEN"
t[65]="disk_benchmark:Benchmark Disque~Vitesse lecture / ecriture (dd):HIDDEN"

# --- APPLICATIONS ---
t[66]="---:APPLICATIONS"
t[67]="pkg_manager:Mises a Jour Applications~Mettre a jour les paquets installes"
t[68]="app_installer:Installateur d'Applications~Installer des logiciels par categorie"
t[69]="update_single:Installer un Paquet~Rechercher et installer via apt/dnf:HIDDEN"
t[70]="update_all:Mettre a Jour Tout~Upgrade complet du systeme:HIDDEN"
t[71]="app_install_chrome:Google Chrome~Navigateur web Google:HIDDEN"
t[72]="app_install_vlc:VLC Media Player~Lecteur multimedia:HIDDEN"
t[73]="app_install_vscode:VS Code~Editeur de code Microsoft:HIDDEN"
t[74]="app_install_git:Git~Gestionnaire de versions:HIDDEN"
t[75]="app_install_nmap:Nmap~Scanner de ports et reseau:HIDDEN"
t[76]="app_install_htop:htop~Moniteur systeme interactif:HIDDEN"
t[77]="app_list_installed:Lister les Paquets~Afficher les paquets installes:HIDDEN"

# --- COMPTES ET SECURITE ---
t[78]="---:COMPTES ET SECURITE"
t[79]="sys_passwords_menu:Outils de Securite~SSH, historique, ports, tentatives de connexion"
t[80]="um_menu:Gestion Utilisateurs Locaux~Panneau de gestion (Admin, Pass, Ajouts)"
t[81]="sys_av_test:Test Antivirus (EICAR Safe)~Tester votre antivirus ClamAV"
t[82]="sys_sudoers:Gestion Sudoers~Droits sudo des utilisateurs:HIDDEN"
t[83]="dump_ssh_keys:Cles SSH~Afficher les cles SSH presentes:HIDDEN"
t[84]="sys_login_history:Historique Connexions~Derniers logins du systeme:HIDDEN"
t[85]="sys_open_ports:Ports Ouverts~Services en ecoute (ss -tlnp):HIDDEN"
t[86]="sys_failed_logins:Tentatives Echouees~Echecs d'authentification (journald):HIDDEN"
t[87]="um_list:Lister les Utilisateurs~Afficher tous les comptes locaux:HIDDEN"
t[88]="um_add:Ajouter un Utilisateur~Creer un nouveau compte local:HIDDEN"
t[89]="um_del:Supprimer un Utilisateur~Effacer compte et donnees:HIDDEN"
t[90]="um_admin:Gerer les Droits~Standard ou Administrateur (groupe sudo):HIDDEN"
t[91]="um_passwd:Changer le Mot de Passe~Modifier le MDP d'un utilisateur:HIDDEN"
t[92]="um_lock:Verrouiller / Deverrouiller~Bloquer ou debloquer un compte:HIDDEN"

# --- EXTRACTION ET SAUVEGARDE ---
t[93]="---:EXTRACTION ET SAUVEGARDE"
t[94]="sys_export_menu:Recuperation et Sauvegarde~Exporter les configs, paquets et cles SSH"
t[95]="sys_export_pkgs:Liste des Logiciels~Exporter les paquets installes:HIDDEN"
t[96]="sys_backup_home:Sauvegarde Home~Archive compressee du dossier personnel:HIDDEN"
t[97]="sys_export_cron:Export des Crons~Sauvegarder les taches planifiees:HIDDEN"
t[98]="sys_export_ssh:Export Cles SSH~Copier les cles publiques:HIDDEN"
t[99]="sys_loot_all:Extraction Locale~Dump configs, SSH, historique shell:HIDDEN"

# --- PERSONNALISATION ---
t[100]="---:PERSONNALISATION"
t[101]="sys_aliases:Gestionnaire d'Alias~Creer et gerer les alias bash"
t[102]="sys_bashrc:Editer .bashrc~Modifier les parametres du shell"
t[103]="sys_hostname:Changer le Hostname~Nom de la machine (hostnamectl)"
t[104]="sys_cron:Gestionnaire Cron~Lister et editer les taches planifiees"
t[105]="sys_timezone:Changer le Fuseau Horaire~timedatectl set-timezone:HIDDEN"
t[106]="sys_keyboard:Disposition Clavier~dpkg-reconfigure keyboard-configuration:HIDDEN"
t[107]="sys_motd:Personnaliser le MOTD~Message d'accueil du terminal:HIDDEN"

# --- MATERIEL ---
t[108]="---:MATERIEL"
t[109]="hw_manager:Tests des Composants PC~CPU, RAM, disques, rapport materiel complet"
t[110]="touch_screen_manager:Gestionnaire Ecran Tactile~Activer / Desactiver (xinput)"
t[111]="sys_power_plan:Gestionnaire d'Alimentation~Profils energetiques (cpupower / TLP)"
t[112]="hw_cpu_test:Test CPU (stress)~Stress test du processeur:HIDDEN"
t[113]="hw_ram_test:Test RAM (memtester)~Analyse de la memoire vive:HIDDEN"
t[114]="hw_smart:Test SMART Disques~Sante et duree de vie (smartctl):HIDDEN"
t[115]="hw_full_report:Rapport Materiel Complet~inxi / lshw - tous les composants:HIDDEN"
t[116]="hw_all:Tous les Tests~Lancer tous les tests materiels:HIDDEN"
t[117]="pp_balanced:Profil Equilibre~Usage quotidien (ondemand):HIDDEN"
t[118]="pp_performance:Profil Hautes Performances~Maximum de puissance (performance):HIDDEN"
t[119]="pp_saver:Profil Economies d'Energie~Autonomie maximale (powersave):HIDDEN"
t[120]="pp_current:Voir le Profil Actuel~Afficher le gouverneur CPU en cours:HIDDEN"

# Auto-calcul du nombre d'outils
total_tools=0
for (( _i=1; _i<=500; _i++ )); do
    [[ -v "t[$_i]" ]] && total_tools=$_i
done
unset _i

# =============================================================================
#  FAVORIS
# =============================================================================
declare -A fav_cache

reload_fav_cache() {
    for _k in "${!fav_cache[@]}"; do unset "fav_cache[$_k]"; done
    touch "$FAV_FILE" 2>/dev/null || true
    while IFS= read -r _line; do
        [[ -n "$_line" ]] && fav_cache["$_line"]=1
    done < "$FAV_FILE"
}

toggle_fav() {
    local target="$1" tmp="${FAV_FILE}.tmp"
    touch "$FAV_FILE" 2>/dev/null || true
    if grep -qxF "$target" "$FAV_FILE" 2>/dev/null; then
        grep -vxF "$target" "$FAV_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$FAV_FILE"
    else
        echo "$target" >> "$FAV_FILE"
    fi
}

# =============================================================================
#  HELPERS
# =============================================================================
_call_target() {
    local target="$1"
    if declare -f "$target" > /dev/null 2>&1; then
        "$target"
    else
        printf "\n${DG}   [ ! ] Script '%s' non encore implemente.${N}\n" "$target"
        sleep 1
    fi
}

# =============================================================================
#  MOTEUR DE MENU DYNAMIQUE
# =============================================================================
dynamic_menu() {
    local title="$1" opts_str="$2" flags="${3:-}"
    local -a opts; IFS=';' read -ra opts <<< "$opts_str"
    local -a sel=(); local _i
    for _i in "${!opts[@]}"; do
        [[ "${opts[$_i]}" != \[---* ]] && sel+=("$_i")
    done
    local sel_count=${#sel[@]}
    if [[ $sel_count -eq 0 ]]; then _MENU_RET=0; return; fi

    local idx=0 top_i=0
    [[ "$flags" != *NOCLS* ]] && clear

    while true; do
        local cols lines_total
        cols=$(tput cols 2>/dev/null || echo 120)
        lines_total=$(tput lines 2>/dev/null || echo 40)
        local pad=$(( cols - 4 ))
        (( pad < 60 )) && pad=60; (( pad > 116 )) && pad=116
        local max_v=$(( lines_total - 8 ))
        [[ $SHOW_LOGO -eq 1 ]] && max_v=$(( max_v - 9 ))
        (( max_v < 5 )) && max_v=5

        local cur="${sel[$idx]}"
        (( cur < top_i )) && top_i=$cur
        local lines_to_cur=0
        for _i in "${!opts[@]}"; do
            (( _i < top_i )) && continue; (( _i > cur )) && break
            if [[ "${opts[$_i]}" == \[---* ]]; then (( lines_to_cur += 2 ))
            else (( lines_to_cur += 1 )); fi
        done
        while (( lines_to_cur > max_v )); do
            if [[ "${opts[$top_i]}" == \[---* ]]; then (( lines_to_cur -= 2 ))
            else (( lines_to_cur -= 1 )); fi
            (( top_i++ ))
        done

        if [[ "$flags" != *NOCLS* ]]; then
            tput cup 0 0 2>/dev/null || printf '\033[H'
        fi
        [[ $SHOW_LOGO -eq 1 ]] && print_logo

        local sep; sep=$(printf '%0.s=' $(seq 1 $(( pad + 4 ))))
        local sep2; sep2=$(printf '%0.s-' $(seq 1 $(( pad + 4 ))))
        printf "${C}  %s${N}\n" "$sep"
        printf "${W}   %s${N}\n" "$title"
        printf "${C}  %s${N}\n" "$sep"

        local num=1 printed=0
        for _i in "${!opts[@]}"; do
            local item="${opts[$_i]}" isheader=0
            [[ "$item" == \[---* ]] && isheader=1
            local cur_num=0
            if [[ $isheader -eq 0 ]]; then cur_num=$num; (( num++ )); fi
            (( _i < top_i )) && continue; (( printed >= max_v )) && continue
            if [[ $isheader -eq 1 ]]; then
                printf "\n"; printf "${C}       %-*s${N}\n" "$pad" "$item"
                (( printed += 2 ))
            else
                local raw_name raw_desc
                raw_name="${item%%~*}"; raw_desc="${item#*~}"
                [[ "$raw_desc" == "$raw_name" ]] && raw_desc=""
                raw_name="${raw_name#(F) }"
                local name_t="${raw_name:0:28}"
                local desc_w=$(( pad - 38 )); (( desc_w < 0 )) && desc_w=0
                local desc_t="${raw_desc:0:$desc_w}"
                if [[ "$_i" -eq "$cur" ]]; then
                    printf "\033[30;47m    >> [%-2s] %-28s  \033[33;47m%-*s\033[0m\n" \
                        "$cur_num" "$name_t" "$desc_w" "${desc_t:+- $desc_t}"
                else
                    printf "${DG}       [%-2s] %-28s  %-*s${N}\n" \
                        "$cur_num" "$name_t" "$desc_w" "${desc_t:+- $desc_t}"
                fi
                (( printed++ ))
            fi
        done
        while (( printed < max_v )); do printf "%*s\n" $(( pad + 4 )) ""; (( printed++ )); done
        printf "${C}  %s${N}\n" "$sep2"
        if [[ "$flags" == *NONUMS* ]]; then
            printf "${DG}   [FLECHES] Naviguer | [ENTREE] Valider | [ECHAP] Retour${N}\n"
        else
            printf "${DG}   [FLECHES] Naviguer | [ENTREE] Valider | [F] Favoriser | [S] Rechercher | [0/ECHAP] Retour${N}\n"
        fi

        local k seq
        IFS= read -rsn1 k 2>/dev/null
        if [[ "$k" == $'\x1b' ]]; then
            IFS= read -rsn2 -t 0.15 seq 2>/dev/null || seq=""; k="$k$seq"
        fi
        case "$k" in
            $'\x1b[A') (( idx-- )); (( idx < 0 )) && idx=$(( sel_count - 1 )) ;;
            $'\x1b[B') (( idx++ )); (( idx >= sel_count )) && idx=0 ;;
            ''|$'\n'|$'\r') [[ "$flags" != *NOCLS* ]] && clear; _MENU_RET=$(( idx + 1 )); return ;;
            $'\x1b')   [[ "$flags" != *NOCLS* ]] && clear; _MENU_RET=0; return ;;
            '0') if [[ "$flags" != *NONUMS* ]]; then
                    [[ "$flags" != *NOCLS* ]] && clear; _MENU_RET=0; return; fi ;;
            'f'|'F') if [[ "$flags" != *NONUMS* ]]; then
                    [[ "$flags" != *NOCLS* ]] && clear; _MENU_RET=$(( 200 + idx + 1 )); return; fi ;;
            's'|'S') if [[ "$flags" != *NONUMS* ]]; then
                    [[ "$flags" != *NOCLS* ]] && clear; _MENU_RET=299; return; fi ;;
            [1-9]) if [[ "$flags" != *NONUMS* ]]; then
                    local n=$(( 10#$k ))
                    if (( n <= sel_count )); then
                        [[ "$flags" != *NOCLS* ]] && clear; _MENU_RET=$n; return; fi; fi ;;
        esac
    done
}

# =============================================================================
#  AUTO MENU
# =============================================================================
auto_menu() {
    local am_title="$1" am_labels="$2" am_flags="${3:-}"
    AUTOMENU_TARGET=""
    while true; do
        reload_fav_cache
        local -a lbl_arr am_targets=(); IFS=';' read -ra lbl_arr <<< "$am_labels"
        local am_opts="" am_idx=0 lbl
        for lbl in "${lbl_arr[@]}"; do
            if [[ "$lbl" == \[---* ]]; then am_opts="$am_opts;$lbl"
            else
                (( am_idx++ )); am_targets+=("$lbl")
                local display="${map_label[$lbl]:-}"
                if [[ -z "$display" ]]; then
                    local _j
                    for (( _j=1; _j<=total_tools; _j++ )); do
                        [[ -v "t[$_j]" ]] || continue
                        if [[ "${t[$_j]%%:*}" == "$lbl" ]]; then
                            display="${t[$_j]#*:}"; display="${display%:HIDDEN}"; break
                        fi
                    done
                fi
                [[ -z "$display" ]] && display="$lbl"
                if [[ -v "fav_cache[$lbl]" ]]; then am_opts="$am_opts;(F) $display"
                else am_opts="$am_opts;$display"; fi
            fi
        done
        am_opts="${am_opts#;}"
        dynamic_menu "$am_title" "$am_opts" "$am_flags"
        local am_c=$_MENU_RET
        if [[ $am_c -eq 0 ]]; then _MENU_RET=0; AUTOMENU_TARGET=""; return; fi
        if [[ $am_c -eq 299 ]]; then search_tools; continue; fi
        if (( am_c >= 200 )); then toggle_fav "${am_targets[$(( am_c - 200 - 1 ))]}"; continue; fi
        AUTOMENU_TARGET="${am_targets[$(( am_c - 1 ))]}"; _MENU_RET=$am_c; return
    done
}

# =============================================================================
#  RECHERCHE
# =============================================================================
search_tools() {
    clear; [[ $SHOW_LOGO -eq 1 ]] && print_logo
    printf "${C}  ========================================================================================${N}\n"
    printf "${W}   RECHERCHE D'OUTILS${N}\n"
    printf "${C}  ========================================================================================${N}\n\n"
    printf "${DG}   Terme de recherche (ECHAP pour annuler) :${N}\n   > "
    local search_term=""
    while IFS= read -rsn1 ch; do
        if   [[ "$ch" == $'\x1b' ]]; then printf "\n"; return
        elif [[ "$ch" == $'\n' ]] || [[ "$ch" == $'\r' ]] || [[ -z "$ch" ]]; then break
        elif [[ "$ch" == $'\x7f' ]] || [[ "$ch" == $'\x08' ]]; then
            [[ ${#search_term} -gt 0 ]] && { search_term="${search_term%?}"; printf '\b \b'; }
        else search_term+="$ch"; printf '%s' "$ch"; fi
    done
    printf "\n"; [[ -z "$search_term" ]] && return

    local dyn_opts="" -a results; local -a results; local _i
    for (( _i=1; _i<=total_tools; _i++ )); do
        [[ -v "t[$_i]" ]] || continue
        local entry="${t[$_i]}"; local label="${entry%%:*}"
        [[ "$label" == "---" ]] && continue
        local rest="${entry#*:}"; rest="${rest%:HIDDEN}"
        local name="${rest%%~*}"; local desc="${rest#*~}"; [[ "$desc" == "$name" ]] && desc=""
        if echo "${name} ${desc}" | grep -qi "$search_term" 2>/dev/null; then
            local disp="$name~$desc"
            [[ -v "fav_cache[$label]" ]] && disp="(F) $disp"
            dyn_opts="$dyn_opts;$disp"; results+=("$label")
        fi
    done
    dyn_opts="${dyn_opts#;}"
    if [[ -z "$dyn_opts" ]]; then
        printf "\n${DG}   Aucun outil trouve pour \"%s\"${N}\n" "$search_term"; sleep 1.5; return
    fi
    dynamic_menu "RESULTATS: $search_term" "$dyn_opts" "NOCLS"
    local choice=$_MENU_RET; [[ $choice -eq 0 ]] && return
    if (( choice >= 200 )); then
        toggle_fav "${results[$(( choice - 200 - 1 ))]}"; reload_fav_cache; return
    fi
    _call_target "${results[$(( choice - 1 ))]}"
}

# =============================================================================
#  OUTILS SYSTEME
# =============================================================================
system_tools() {
    while true; do
        reload_fav_cache
        local opts="" -a st_targets; local -a st_targets; local st_idx=0 _i
        for (( _i=1; _i<=total_tools; _i++ )); do
            [[ -v "t[$_i]" ]] || continue
            local entry="${t[$_i]}"; local label="${entry%%:*}"; local rest="${entry#*:}"
            if [[ "$label" == "---" ]]; then opts="$opts;[--- ${rest} ---]"; continue; fi
            [[ "$rest" == *:HIDDEN ]] && continue
            local name="${rest%%~*}"; local desc="${rest#*~}"; [[ "$desc" == "$name" ]] && desc=""
            (( st_idx++ )); st_targets+=("$label")
            if [[ -v "fav_cache[$label]" ]]; then opts="$opts;(F) $name~$desc"
            else opts="$opts;$name~$desc"; fi
        done
        opts="${opts#;}"
        dynamic_menu "OUTILS SYSTEME AVANCES" "$opts"
        local choice=$_MENU_RET; [[ $choice -eq 0 ]] && return
        if [[ $choice -eq 299 ]]; then search_tools; continue; fi
        if (( choice >= 200 )); then
            toggle_fav "${st_targets[$(( choice - 200 - 1 ))]}"; reload_fav_cache; continue
        fi
        _call_target "${st_targets[$(( choice - 1 ))]}"
    done
}

# =============================================================================
#  MENU PRINCIPAL
# =============================================================================
main_menu() {
    while true; do
        reload_fav_cache
        local opts="[--- MES FAVORIS ---]" fav_idx=0; local -a main_targets=(); local _i
        for (( _i=1; _i<=total_tools; _i++ )); do
            [[ -v "t[$_i]" ]] || continue
            local entry="${t[$_i]}"; local label="${entry%%:*}"
            [[ "$label" == "---" ]] && continue
            if [[ -v "fav_cache[$label]" ]]; then
                (( fav_idx++ ))
                local rest="${entry#*:}"; rest="${rest%:HIDDEN}"
                local name="${rest%%~*}"; local desc="${rest#*~}"; [[ "$desc" == "$name" ]] && desc=""
                opts="$opts;(F) $name~$desc"; main_targets+=("$label")
            fi
        done
        if [[ $fav_idx -eq 0 ]]; then system_tools; exit_script; return; fi
        opts="$opts;[--- OUTILS AVANCES ---];Voir les outils systeme avances~Acces a tous les outils"
        dynamic_menu "BOITE A SCRIPTS LINUX - By ALEEXLEDEV" "$opts"
        local choice=$_MENU_RET
        [[ $choice -eq 0 ]] && exit_script
        if [[ $choice -eq 299 ]]; then search_tools; continue; fi
        if (( choice >= 200 )); then
            toggle_fav "${main_targets[$(( choice - 200 - 1 ))]}"; reload_fav_cache; continue
        fi
        local see_all=$(( fav_idx + 1 ))
        if [[ $choice -eq $see_all ]]; then system_tools; continue; fi
        _call_target "${main_targets[$(( choice - 1 ))]}"
    done
}

# =============================================================================
#  QUITTER
# =============================================================================
exit_script() {
    clear
    printf "\n${C}  =====================================================${N}\n"
    printf "${W}      MERCI D'AVOIR UTILISE CET OUTIL !${N}\n"
    printf "${C}  =====================================================${N}\n\n"
    printf "${DG}  Developpe par ALEEXLEDEV${N}\n\n"
    printf "${DG}  Appuyez sur une touche pour quitter...${N}\n"
    read -rsn1; exit 0
}

# =============================================================================
#  MENUS DE NAVIGATION PAR CATEGORIE
#  (les scripts individuels seront ajoutes ici au fur et a mesure)
# =============================================================================

# --- DIAGNOSTIC ---
sys_diagnostic_menu() {
    while true; do
        auto_menu "ANALYSE ET DIAGNOSTIC SYSTEME" \
            "[--- ANALYSE SYSTEME ET RAPPORTS ---];sys_info;sys_temp_report;sys_ram_info;sys_net_diag;sys_battery_report;sys_uptime_load;[--- PROCESSUS ---];sys_top_processes;[--- JOURNAUX ---];sys_journal_errors;ev_critical_24h;ev_critical_7d;ev_kernel_warn;ev_disk_warn"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- REPARATION ---
sys_rescue_menu() {
    while true; do
        auto_menu "OUTILS DE REPARATION LINUX" \
            "res_restore_point;[--- PAQUETS ---];res_dpkg_fix;res_apt_fix;[--- SYSTEME ---];res_fsck;res_systemd_failed;res_grub_update;res_initrd_update;[--- NETTOYAGE ---];res_journal_clean"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- NETTOYAGE ET OPTIMISATION ---
sys_opti_menu() {
    while true; do
        auto_menu "NETTOYEUR ET OPTIMISEUR SYSTEME" \
            "cl_all;[--- PAQUETS ---];cl_apt_cache;cl_apt_autoremove;[--- FICHIERS ---];cl_temp;cl_trash;cl_thumbnails;[--- SYSTEME ---];cl_journal;cl_dns;sys_startup_manager"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- RESEAU : DNS ---
dns_manager() {
    while true; do
        auto_menu "GESTIONNAIRE DNS" \
            "show_dns_config;[--- CLOUDFLARE ---];install_cloudflare_full;[--- GOOGLE ---];install_google_full;[--- REINITIALISATION ---];restore_dns"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- RESEAU : DEPANNAGE ---
sys_network_menu() {
    while true; do
        auto_menu "MENU DE DEPANNAGE RESEAU" \
            "net_flush_dns;net_display_arp;net_clear_arp;net_renew_ip;net_restart_adapters;net_reset_all;net_fast_reset"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- RESEAU : PENTEST ---
net_cyber_menu() {
    while true; do
        auto_menu "CYBERSECURITE RESEAU" "net_menu_wifi;net_menu_interne;net_menu_distant"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

net_menu_wifi() {
    while true; do
        auto_menu "WI-FI - OUTILS" "net_wifi_scan"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

net_menu_interne() {
    while true; do
        auto_menu "RESEAU INTERNE - CONNECTE" \
            "cyber_triage;cyber_adapter_audit;cyber_lan_auto;cyber_flux_analysis;cyber_dns_leak"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

net_menu_distant() {
    while true; do
        auto_menu "RESEAU DISTANT" "cyber_triage;cyber_ip_grabber"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- DISQUE ---
disk_manager() {
    while true; do
        auto_menu "GESTIONNAIRE DE DISQUES" "disk_info;disk_usage;hw_smart;disk_benchmark"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- APPLICATIONS ---
pkg_manager() {
    while true; do
        auto_menu "MISES A JOUR APPLICATIONS" "update_all;update_single;app_list_installed"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

app_installer() {
    while true; do
        auto_menu "INSTALLATEUR D'APPLICATIONS" \
            "[--- NAVIGATEURS ---];app_install_chrome;[--- MULTIMEDIA ---];app_install_vlc;[--- DEVELOPPEMENT ---];app_install_vscode;app_install_git;[--- RESEAU ---];app_install_nmap;[--- SYSTEME ---];app_install_htop"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- COMPTES ET SECURITE ---
sys_passwords_menu() {
    while true; do
        auto_menu "OUTILS DE SECURITE" \
            "[--- AUDIT ---];sys_sudoers;dump_ssh_keys;sys_login_history;sys_failed_logins;[--- RESEAU ---];sys_open_ports"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

um_menu() {
    while true; do
        auto_menu "GESTION UTILISATEURS LOCAUX" "um_list;um_add;um_del;um_admin;um_passwd;um_lock"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- EXTRACTION ET SAUVEGARDE ---
sys_export_menu() {
    while true; do
        auto_menu "SAUVEGARDE ET EXPORT" \
            "[--- INFORMATIONS ---];sys_export_pkgs;sys_export_cron;sys_export_ssh;[--- SAUVEGARDE ---];sys_backup_home;sys_loot_all"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# --- MATERIEL ---
hw_manager() {
    while true; do
        auto_menu "TESTS DES COMPOSANTS PC" \
            "hw_all;[--- TESTS ---];hw_cpu_test;hw_ram_test;hw_smart;[--- RAPPORTS ---];hw_full_report"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

sys_power_plan() {
    while true; do
        auto_menu "GESTIONNAIRE D'ALIMENTATION" "pp_balanced;pp_performance;pp_saver;pp_current"
        [[ $_MENU_RET -eq 0 ]] && return
        _call_target "$AUTOMENU_TARGET"
    done
}

# =============================================================================
#  INITIALISATION
# =============================================================================
touch "$FAV_FILE" 2>/dev/null || true

clear; [[ $SHOW_LOGO -eq 1 ]] && print_logo
printf "${C}  ========================================================================================${N}\n"
printf "${W}              ---===[ A  L  E  E  X     L  E     D  E  V ]===---${N}\n"
printf "${C}  ========================================================================================${N}\n\n"
printf "${DG}  %-78s${N}\n" "  [+] VERSION : 1.0 LINUX EDITION        [+] BYPASS : ANTI-VIRUS LIVE"
printf "${DG}  %-78s${N}\n" "  [+] TARGET  : MULTI-NETWORK SCAN        [+] ACCESS : UNRESTRICTED"
printf "${C}  ========================================================================================${N}\n\n"
printf "${G}[ SYSTEM ]${N} Powering up framework...\n"
printf "[ MODULE ] Tool dictionary loaded  (%d entrees).\n" "$total_tools"
printf "[ MODULE ] Favorites engine active.\n\n"
printf "${DG}[ i ] Initialisation terminee. Bienvenue, ALEEXLEDEV.${N}\n"
sleep 1

# =============================================================================
#  DEMARRAGE
# =============================================================================
main_menu
