#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Vérification entitlements BeatDeal ==="

if [ -f BeatDeal/BeatDeal.entitlements ]; then
  if grep -q "critical-alerts" BeatDeal/BeatDeal.entitlements 2>/dev/null; then
    echo "::error::Critical Alerts non requis pour BeatDeal — retire l'entitlement."
    exit 1
  fi
fi

echo "OK — pas d'entitlement problématique."
