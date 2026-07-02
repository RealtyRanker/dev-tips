#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo " RealtyRanker — fetch & pull all repos"
echo "========================================"
echo ""

SERVICES=(dev-tips realty-parser flats-analyzer subscription-handler users-notifier reports-builder)

for svc in "${SERVICES[@]}"; do
  echo ">>> $svc"
  if [ -d "$ROOT_DIR/$svc/.git" ]; then
    (cd "$ROOT_DIR/$svc" && git fetch --all && git pull origin main)
  else
    echo "    $svc is not a git repo, skipping"
  fi
  echo ""
done

echo "========================================"
echo " Done"
echo "========================================"
