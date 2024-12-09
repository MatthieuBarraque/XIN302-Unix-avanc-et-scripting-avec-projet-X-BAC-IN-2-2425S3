# Meta-Caca - Unix Network Analysis Tool

## Description
Meta-Caca est un script Shell avancé pour l'analyse réseau. Il fournit une interface utilisateur intuitive en ligne de commande permettant de réaliser diverses tâches de sécurité et de diagnostic, telles que la détection d'appareils, le scan de ports, l'analyse des vulnérabilités, et la planification automatique des audits réseau.

---

## Fonctionnalités
- **Lister les IP et MAC** : Utilisation de `netdiscover` pour cartographier le réseau.
- **Scans avancés avec Nmap** : Plusieurs types de scans personnalisés.
- **Scans rapides avec Masscan** : Analyse des ports à grande échelle.
- **Analyse web avec Nikto** : Détection des vulnérabilités web.
- **Automatisation avec cron** : Planification récurrente de scans.
- **Gestion des scans planifiés** : Visualisation, modification et annulation des audits automatisés.

---

## Prérequis

Assurez-vous que votre système dispose des outils suivants :
- **Linux/Unix** : Bash version 4.0 ou ultérieure.
- **Outils requis** :
  - `nmap`
  - `netdiscover`
  - `masscan`
  - `nikto`
- **Accès root** : Les commandes telles que `nmap` et `masscan` requièrent des privilèges administrateurs.

---

## Installation

1. Clonez le projet :
   ```bash
   git clone git@github.com:MatthieuBarraque/D3sir3-UNIX-Shell.git
   cd D3sir3-UNIX-Shell
   ```

2. Rendre les scripts exécutables :
   ```bash
   chmod +x metacaca.sh install.sh
   ```

3. Installez les outils requis :
   ```bash
   ./install.sh
   ```

4. Lancez le script principal :
   ```bash
   ./metacaca.sh
   ```

---

## Utilisation

1. Lancez le script pour afficher le menu principal.
2. Naviguez entre les options pour choisir une tâche :
   - Lister les IP et MAC disponibles.
   - Réaliser un scan Nmap personnalisé.
   - Automatiser un scan à l'aide de cron.
   - Gérer les scans planifiés.

---

## Contributions

Les contributions sont les bienvenues ! Si vous souhaitez améliorer ou ajouter des fonctionnalités, n'hésitez pas à forker le projet et soumettre une pull request.