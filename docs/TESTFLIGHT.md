# BeatDeal — Déploiement TestFlight (GitHub Actions)

Même modèle que **Panium** / **SleepLab** / **TrajOc** / **RAS** : workflow **BeatDeal TestFlight** à chaque release.

## Prérequis Apple

1. [App Store Connect](https://appstoreconnect.apple.com) — créer l'app **BeatDeal**
2. [Developer](https://developer.apple.com/account/resources/identifiers/list) — App ID **`com.cashthetrain.beatdeal`**
3. Clé API ASC : **Users and Access → Integrations → App Store Connect API**

Guide complet : [APPLE-DEVELOPER-SETUP.md](APPLE-DEVELOPER-SETUP.md)

## Secrets GitHub (repo BeatDeal)

**Obligatoires pour TestFlight** :

| Secret | Description |
|--------|-------------|
| `ASC_KEY_ID` | ID de la clé API |
| `ASC_ISSUER_ID` | Issuer ID du compte |
| `ASC_PRIVATE_KEY` | Contenu du fichier `.p8` (copier-coller entier) |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Certificat `.p12` (bootstrap, **réutilisé**) |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Mot de passe du `.p12` |
| `KEYCHAIN_PASSWORD` | Mot de passe trousseau CI |

**Important :** un seul certificat **Apple Distribution** suffit pour **toutes** tes apps (BeatDeal, Panium, TrajOc, CarenceScan, etc.). Ne le recrée pas à chaque build — Apple limite à **2** certificats actifs. Le workflow **réutilise** le `.p12` et ne régénère que le **profil** App Store.

## Première fois — Bootstrap (optionnel, sans Mac)

1. Ajouter les 3 secrets `ASC_*`
2. **Actions** → **BeatDeal — Bootstrap signing (sans Mac)** → **Run workflow** (une fois, n'importe quel repo suffit si tu as déjà le `.p12`)
3. Copier `IOS_DISTRIBUTION_CERTIFICATE_BASE64`, `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` et `KEYCHAIN_PASSWORD` dans **chaque** repo GitHub

## Envoyer une build TestFlight

1. **Actions** → **BeatDeal TestFlight** → **Run workflow**
2. Laisser **Uploader vers TestFlight** coché
3. Attendre ~15–25 min
4. App Store Connect → **TestFlight** → build **Processing** → **Ready to test**

## Build simulateur

**BeatDeal iOS** — lancement **manuel** uniquement.

## Numéro de build

Par défaut : `run_number * 10 + run_attempt`.

## Dépannage

| Problème | Action |
|----------|--------|
| `Signing certificate is invalid` | Révoquer un ancien cert Distribution sur developer.apple.com puis relancer |
| `CFBundleVersion` déjà utilisé | Relancer ou forcer un numéro plus haut |
| 2 certificats Distribution max | Révoquer un ancien cert puis relancer |
| App ID introuvable | Créer `com.cashthetrain.beatdeal` sur developer.apple.com |

## Workflows

| Fichier | Rôle |
|---------|------|
| `beatdeal-bootstrap-signing.yml` | Certificat + profil → artifact |
| `beatdeal-testflight.yml` | Archive + IPA + upload TestFlight |
| `beatdeal-ios.yml` | Build simulateur (manuel) |
