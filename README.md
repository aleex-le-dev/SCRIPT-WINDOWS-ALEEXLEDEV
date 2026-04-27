```text
  ▄▄▄▄▄▄▄ ▄▄       ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄    ▄▄       ▄▄▄▄▄▄▄    ▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ 
 █       █  █     █       █       █  █ █  █  █  █     █       █  █      ██       █  █ █  █
 █   ▄   █  █     █    ▄▄▄█    ▄▄▄█  █▄█  █  █  █     █    ▄▄▄█  █  ▄    █    ▄▄▄█  █▄█  █
 █  █▄█  █  █     █   █▄▄▄█   █▄▄▄█       █  █  █     █   █▄▄▄   █ █ █   █   █▄▄▄█       █
 █       █  █▄▄▄▄▄█    ▄▄▄█    ▄▄▄█       █  █  █▄▄▄▄▄█    ▄▄▄█  █ █▄█   █    ▄▄▄█       █
 █   ▄   █       █   █▄▄▄█   █▄▄▄█   ▄   █  █       █   █▄▄▄   █       █   █▄▄▄█   ▄   █
 █▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█  █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█  █▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█

             ---===[  A  L  E  E  X     L  E     D  E  V  ]===---
```

# Scripts-by-AleexLeDev — Boîte à Outils Système (v3.5 Windows / v2.0 Linux)

Toolkit multifonction de diagnostic, réparation, optimisation et cybersécurité.  
Disponible en deux éditions : **Windows (Batch)** et **Linux (Bash)** — même structure, mêmes noms, mêmes fonctionnalités.

---

## Editions

| Fichier | Plateforme | Version | Outils |
|---|---|---|---|
| `Scripts-by-AleexLeDev.bat` | Windows 10/11 | v3.5 GOLDEN | 167 |
| `Scripts-by-AleexLeDev-Linux.sh` | Debian / Ubuntu / Arch / Fedora | v2.0 | 167 |

---

## Lancement

### Windows
```bat
Clic droit → "Exécuter en tant qu'administrateur"
```

### Linux
```bash
sudo bash Scripts-by-AleexLeDev-Linux.sh
```
Le script détecte automatiquement l'absence de terminal et s'ouvre dans gnome-terminal / konsole / xterm.

---

## Navigation

- **Flèches ↑↓** — naviguer
- **Entrée** — sélectionner
- **Échap** — retour au menu précédent

Aucune saisie clavier numérique. Jamais.

---

## Structure — 10 Catégories, 167 outils

### 1. DIAGNOSTIC
Analyse complète du système : CPU, RAM, GPU, batterie, chiffrement disque, journal d'erreurs, température, antivirus, events critiques.

### 2. REPARATION
- **Rescue** : SFC/apt fix-broken, DISM/debsums, CHKDSK/fsck, Reset Windows Update/APT locks
- **WinRE/GRUB** : Mode sans échec, accès BIOS/UEFI, statut boot, reset GRUB

### 3. NETTOYAGE ET OPTIMISATION
Nettoyage complet (temp, cache APT, DNS, disque, registre/orphelins, presse-papiers, navigateurs), tweaks système (swappiness, CPU governor, IPv6), gestionnaire de démarrage.

### 4. RESEAU
- **DNS** : Cloudflare, Google, Quad9, AdGuard, DHCP restore
- **Dépannage** : flush DNS, ARP, renouvellement IP, reset TCP/IP, script urgence réseau
- **Pentest** : scan LAN, flux réseau, triage connectivité, scanner distant, web interface hunt, enum services, vérif failles, audit WiFi

### 5. DISQUE
Gestionnaire complet : formatage sécurisé, SMART, fsck, benchmark I/O, effacement (shred).

### 6. APPLICATIONS
Mises à jour (apt + snap + flatpak + pip), installateur rapide (Chrome, VLC, LibreOffice, p7zip, zsh).

### 7. COMPTES ET SECURITE
- Extracteurs : credentials, Wi-Fi, navigateurs (Firefox/Chrome)
- Utilisateurs : créer, supprimer, droits sudo, auto-login, root
- **Antivirus ClamAV** : scan rapide/complet, mise à jour signatures, historique menaces, test EICAR, test heuristique

### 8. EXTRACTION ET SAUVEGARDE
Clé système, export pilotes/logiciels/Wi-Fi, loot complet, historique navigateurs, scan documents sensibles, audit routes web.

### 9. PERSONNALISATION
Menu contextuel Nautilus, God Mode, mode gaming (CPU perf + GameMode), raccourcis bureau, visionneuse d'images, explorateur d'arborescence.

### 10. MATERIEL
Écran tactile (xinput), imprimantes (CUPS), plans d'alimentation (governor), score de performances (sysbench), test RAM (memtester).

---

## Système de Favoris

- **Touche [F]** sur une option → ajouter/retirer des favoris
- Les favoris apparaissent sur l'écran d'accueil pour un accès immédiat
- Sauvegardés dans `favoris.txt` / `~/.config/scripts-aleex/favoris.txt`

---

## Configuration Email (Windows — extraction Nirsoft)

Créer `credentials.txt` à côté du script :
```text
SMTP_USER=votre-email@gmail.com
SMTP_PASS=votre-mot-de-passe-application
EMAIL_TO=email-reception@gmail.com
```
*Pour Gmail : utiliser un "Mot de passe d'application" depuis les paramètres du compte.*

---

## Avertissement Légal

Outil conçu pour le diagnostic système et le pentest éthique.  
**Ne jamais tester une infrastructure sans autorisation explicite.**  
L'auteur (ALEEXLEDEV) décline toute responsabilité en cas d'usage inapproprié.

---

Développé avec passion par **ALEEXLEDEV**
