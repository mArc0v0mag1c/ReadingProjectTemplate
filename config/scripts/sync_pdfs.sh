#!/bin/bash
# Manually sync compiled PDFs from Output/<reading>/ to Output/Compiled/
# Naming: <foldername>.pdf (e.g., Output/Noise/main.pdf → Compiled/Noise.pdf)
#
# Note: This is a manual fallback. LaTeX Workshop auto-copies on every build.
#
# Usage:
#   ../../config/scripts/sync_pdfs.sh              # sync all
#   ../../config/scripts/sync_pdfs.sh <reading>    # sync one

set -e

COMPILED="Output/Compiled"

if [ ! -d "$COMPILED" ] && [ ! -L "$COMPILED" ]; then
    echo "Error: Output/Compiled/ does not exist."
    echo "Run create_project.sh or create the symlink manually."
    exit 1
fi

sync_reading() {
    local dir="$1"
    local reading="$(basename "$dir")"

    # Skip Compiled/ itself
    [ "$reading" = "Compiled" ] && return

    find "$dir" -maxdepth 1 -name "*.pdf" | while read -r pdf; do
        cp "$pdf" "$COMPILED/${reading}.pdf"
        echo "  $COMPILED/${reading}.pdf"
    done
}

if [ -n "$1" ]; then
    SRC="Output/$1"
    if [ ! -d "$SRC" ]; then
        echo "Error: $SRC does not exist."
        exit 1
    fi
    echo "Syncing PDFs from $SRC:"
    sync_reading "$SRC"
else
    echo "Syncing all PDFs to $COMPILED/:"
    for dir in Output/*/; do
        [ -d "$dir" ] || continue
        sync_reading "$dir"
    done
fi

echo "Done."
