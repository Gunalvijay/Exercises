#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Log file not found!"
  exit 1
fi

echo "===== Nginx Log Analysis ====="

total_requests=$(wc -l < "$LOG_FILE")
echo "Total Requests: $total_requests"

unique_ips=$(awk '{print $1}' "$LOG_FILE" | sort -u | wc -l)
echo "Unique Visitors (IPs): $unique_ips"

echo "Most Requested Paths:"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5

echo "404 Error Paths:"
grep ' 404 ' "$LOG_FILE" | awk '{print $7}' | sort | uniq

form_submits=$(grep 'POST /submit' "$LOG_FILE" | wc -l)
echo "Form Submission Attempts: $form_submits"