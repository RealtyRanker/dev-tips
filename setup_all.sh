#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo " RealtyRanker — full infrastructure setup"
echo "========================================"
echo ""

SERVICES=(realty-parser flats-analyzer subscription-handler users-notifier reports-builder)
ORG="https://github.com/RealtyRanker"

echo ">>> [0/9] Cloning services"
for svc in "${SERVICES[@]}"; do
  if [ -d "$ROOT_DIR/$svc" ]; then
    echo "    $svc already exists, skipping"
  else
    echo "    Cloning $svc..."
    git clone "$ORG/$svc.git" "$ROOT_DIR/$svc"
  fi
done
echo ""

echo ">>> [1/9] PostgreSQL"
bash "$SCRIPT_DIR/psql_setup.sh"
echo ""

echo ">>> [2/9] Kafka"
bash "$SCRIPT_DIR/kafka_setup.sh"
echo ""

echo ">>> [3/9] Prometheus"
bash "$SCRIPT_DIR/prometheus.sh"
echo ""

echo ">>> [4/9] Grafana"
bash "$SCRIPT_DIR/grafana.sh"
echo ""

echo ">>> [5/9] realty-parser"
(cd "$ROOT_DIR/realty-parser" && bash server_setup.sh)
echo ""

echo ">>> [6/9] flats-analyzer"
(cd "$ROOT_DIR/flats-analyzer" && bash server_setup.sh)
echo ""

echo ">>> [7/9] subscription-handler"
(cd "$ROOT_DIR/subscription-handler" && bash server_setup.sh)
echo ""

echo ">>> [8/9] users-notifier"
(cd "$ROOT_DIR/users-notifier" && bash server_setup.sh)
echo ""

echo ">>> [9/9] reports-builder"
(cd "$ROOT_DIR/reports-builder" && bash server_setup.sh)
echo ""

echo "========================================"
echo " All services started successfully!"
echo "========================================"
echo ""
echo "  Postgres:             localhost:5432"
echo "  Kafka:                localhost:9092"
echo "  Prometheus:           http://localhost:9090"
echo "  Grafana:              http://localhost:3004  (admin / admin)"
echo "  realty-parser:        http://localhost:9095"
echo "  flats-analyzer:       http://localhost:9093"
echo "  subscription-handler: http://localhost:9094"
echo "  users-notifier API:   http://localhost:8080"
echo "  users-notifier metrics: http://localhost:9091"
echo "  reports-builder:      http://localhost:9096"
