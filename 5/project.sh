#!/bin/bash
set -euo pipefail

DIR="${1:-}"
BACKUP_DIR="$HOME/project_backups"
TIMESTAMP="$(date +%Y-%m-%d_%H-%M)"
ARCHIVE_NAME="projects_${TIMESTAMP}.tar.gz"
LOG_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

if [[ -z "$DIR" ]]; then
    echo "[$LOG_TIME] ERROR: No directory provided"
    echo "Usage: $0 <directory>"
    exit 1
fi

if [[ ! -d "$DIR" ]]; then
    echo "[$LOG_TIME] ERROR: Directory does not exist"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "[$LOG_TIME]"
echo "Target Directory: $DIR"

HTML_FILES=$(find "$DIR" -type f -name "*.html")

for file in $HTML_FILES; do
    if grep -q '<!DOCTYPE html>' "$file" && grep -q '<html' "$file"; then
        echo "PASS: $file"
    else
        echo "FAIL: $file"
    fi
done

HTML_COUNT=$(find "$DIR" -type f -name "*.html" | wc -l)
CSS_COUNT=$(find "$DIR" -type f -name "*.css" | wc -l)
JS_COUNT=$(find "$DIR" -type f -name "*.js" | wc -l)

echo "HTML files: $HTML_COUNT"
echo "CSS files : $CSS_COUNT"
echo "JS files  : $JS_COUNT"

echo "---- Creating Archive ----"

tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" \
    --exclude='*/node_modules' \
    --exclude='*/.git' \
    -C "$DIR" .

echo "Archive created: $BACKUP_DIR/$ARCHIVE_NAME"

find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -print -delete

echo ""

echo "[$(date '+%Y-%m-%d %H:%M:%S')]"
