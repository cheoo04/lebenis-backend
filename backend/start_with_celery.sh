#!/bin/bash
# Script pour 1 seul service Render Starter (7$/mois)
# Web + Worker + Beat combinés

set -e

echo "🚀 Démarrage Django + Celery Worker + Beat"

cleanup() {
    echo "🛑 Arrêt..."
    pkill -P $$ || true
    exit
}
trap cleanup SIGTERM SIGINT

# Worker
echo "🔧 Celery Worker..."
celery -A config worker \
    --loglevel=info \
    --concurrency=1 \
    --max-tasks-per-child=50 \
    --max-memory-per-child=100000 \
    --logfile=/tmp/celery-worker.log &
WORKER_PID=$!

# Beat
echo "⏰ Celery Beat..."
celery -A config beat \
    --loglevel=info \
    --max-interval=15 \
    --logfile=/tmp/celery-beat.log &
BEAT_PID=$!

sleep 5

if ! kill -0 $WORKER_PID 2>/dev/null; then
    echo "❌ Worker failed"
    cat /tmp/celery-worker.log
    exit 1
fi
echo "✅ Worker (PID: $WORKER_PID)"

if ! kill -0 $BEAT_PID 2>/dev/null; then
    echo "❌ Beat failed"
    cat /tmp/celery-beat.log
    exit 1
fi
echo "✅ Beat (PID: $BEAT_PID)"

# Gunicorn
echo "🌐 Gunicorn..."
exec gunicorn config.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 1 \
    --threads 2 \
    --worker-class gthread \
    --max-requests 1000 \
    --timeout 120 \
    --access-logfile - \
    --error-logfile -
