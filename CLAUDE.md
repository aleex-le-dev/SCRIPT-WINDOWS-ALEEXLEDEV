# CLAUDE.md — Scripts-by-AleexLeDev (v3.5+)
> Instructions machine prioritaires. Mode : Performance & Token-Saving.

## 🎯 Principes d'Exécution
1. **Concision :** Pas de blabla. Code direct + explications vitales uniquement.
2. **Conformité :** Respect strict du système `:AutoMenu` et du dictionnaire `t[N]`.
3. **Admin-First :** Vérifier `fsutil dirty query %systemdrive%` avant toute action système.

## 🏗️ Standards Techniques (Lois du Projet)
- **Routage :** Batch (`.bat`) gère la navigation et les menus.
- **Logique :** PowerShell (`.ps1`) gère WMI, Web, Parsing, et UI complexes.
- **Indexation `t[N]` :** - Format : `set "t[N]=label:Titre~Description[:HIDDEN]"` (en début de script).
  - Outils hors `t[N]` : Définir `set "map_label=Titre~Description"`.
  - `total_tools` : Laisser le script l'auto-calculer via la boucle `for /l`.
- **Interface :** Interdiction de boucles `for` manuelles pour les menus.
  - Utilisation : `call :AutoMenu "TITRE" "label1;[---];label2" "OPTIONS"`

## 🛠️ Skills de Développement (Anti-Bug IA)
### 1. Gestion des chaînes complexes (Règle d'Or)
- **SI** code PS > 3 lignes **OU** contient `"`/`'` imbriqués **OU** symboles `&|< >`.
- **ALORS** : Écrire dans `%TEMP%\tmp.ps1` -> Exécuter -> Supprimer.
- **JAMAIS** de "one-liners" PS complexes (risque de crash syntaxique Batch).

### 2. Sécurité & Furtivité
- **Payloads/EICAR :** Encodage **Base64 OBLIGATOIRE**. Jamais de chaînes sensibles en clair.
- **Anti-Forensics :** `del /f /q` systématique des fichiers temporaires après usage.

### 3. Syntaxe Batch Robuste
- Déclaration : `set "var=valeur"` (guillemets obligatoires pour éviter les espaces).
- Scoping : `setlocal / endlocal` dans chaque nouveau module : **OBLIGATOIRE**.
- DNS : Si modif DNS -> `net stop Dnscache /y` avant et `net start Dnscache` après.

## 🚨 Check-list de Validation (Pre-Response)
1. **Dictionnaire :** La fonction est-elle déclarée dans `t[N]` au début du script ?
2. **Admin :** Le script vérifie-t-il les privilèges avant de s'exécuter ?
3. **Favoris :** La logique `NONUMS` est-elle préservée ?
4. **Boot Loop :** Si modif `RunOnce` -> Routine `SafeModeRevert` incluse ?