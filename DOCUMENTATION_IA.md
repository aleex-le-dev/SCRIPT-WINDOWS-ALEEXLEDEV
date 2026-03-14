# Documentation et Historique des Développements IA

*Ce fichier sert de mémoire pour toute future IA (ou développeur) qui travaillera sur le projet `Scripts-by-AleexLeDev.bat`. Il résume les axes de développement récents, les méthodes utilisées et les problèmes résolus.*

## 1. Fonctionnalités et Outils Ajoutés
*   **Recherche Globale (Global Search) :** Implémentation d'une fonction permettant à l'utilisateur de chercher un script spécifique parmi tous les outils disponibles directement depuis le menu principal.
*   **Monitoring Matériel :** 
    *   Surveillance en temps réel des températures CPU/GPU (utilisation de WMI et intégration avec des outils en ligne de commande comme OpenHardwareMonitor).
    *   Vérification de la RAM : création d'un outil analysant la RAM installée/utilisée versus la capacité maximale supportée par la carte mère (pour conseiller des upgrades).
*   **Tests Antivirus (EICAR & Heuristique) :** 
    *   Scripts permettant de simuler des détections antivirus de manière sécurisée.
    *   Mise en place de contournements pour éviter que l'antivirus ne ferme brutalement l'outil batch (interférences palliées).
    *   Nettoyage automatisé et forcé des fichiers/dossiers de test après exécution pour ne pas laisser de traces.
*   **Refonte de la Navigation :** Standardisation des menus pour inclure systématiquement l'option `0` (Retour au menu principal / Quitter) dans toutes les sous-sections.

## 2. Corrections Ciblées (Debugging)
*   **Stabilité Batch/PowerShell :** Résolution de multiples crashs liés à l'exécution de sous-processus PowerShell depuis le Batch `cmd.exe`.
*   **Gestion des Caractères Spéciaux :** Fix des erreurs de syntaxe (accents, esperluettes, etc.) qui faisaient planter l'affichage ou l'exécution du script.
*   **Mode "Réparation" Infini (Boot Loop) :** Correction d'un problème critique où l'exécution du script de réparation complet (`sys_repair`, `sfc`, `dism` etc.) bloquait le PC de l'utilisateur en mode de réparation au démarrage suivant. Des commandes ont été ajustées/retirées (ex. gestion de `SafeModeRevert`) pour redémarrer Windows normalement.
*   **Logs d'Erreurs :** Amélioration des méthodes de journalisation pour capturer et conserver les erreurs (Output/Error trapping).

## 3. Architecture et Choix Techniques
*   **Encapsulation PowerShell :** Face aux limites du MS-DOS (CMD), les scripts complexes font massivement appel à `powershell.exe -Command "..."` pour traiter des chaînes de caractères complexes, des APIs WMI et des interfaces graphiques basiques (Pop-ups, sélections).
*   **Génération de l'Interface (Menu Dynamique) :** Le script principal utilise un système de variables structurées (comme un tableau, par ex. `set "t[...] = id_script:Titre~Description"`) pour générer automatiquement l'affichage du menu.
*   **Sécurisation des Entrées (Input Validation) :** La saisie utilisateur (`set /p`) est filtrée pour éviter les plantages ou l'injection accidentelle.
*   **Gestion de l'Élévation (Run as Admin) :** La structure comprend une détection et une relance automatique avec les droits Administrateurs si les outils ou réparations le nécessitent.

## 4. Déploiement
*   **Git Integration :** Le projet est géré via Git. Les différentes versions ont été régulièrement commitées et poussées vers le repos `origin` pour garantir la sauvegarde et la publication des évolutions (via des routines `git add`, `git commit`, `git push`).

## 5. Listing Détaillé des Scripts (avec cibles d'appel)
La liste complète des outils est indexée dans les variables `t[1]` à `t[TOTAL]` et appelée par leurs "methods" correspondantes (ex. `goto sys_diagnostic_menu`).

### 🛠️ DIAGNOSTIC
*   **Menu de diagnostic** (`sys_diagnostic_menu`) : Regroupe 8 outils d'analyse (Système, Réseau, Santé...)
*   **Apercu de la configuration PC** (`sys_report`) : Affiche les spécifications et l'état de santé matériel *(Outil avancé/Caché)*
*   **Diagnostic Reseau** (`sys_diag_network`) : Test de connexion (Local, Box, Internet, DNS) *(Outil avancé/Caché)*
*   **Rapport de Batterie** (`sys_battery_report`) : Usure, Santé et statistiques en temps réel *(Outil avancé/Caché)*
*   **Verificateur BitLocker** (`sys_bitlocker_check`) : Vérifie l'état de chiffrement des partitions *(Outil avancé/Caché)*
*   **Journaux d'Erreurs Windows** (`sys_event_log`) : Affiche les erreurs critiques récentes *(Outil avancé/Caché)*
*   **Test des Composants PC** (`sys_hw_test`) : Benchmark disque, RAM, CPU et SMART *(Outil avancé/Caché)*
*   **Gestionnaire Windows Defender** (`sys_defender`) : Scans CLI, MAJ signatures *(Outil avancé/Caché)*
*   **Generer Rapport HTML Tout-en-Un** (`sys_full_report`) : Export HTML de l'ordinateur complet *(Outil avancé/Caché)*

### 🩹 REPARATION
*   **Outil Reparation Windows (Rescue)** (`sys_rescue_menu`) : Menu multi-outils (SFC, DISM, CHKDSK, Reset WinUpdate...)
*   **Reparation Cache Icones** (`sys_repair_icons`) : Corrige les icones/miniatures corrompues
*   **Mode Reparation (WinRE)** (`sys_winre`) : Démarrer dans l'environnement de réparation (BIOS/Safe Mode...)
*   **Scan RAPIDE du systeme** (`res_sfc`) : SFC /scannow *(Outil avancé/Caché)*
*   **Verification image base** (`res_dism_check`) : DISM /CheckHealth et /ScanHealth *(Outil avancé/Caché)*
*   **Reparation profonde** (`res_dism_restore`) : DISM /RestoreHealth *(Outil avancé/Caché)*
*   **Nettoyage massif Temp/Cache** (`res_temp_clean`) : Purge des fichiers temporaires *(Outil avancé/Caché)*
*   **Reset Fix Windows Update** (`res_wu_reset`) : Réinitialisation forcée de Windows Update *(Outil avancé/Caché)*

### 🧹 NETTOYAGE ET OPTIMISATION
*   **Menu de Nettoyage et Optimisation** (`sys_opti_menu`) : Regroupe nettoyage et optimisation
*   **Nettoyage Complet Unifie** (`sys_clean_unified`) : Disque, Temp, Registre, WU, DNS *(Outil avancé/Caché)*
*   **Nettoyage du Registre** (`sys_registry_cleanup`) : Optimisation rapide *(Outil avancé/Caché)*
*   **Menu Optimisation Windows 11** (`sys_tweaks_menu`) : Bloatwares, Telemetrie, Cortana *(Outil avancé/Caché)*
*   **Programmes au Demarrage** (`sys_startup_manager`) : Gestion des malwares/bloatwares au boot *(Outil avancé/Caché)*

### 🌐 RESEAU
*   **Gestionnaire DNS** (`dns_manager`) : Changer DNS Cloudflare/Google par defaut DHCP
*   **Menu de Depannage Reseau** (`sys_network_menu`) : Outils avances (ARP, TCP/IP, Autoreset)

### 💾 DISQUE ET MATERIEL
*   **Formatteur de Disque (DISKPART)** (`disk_manager`) : Formater un disque de facon sécurisée
*   **Gestionnaire Ecran Tactile** (`touch_screen_manager`) : Activation et désactivation du pilote
*   **Gestionnaire d'Imprimantes** (`sys_print_manager`) : Lister, vider la file et supprimer des imprimantes
*   **Gestionnaire Plan d'Alimentation** (`sys_power_plan`) : Equilibre, Performances, Ultimate Performance

### 📦 APPLICATIONS ET MSS
*   **Mises a jour d'applications** (`winget_manager`) : MAJ logiciels via Winget
*   **Installateur d'applications** (`app_installer`) : Installer des logiciels triés via Winget

### 🔐 COMPTES ET SECURITE
*   **Extracteurs de mots de passe** (`sys_passwords_menu`) : Menus des mots de passe
*   **Recuperation de Compte bloque** (`sys_unlock_notes`) : Instructions sans mdp
*   **Gestion utilisateurs locaux** (`um_menu`) : Panneau de gestion local
*   **Gestionnaire d'identifiants Windows** (`dump_credman`) : Utilitaire CredMan *(Outil avancé/Caché)*
*   **Extraction reseaux Wi-Fi** (`dump_wifi`) : Passwords en clair via PS *(Outil avancé/Caché)*
*   **WebBrowserPassView** (`sys_nirsoft_pw`) : Utilitaire Nirsoft graphique *(Outil avancé/Caché)*
*   **Test Antivirus (EICAR Safe)** (`sys_av_test`) : Simulation eicar pour validation AV.
*   **Test d'Infiltration et Audit de Privileges** (`cyber_privesc_audit`) : Module avancé cherchant les failles d'élévation de privilèges (Unquoted Paths, Tâches SYSTEM, Banner Grabbing).
*   **Generateur de Config Securite (.htaccess)** (`cyber_gen_htaccess`) : Crée une configuration robuste (Headers, Security) pour votre site web.

### 📤 EXTRACTION ET PERSONNALISATION
*   **Menu des Extractions** (`sys_export_menu`) : Export clés, WIFI, Drivers
*   **Cle de licence** (`sys_win_key`) : Scripts Powershell d'extraction OEM/WMI *(Outil avancé/Caché)*
*   **Extraction des pilotes** (`sys_drivers`) : Sauvegarde via Dism *(Outil avancé/Caché)*
*   **Export Liste des Logiciels** (`sys_export_software`) : Fichier CSV sur le bureau *(Outil avancé/Caché)*
*   **Export Wi-Fi + Logiciels (TXT)** (`sys_export_wifi_apps`) : Pack txt sur le bureau *(Outil avancé/Caché)*
*   **Menu contextuel Windows 11** (`context_menu`) : Swap entre classique et moderne.
*   **Dossier God Mode** (`sys_god_mode`) : Création du dossier God Mode Desktop.
*   **Raccourcis Bureau 1-Clic** (`sys_shortcuts_bureau`) : Power off/ Restart desktop.

---
**Conseil pour l'IA suivante :**
Lors d'une nouvelle modification, lis attentivement la logique d'assignation des menus `t[]` en haut du script `Scripts-by-AleexLeDev.bat` avant d'ajouter un nouvel outil. Prends garde aux échappements de caractères dans les commandes PowerShell d'une ligne (`One-Liners`) appelées depuis le script Batch.
