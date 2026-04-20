#!/bin/bash
set -e

[ -d './src' ] || { echo 'ERROR: src/ not found'; exit 1 }

trap 'echo "Stop.."; docker compose -f docker-compose.dev.yml down'INT

docker compose -f docker-compose.dev.yml up

echo 'Dev server running at http://localhost:8080'
