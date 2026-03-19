#!/bin/bash
# Sync compiled PDFs from Output/ to Dropbox
# Usage: ../scripts/sync_pdfs.sh [reading-name]
#   No args: syncs all PDFs from Output/
#   With arg: syncs PDFs from Output/<reading-name>/

set -e

# Find Dropbox path from Literature/ symlink
if [ -L "Literature" ]; then
    DRIVE_PROJECT_PATH="$(dirname "$(readlink Literature)")"
else
    echo "Error: Literature/ is not a symlink — no Dropbox configured for this project."
    exit 1
fi

DROPBOX_OUTPUT="$DRIVE_PROJECT_PATH/Output"
mkdir -p "$DROPBOX_OUTPUT"

if [ -n "$1" ]; then
    # Sync specific reading
    SRC="Output/$1"
    if [ ! -d "$SRC" ]; then
        echo "Error: $SRC does not exist."
        exit 1
    fi
    mkdir -p "$DROPBOX_OUTPUT/$1"
    find "$SRC" -name "*.pdf" -exec cp {} "$DROPBOX_OUTPUT/$1/" \;
    echo "Synced PDFs from $SRC -> $DROPBOX_OUTPUT/$1/"
else
    # Sync all readings
    COUNT=0
    for dir in Output/*/; do
        [ -d "$dir" ] || continue
        READING="$(basename "$dir")"
        mkdir -p "$DROPBOX_OUTPUT/$READING"
        find "$dir" -name "*.pdf" -exec cp {} "$DROPBOX_OUTPUT/$READING/" \;
        COUNT=$((COUNT + 1))
    done
    echo "Synced PDFs from $COUNT reading(s) -> $DROPBOX_OUTPUT/"
fi
