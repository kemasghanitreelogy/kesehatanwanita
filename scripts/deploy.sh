#!/usr/bin/env bash
# Force-publish the current working tree to a Shopify theme via Shopify CLI.
# Bypasses the GitHub → Shopify auto-sync delay.
#
# Usage:
#   scripts/deploy.sh                # push to the LIVE theme (with --allow-live confirmation)
#   scripts/deploy.sh dev            # push to a development/unpublished theme (creates one if needed)
#   scripts/deploy.sh theme <ID|NAME># push to a specific theme by id or name
#
# Requirements:
#   - Shopify CLI installed (shopify version)
#   - You have run `shopify auth login` (or `shopify theme push` once) for this store
#   - .shopify/ contains the store config (already in repo, gitignored)

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v shopify >/dev/null 2>&1; then
  echo "Shopify CLI not found. Install with: npm i -g @shopify/cli @shopify/theme" >&2
  exit 1
fi

mode="${1:-live}"

case "$mode" in
  live)
    echo "→ Pushing local theme to the LIVE theme on the connected store…"
    shopify theme push --live --allow-live --nodelete
    ;;
  dev)
    echo "→ Pushing local theme to an unpublished development theme…"
    shopify theme push --unpublished --nodelete
    ;;
  theme)
    target="${2:-}"
    if [[ -z "$target" ]]; then
      echo "Usage: scripts/deploy.sh theme <ID|NAME>" >&2
      exit 1
    fi
    echo "→ Pushing local theme to theme: $target"
    shopify theme push --theme "$target" --nodelete
    ;;
  *)
    echo "Unknown mode: $mode" >&2
    echo "Valid modes: live | dev | theme <ID|NAME>" >&2
    exit 1
    ;;
esac

echo "✓ Done."
