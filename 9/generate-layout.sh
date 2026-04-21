#!/bin/bash
set -euo pipefail

# -------------------------------
# Input Parsing
# -------------------------------
TITLE="${1:-}"
COLS="${2:-}"
THEME="${3:-}"
shift 3 || true
SECTIONS=("$@")

# -------------------------------
# Validation
# -------------------------------
if [[ -z "$TITLE" || -z "$COLS" ]]; then
  echo "Usage: $0 <title> <columns:1-4> <theme> <sections...>"
  exit 1
fi

# Validate columns
if ! [[ "$COLS" =~ ^[0-9]+$ ]] || [ "$COLS" -lt 1 ] || [ "$COLS" -gt 4 ]; then
  echo "ERROR: columns must be between 1 and 4"
  exit 1
fi

# Validate theme
case "$THEME" in
  blue)
    PRIMARY="#1e3a8a"
    ;;
  green)
    PRIMARY="#065f46"
    ;;
  red)
    PRIMARY="#7f1d1d"
    ;;
  *)
    echo "WARNING: Invalid theme '$THEME'. Defaulting to blue."
    PRIMARY="#1e3a8a"
    ;;
esac

# Default sections if none provided
if [ "${#SECTIONS[@]}" -eq 0 ]; then
  SECTIONS=("Section 1" "Section 2")
fi

# -------------------------------
# Prepare Output
# -------------------------------
mkdir -p output
FILENAME="output/${TITLE// /_}.html"

# -------------------------------
# Generate HTML
# -------------------------------
cat > "$FILENAME" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${TITLE}</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: Arial, sans-serif;
    }

    body {
      background: #f9fafb;
      color: #111;
    }

    header, footer {
      background: ${PRIMARY};
      color: white;
      text-align: center;
      padding: 1rem;
    }

    main {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1rem;
      padding: 1rem;
    }

    section {
      background: white;
      padding: 1rem;
      border: 1px solid #ddd;
      border-radius: 8px;
    }

    @media (min-width: 768px) {
      main {
        grid-template-columns: repeat(${COLS}, 1fr);
      }
    }
  </style>
</head>
<body>

<header>
  <h1>${TITLE}</h1>
</header>

<main>
EOF

# -------------------------------
# Generate Sections Dynamically
# -------------------------------
for section in "${SECTIONS[@]}"; do
cat >> "$FILENAME" <<EOF
  <section>
    <h2>${section}</h2>
    <p>This is the ${section} section.</p>
  </section>
EOF
done

# -------------------------------
# Footer
# -------------------------------
cat >> "$FILENAME" <<EOF
</main>

<footer>
  <p>&copy; 2026 ${TITLE}</p>
</footer>

</body>
</html>
EOF

echo "✔ Generated: $FILENAME"