Documentation et Historique des Développements IA
Projet : Scripts-by-AleexLeDev.bat (Golden Edition v3.5+)

Ce fichier sert de mémoire de contexte pour toute future IA ou développeur intervenant sur ce script. Il résume l'architecture, les méthodes de développement, les problèmes historiques résolus et les directives strictes d'optimisation.

1. Architecture et Choix Techniques
Encapsulation PowerShell : Face aux limites inhérentes du MS-DOS (CMD), les scripts avancés font massivement appel à powershell.exe -Command "..." ou -File. Cela permet de traiter des chaînes complexes, d'interroger les APIs WMI/CIM, d'effectuer des requêtes web (Invoke-WebRequest), et de gérer des interfaces (Pop-ups).

Dictionnaire Centralisé : L'indexation de tous les outils se fait au tout début du script via un tableau t[ID]=nom_fonction:Titre~Description:HIDDEN. C'est le cœur du programme.

Moteur de Menu Automatique (:AutoMenu) : Les menus ne sont plus hardcodés. Ils font appel à un moteur de rendu dynamique centralisé qui gère l'affichage, la pagination, et le ciblage.

Système de Favoris Dynamique : La touche (F) intercepte l'outil sélectionné, l'écrit dans favoris.txt, et le moteur de menu met à jour l'affichage visuel dynamiquement en relisant ce fichier.

Sécurisation des Entrées (Input Validation) : La saisie utilisateur (set /p) est filtrée via des fonctions dédiées (ex: :InputWithEsc) pour éviter les plantages ou l'injection accidentelle.

Auto-Élévation : Le script inclut une routine de détection des privilèges. S'il n'est pas lancé en Administrateur, il se relance lui-même via Start-Process -Verb RunAs.

2. Fonctionnalités et Modules Clés
Recherche Globale (Global Search) : Fonction accessible via la touche S permettant de chercher et lancer un script spécifique parmi l'intégralité des outils indexés.

Monitoring Matériel : Surveillance CPU/GPU (WMI + OpenHardwareMonitor), analyse approfondie de la RAM (Soudée vs Remplaçable), rapports de batterie HTML et vérification BitLocker.

Cybersécurité et Pentest (LAN/WAN) : Modules de scan de ports, détection de failles web (SSTI, XXE, SQLi, XSS, Open Redirect), IP Grabber (Webhooks), et audit SMB/IPC$.

Tests Antivirus (EICAR & Heuristique) : Génération de payloads inoffensifs en base64 pour tester les réactions de l'AMSI et de Windows Defender, avec nettoyage post-test.

Post-Exploitation & Anti-Forensics : Dumping de mots de passe (navigateurs, Wi-Fi, Credential Manager), création de reverse shells obfusqués et module de nettoyage des traces (Event Logs).

3. Historique des Corrections Critiques (Debugging)
Stabilité des Sous-menus (Le bug du NONUMS) : Résolution d'un bug où l'argument NONUMS désactivait l'écoute de la touche F (Favoris). La logique dynamique a été réparée pour fonctionner partout.

Mode "Réparation" Infini (Boot Loop) : Correction d'un problème critique où l'exécution des scripts de démarrage (Safe Mode) bloquait le PC. La gestion de la clé registre RunOnce (SafeModeRevert) a été fiabilisée pour garantir un retour au mode normal.

Caractères Spéciaux : Fix des erreurs de syntaxe de type &, <, >, | dans les one-liners PowerShell en utilisant des encodages Base64 ou une évasion rigoureuse.

4. ⚠️ Directives d'Optimisation pour les Futures IA
Si vous êtes une IA analysant ce code pour y apporter des modifications, vous DEVEZ respecter les règles suivantes :

Règle du DRY (Don't Repeat Yourself) : * Ne créez JAMAIS de boucles for locales pour générer un sous-menu.

Utilisez exclusivement le moteur :AutoMenu situé à la fin du script.

Syntaxe : call :AutoMenu "TITRE DU MENU" "label1;label2;[--- SEPARATEUR ---];label3" "OPTIONS"

Ajout de Nouveaux Outils :

Créez la fonction (ex: :nouvel_outil).

Déclarez-la OBLIGATOIREMENT dans le dictionnaire global au début du script : set "t[XX]=nouvel_outil:Titre~Description:HIDDEN".

Incrémentez la variable total_tools.

C'est tout. Le système AutoMenu et le Global Search feront le reste.

Gestion des variables locales : Utilisez systématiquement setlocal / endlocal dans les nouveaux modules autonomes pour éviter la pollution de l'espace global des variables du script parent.

One-Liners PowerShell : Pour tout code PowerShell dépassant 3 lignes ou contenant des guillemets imbriqués complexes, privilégiez l'écriture temporaire dans un fichier (ex: > "%TEMP%\script.ps1") puis son exécution powershell -File "%TEMP%\script.ps1", suivie de sa suppression. Cela évite les cauchemars d'échappement de caractères en Batch.