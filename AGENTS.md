# AGENTS.md

## Règles de collaboration pour ce dossier
- Avant toute modification, fournir un mini‑rapport clair (liste numérotée 1 à 5 points maximum) avec la liste des changements prévus.
- Attendre une validation explicite (ex. `programme validé` ou `validé`) avant de commencer les changements.
- Montrer la liste avant de commencer à travailler, à chaque demande.

## Git push protocol (KOKTEK)
- Quand l’utilisateur dit "push to GitHub" :
- Créer un court message de commit en français avec un préfixe ci‑dessous.
- Pousser vers GitHub.
- Vérifier l’exécution de GitHub Actions si possible, sinon demander un lien.
- Vérifier le déploiement via le build stamp et rapporter le résultat.

## French commit prefixes
- `ajout:` Nouvelle fonctionnalité.
- `corr:` Correction de bug.
- `refacto:` Refactorisation sans changement fonctionnel.
- `doc:` Documentation uniquement.
- `test:` Ajout ou modification de tests.
- `perf:` Amélioration des performances.
- `style:` Mise en forme, CSS, ou ajustements visuels sans logique métier.
- `deps:` Mise à jour des dépendances.
- `ci:` Pipeline CI/CD ou scripts d’automatisation.
- `config:` Configuration ou paramètres d’environnement.
- `maintenance:` Nettoyage, tâches techniques diverses.
- `revert:` Annulation d’un commit.

## Build stamp
- Build stamp uses `VITE_BUILD_ID` (set from `GITHUB_SHA` in CI).
- Stamp is shown in the footer to confirm the deployed version.
