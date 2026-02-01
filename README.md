# 🔨 Ma Configuration Hammerspoon (AI & Productivité)

Ce projet contient mes scripts d'automatisation pour macOS, notamment pour connecter mon Terminal à l'IA (Gemini/ChatGPT).

## 🚀 Fonctionnalités Principales

### 1. AI Paste (Copie Intelligente vers IA)
Le script `modules/ai_paste.lua` détecte automatiquement ce que je copie et l'envoie vers la fenêtre d'IA ouverte (Gemini ou ChatGPT).

* **Texte :** Copie ultra-rapide (Mode Turbo 0.15s).
* **Images :** Copie sécurisée (Mode Smart 0.6s) pour laisser le temps à l'upload.
* **Terminal Apple :** Force le `Cmd+C` automatiquement à la sélection.
* **iTerm2 :** Détecte la copie native sans interférence.

### 2. Raccourcis Clavier
* **`Alt + S`** : Capture d'écran -> Envoi direct à l'IA.
* **`Alt + V`** : Force l'envoi du presse-papier actuel vers l'IA (Secours).

---

## ☁️ Sauvegarde GitHub

J'ai créé une commande personnalisée pour sauvegarder tout le projet en un mot.

**Commande :**
```bash
sauver_hammer
```

**Ce que ça fait :**
1.  Se place dans le dossier `.hammerspoon`.
2.  Ajoute tous les nouveaux fichiers.
3.  Fait un commit "Sauvegarde Rapide".
4.  Envoie tout sur GitHub (Push).

---

*Dernière mise à jour : Février 2026*
