# BeatDeal

Application iOS native (Swift/SwiftUI) — générateur de contrats de licence de beats professionnels en moins de 60 secondes.

100 % offline · PDF local · **App payante** sur l'App Store (4,99 €).

## Fonctionnalités

- **Générateur en 3 étapes** : type de licence → infos artiste/beat/producteur → droits accordés
- **4 types de licence** : MP3 Lease, WAV Lease, Trackout Lease, Exclusive
- **PDF A4** généré localement (HTML → PDF via UIKit)
- **Partage natif** : iMessage, email, AirDrop
- **Contrats récents** sur l'écran d'accueil (5 derniers)
- **Modèles personnalisables** : prix, streams max, droits par défaut, clauses
- **Profil producteur** pré-rempli dans tous les contrats
- **App payante** : toutes les fonctions incluses (pas d'achat in-app)
- **Calculateur de royalties** : estimation revenus / seuil de rentabilité par plateforme (JSON embarqué)
- **Catalogue de beats** : beats + prix par licence, pré-remplissage des contrats
- **Dashboard revenus** : totaux mois / trimestre / global + ventilation par licence
- **Tracker de licences** : suivi streams + expiration, alertes push locales pour upgrades
- **Mode co-prod** : co-producteur + % sur fiche beat, PDF split sheet aligné
- **DM Kit** : message Instagram/iMessage pré-rédigé avec lien de paiement
- **Checklist de livraison** : 5 étapes avant envoi final
- **Packs de beats** : bundles multi-beats avec contrat PDF unifié
- **Zéro backend** — UserDefaults + fichiers PDF temporaires

## Prérequis

- macOS avec **Xcode 15+** (ou CI GitHub Actions sans Mac)
- iPhone physique recommandé (partage PDF)
- iOS **17+**
- Compte **Apple Developer Program** pour TestFlight

## Import GitHub

**Pousse ce dossier comme racine du repo** (pas de dossier parent).

```
BeatDeal/                 ← racine du dépôt Git
├── .github/workflows/
├── project.yml
├── BeatDeal/             ← code app
└── BeatDealTests/
```

`BeatDeal.xcodeproj` est généré par XcodeGen — ne pas le committer (`.gitignore`).

## Déploiement TestFlight (sans Mac)

1. Crée l'app sur Apple : [docs/APPLE-DEVELOPER-SETUP.md](docs/APPLE-DEVELOPER-SETUP.md)
2. Ajoute les 3 secrets GitHub : `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`
3. **Actions** → **BeatDeal TestFlight** → **Run workflow**

Guide détaillé : [docs/TESTFLIGHT.md](docs/TESTFLIGHT.md)

## Installation (Mac)

```bash
brew install xcodegen
cd BeatDeal
python3 ci/generate-app-icons.py
xcodegen generate
open BeatDeal.xcodeproj
```

1. Sélectionner ta **Team** dans Signing & Capabilities
2. Bundle ID : `com.cashthetrain.beatdeal`
3. Bundle ID : `com.cashthetrain.beatdeal`
4. Build & Run sur iPhone

## CI GitHub Actions

| Workflow | Rôle |
|----------|------|
| `beatdeal-testflight.yml` | Archive + IPA + upload TestFlight |
| `beatdeal-bootstrap-signing.yml` | Cert + profils (sans Mac, optionnel) |
| `beatdeal-ios.yml` | Build simulateur (manuel) |

## Structure

```
./
├── .github/               # CI
├── BeatDeal/              # App principale
│   ├── Config/
│   ├── Models/
│   ├── Services/          # Storage, PDF
│   ├── Theme/
│   ├── Views/
│   └── Resources/
├── BeatDealTests/
├── ci/
├── docs/
├── fastlane/
├── project.yml
└── README.md
```

## App Store

| Champ | Valeur |
|-------|--------|
| **Nom** | BeatDeal |
| **Sous-titre** | Licences pro en 60s |
| **Bundle ID** | `com.cashthetrain.beatdeal` |
| **Catégorie** | Musique / Business |
| **Prix** | 4,99 € (app payante — tarif dans App Store Connect) |
| **Monétisation** | Aucun achat in-app |

## Tests

```bash
xcodebuild test -scheme BeatDeal -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Licence

MIT — voir [LICENSE](LICENSE).
