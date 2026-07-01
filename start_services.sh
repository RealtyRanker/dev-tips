#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo " RealtyRanker — rebuild & restart services"
echo "========================================"
echo ""

SERVICES=(realty-parser flats-analyzer subscription-handler users-notifier)

for i in "${!SERVICES[@]}"; do
  svc="${SERVICES[$i]}"
  echo ">>> [$((i+1))/${#SERVICES[@]}] $svc"
  (cd "$ROOT_DIR/$svc" && bash server_setup.sh)
  echo ""
done

echo "========================================"
echo " All services rebuilt and restarted!"
echo "========================================"
echo ""
echo "  realty-parser:        http://localhost:9095"
echo "  flats-analyzer:       http://localhost:9093"
echo "  subscription-handler: http://localhost:9094"
echo "  users-notifier API:   http://localhost:8080"
echo "  users-notifier metrics: http://localhost:9091"
