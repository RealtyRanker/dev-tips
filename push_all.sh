#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$1" ]; then
  echo "Usage: $0 \"<commit message>\""
  exit 1
fi

COMMIT_MESSAGE="$1"

echo "========================================"
echo " RealtyRanker — commit & push changed repos"
echo "========================================"
echo ""

SERVICES=(dev-tips realty-parser flats-analyzer subscription-handler users-notifier reports-builder)

for svc in "${SERVICES[@]}"; do
  echo ">>> $svc"
  if [ ! -d "$ROOT_DIR/$svc/.git" ]; then
    echo "    $svc is not a git repo, skipping"
    echo ""
    continue
  fi

  if [ -z "$(cd "$ROOT_DIR/$svc" && git status --porcelain)" ]; then
    echo "    no changes, skipping"
    echo ""
    continue
  fi

  (cd "$ROOT_DIR/$svc" && git add . && git commit -m "$COMMIT_MESSAGE" && git push origin main)
  echo ""
done

echo "========================================"
echo " Done"
echo "========================================"
