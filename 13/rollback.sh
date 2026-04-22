#!/bin/bash

ENV=$1
DEPLOY_DIR="/tmp/deployments/$ENV"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [[ -z "$ENV" ]]; then
    echo "Usage: ./rollback.sh <staging|production>"
    exit 1
fi

echo "$TIMESTAMP - Starting rollback for $ENV"

FILES=$(ls -t "$DEPLOY_DIR"/*.tar.gz 2>/dev/null | head -3)

if [ -z "$FILES" ]; then
    echo "$TIMESTAMP - No deployments found"
    exit 1
fi

echo "Last 3 deployments:"
echo "$FILES"

PREVIOUS=$(echo "$FILES" | sed -n '2p')

if [ -z "$PREVIOUS" ]; then
    echo "$TIMESTAMP - No previous version to rollback"
    exit 1
fi

echo "$TIMESTAMP - Rolling back to: $PREVIOUS"

rm -rf "$DEPLOY_DIR"/*.html "$DEPLOY_DIR"/*.css

tar -xzf "$PREVIOUS" -C "$DEPLOY_DIR"

if [ -f "$DEPLOY_DIR/index.html" ] && ls "$DEPLOY_DIR"/*.css >/dev/null 2>&1; then
    echo "$TIMESTAMP - ROLLBACK SUCCESS"
    exit 0
else
    echo "$TIMESTAMP - ROLLBACK FAILED"
    exit 1
fi