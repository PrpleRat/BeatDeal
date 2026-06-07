# BeatDeal — Créer l'app sur Apple Developer (guide pas à pas)

Ce guide couvre la création de l'app **BeatDeal** sur ton compte Apple Developer, depuis Windows ou Mac, pour ensuite utiliser la CI GitHub Actions (TestFlight) comme Panium, SleepLab, TrajOc et RAS.

## Ce dont tu as besoin

- Compte **Apple Developer Program** actif (99 €/an) — [developer.apple.com/programs](https://developer.apple.com/programs/)
- Accès à [App Store Connect](https://appstoreconnect.apple.com)
- Repo GitHub **BeatDeal** poussé (racine = dossier `BeatDeal/`)

---

## Étape 1 — Enregistrer le Bundle ID (App ID)

1. Va sur [developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list)
2. Clique **+** (Register an App ID)
3. Type : **App IDs** → **App**
4. Renseigne :
   - **Description** : `BeatDeal`
   - **Bundle ID** : **Explicit** → `com.cashthetrain.beatdeal`
5. Capabilities : **aucune obligatoire** pour BeatDeal v1
6. **Register**

---

## Étape 2 — Créer l'app dans App Store Connect

1. [appstoreconnect.apple.com/apps](https://appstoreconnect.apple.com/apps) → **+** → **New App**
2. Plateformes : **iOS**
3. **Name** : `BeatDeal`
4. **Primary Language** : French
5. **Bundle ID** : `com.cashthetrain.beatdeal`
6. **SKU** : `beatdeal-ios`
7. **Create**

Complète plus tard (pas bloquant pour TestFlight) :

| Champ | Suggestion |
|-------|------------|
| Sous-titre | Licences pro en 60s |
| Catégorie | Musique ou Business |
| Confidentialité | Aucune donnée collectée |
| Politique de confidentialité | URL requise à la soumission — ex. `https://beatdeal.app/privacy` |

---

## Étape 3 — Créer l'achat in-app (BeatDeal Pro)

1. App Store Connect → **BeatDeal** → **Monetization** → **In-App Purchases**
2. **+** → **Non-Consumable**
3. **Product ID** : `beatdeal_pro` (doit correspondre à `AppConstants.productID`)
4. **Price** : 4,99 €
5. Nom + description en français → **Save**

> L'IAP n'est pas bloquant pour TestFlight interne, mais requis pour tester les achats en sandbox.

---

## Étape 4 — Clé API App Store Connect (pour CI)

1. App Store Connect → **Users and Access** → **Integrations** → **App Store Connect API**
2. **+** → nom : `GitHub Actions BeatDeal`
3. Accès : **App Manager** (ou Admin)
4. Télécharge le fichier **`.p8`** — **une seule fois**
5. Note **Issuer ID** et **Key ID**

Tu peux réutiliser la même clé que Panium/RAS si elle a les droits App Manager.

---

## Étape 5 — Secrets GitHub

Dans ton repo GitHub **BeatDeal** :

**Settings → Secrets and variables → Actions → New repository secret**

| Secret | Valeur |
|--------|--------|
| `ASC_KEY_ID` | Key ID |
| `ASC_ISSUER_ID` | Issuer ID (UUID) |
| `ASC_PRIVATE_KEY` | Contenu **complet** du `.p8` |

C'est tout — pas besoin de secrets certificat manuels.

---

## Étape 6 — Pousser le code

```powershell
cd D:\CURSOR\BOS-main\BeatDeal
git remote add origin https://github.com/TON_USER/BeatDeal.git
git push -u origin main
```

---

## Étape 7 — Lancer TestFlight

1. GitHub → **Actions** → **BeatDeal TestFlight** → **Run workflow**
2. Attendre ~15–25 min
3. App Store Connect → **BeatDeal** → **TestFlight** → build **Ready to Test**

---

## Checklist récapitulative

- [ ] Compte Apple Developer actif
- [ ] App ID `com.cashthetrain.beatdeal` créé
- [ ] App **BeatDeal** créée dans App Store Connect
- [ ] IAP `beatdeal_pro` créé (optionnel pour TestFlight, requis pour achats)
- [ ] Clé API ASC + 3 secrets GitHub
- [ ] Repo GitHub poussé
- [ ] Workflow **BeatDeal TestFlight** exécuté avec succès
- [ ] Build visible dans TestFlight sur iPhone

---

## Team ID

Le projet utilise **Team ID `4N92TKQ397`**. Si ton compte est différent, remplace dans `project.yml`, `ExportOptions.plist`, `ci/profile-utils.sh` et `fastlane/Fastfile`.
