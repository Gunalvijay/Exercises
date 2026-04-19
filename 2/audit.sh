#!/bin/bash
set -euo pipefail

DIR="${1:-}"

if [[ -z "$DIR" ]]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

if [[ ! -d "$DIR" ]]; then
	echo "Directory does not exist"
	exit 1
fi

total_files=0
file_issues=0
total_issues=0
clean_files=0

while IFS= read -r file; do
	echo "Processing: $file"
	((total_files++)) || true
	file_issues=0
	while IFS= read -r line; do
		echo ""
		echo -e "\033[31mERROR\033[0m $file:$line Missing alt"
        	((file_issues++)) || true
        	((total_issues++)) || true
	done < <(grep -n '<img' "$file" | cut -d: -f1 | grep -v 'alt=' || true)

	input_count=$(grep -ci '<input' "$file" || true)
	label_count=$(grep -ci '<label' "$file" || true)

	if (( input_count > label_count )); then
    		echo -e "\033[33mWARN\033[0m $file Possible missing labels"
    		((total_issues++)) || true
    		((file_issues++)) || true
	fi

	first_h1=$(grep -ni '<h1' "$file" | head -n1 | cut -d: -f1 || echo 0)
	first_h2=$(grep -ni '<h2' "$file" | head -n1 | cut -d: -f1 || echo 0)
	first_h3=$(grep -ni '<h3' "$file" | head -n1 | cut -d: -f1 || echo 0)

	if [[ "$first_h2" -ne 0 && "$first_h1" -eq 0 ]]; then
    		echo -e "\033[31mERROR\033[0m $file:$first_h2 <h2> used before <h1>"
		((total_issues++)) || true
		((file_issues++)) || true
	fi

	if [[ "$first_h3" -ne 0 && "$first_h2" -eq 0 ]]; then
		echo -e "\033[31mERROR\033[0m $file:$first_h3 <h3> used before <h2>"
		((total_issues++)) || true
                ((file_issues++)) || true
	fi

	if (( file_issues == 0 )); then
    		((clean_files++)) || true
	fi

done < <(find "$DIR" -type f -name "*.html")

echo ""
echo "========== SUMMARY =========="
echo "Total files scanned : $total_files"
echo "Total issues found  : $total_issues"
echo "Files with no issues: $clean_files"
