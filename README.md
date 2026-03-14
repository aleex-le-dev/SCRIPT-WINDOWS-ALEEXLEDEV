# 🛠️ Boîte à Scripts Windows - ALEEXLEDEV (v3.0)

Bienvenue dans la **Boîte à Scripts Windows**, un outil multifonction ultime conçu pour le diagnostic, la réparation, l'optimisation et la cybersécurité. Ce script Batch interactif regroupe des outils puissants pour les utilisateurs avancés et les administrateurs système.

---

## 🚀 Fonctionnalités Principales

Le script est organisé en **5 catégories majeures** pour une navigation fluide :

### 1. 🔍 RECONNAISSANCE
Collectez des informations sur des cibles web ou réseau :
*   **WHOIS & ASN** lookup.
*   Énumération de sous-domaines via **crt.sh**.
*   Vérification des fichiers sensibles (`robots.txt`, `sitemap.xml`).
*   Bruteforce DNS pour découvrir des services cachés.

### 2. 🌐 ANALYSE RÉSEAU
Cartographiez et sécurisez votre infrastructure :
*   **Scan LAN Avancé** : Détection des appareils, résolution des marques par adresse MAC (OUI) et scan de ports ouverts.
*   **Test de Fuite DNS** : Vérifiez si votre anonymat (VPN) est respecté.
*   **Flux Réseau** : Analyse des connexions actives liées aux processus Windows.
*   **Gestionnaire DNS** : Basculez rapidement sur Cloudflare (1.1.1.1) ou Google (8.8.8.8).

### 3. ⚔️ WEB OFFENSIF
Outils de test d'intrusion (Pentest) avancés :
*   **SSRF (14 Payloads)** : Testez les requêtes côté serveur (Cloud IMDS, DB internes, LFI).
*   **Subdomain Takeover (19 Services)** : Détectez les CNAME "dangling" (Vercel, GitHub, AWS...).
*   **Audit d'Auth & Web Pentest** : Scanners de vulnérabilités (SQLi, XSS, Path Traversal, Headers).

### 4. 🛡️ AUDIT DÉFENSIF
Vérifiez la solidité de votre propre système :
*   **Audit de Privilèges** : Détection des Unquoted Service Paths et tâches SYSTEM suspectes.
*   **Audit de Sécurité** : Vérification Firewall, SMB et ports RAT classiques.
*   **Générateur .htaccess** : Créez des configurations de headers sécurisés en un clic.
*   **Test Antivirus** : Vérifiez si votre protection réagit bien aux signatures EICAR.

### 5. 📊 RAPPORTS
Générez des rapports professionnels au format **HTML** pour vos audits système ou vos tests de vulnérabilités web.

---

## ⭐ Système de Favoris

Le script intègre un système de **favoris dynamique** :
*   Dans chaque menu, vous pouvez appuyer sur la touche **[F]** sur une option pour l'ajouter ou la retirer des favoris.
*   Vos outils préférés apparaîtront directement sur l'écran d'accueil du script pour un accès ultra-rapide.
*   Les favoris sont sauvegardés localement dans le fichier `favoris.txt`.

---

## 📧 Configuration de l'Envoi par Email (Nirsoft)

Pour utiliser l'envoi automatique des mots de passe par email dans le module `Extracteurs de mots de passe`, vous devez créer un fichier de configuration local. 

**Pourquoi ?** Pour garantir que vos identifiants ne soient **JAMAIS** poussés sur GitHub (le fichier est sécurisé via `.gitignore`).

### Comment configurer ?
Créez un fichier nommé `credentials.txt` à côté du script avec la structure suivante :
```text
SMTP_USER=votre-email@gmail.com
SMTP_PASS=votre-mot-de-passe-d-application
EMAIL_TO=email-de-reception@gmail.com
```

*Note : Pour Gmail, utilisez un "Mot de passe d'application" généré dans les paramètres de votre compte Google.*

---

## ⚠️ Avertissement Légal
Cet outil est conçu pour le diagnostic système et le Pentest éthique. L'auteur (**ALEEXLEDEV**) n'est pas responsable des dommages causés par une utilisation inappropriée de ces outils. Ne testez jamais une infrastructure sans autorisation explicite.

---
Développé avec ❤️ par **ALEEXLEDEV**
