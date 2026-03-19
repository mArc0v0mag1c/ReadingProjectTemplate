#!/bin/bash
# Auto-copy compiled PDF to Output/Compiled/<foldername>.pdf
# Called by LaTeX Workshop after each successful build.
#
# Usage: copy_compiled.sh <path-to-compiled-pdf>
# Example: Output/Noise/main.pdf → Output/Compiled/Noise.pdf

set -e

PDF_PATH="$1"

if [ -z "$PDF_PATH" ] || [ ! -f "$PDF_PATH" ]; then
    exit 0
fi

DIR="$(cd "$(dirname "$PDF_PATH")" && pwd)"
READING="$(basename "$DIR")"
COMPILED="$(dirname "$DIR")/Compiled"

if [ ! -d "$COMPILED" ] && [ ! -L "$COMPILED" ]; then
    exit 0
fi

cp "$PDF_PATH" "$COMPILED/${READING}.pdf"
