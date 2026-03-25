#!/bin/bash
set -euo pipefail

# Configuration
EFFECT_SMOL_DIR="${EFFECT_SMOL_DIR:-$HOME/pj/effect/effect/packages/effect}"
EDIT_DIR="node_modules/.patch-edits/effect_patch"

# Directories to copy
DIRS_TO_COPY=("src" "dist")

echo "Creating patch edit directory..."
pnpm patch effect --edit-dir "$EDIT_DIR"

echo "Copying modified directories from $EFFECT_SMOL_DIR..."
for dir in "${DIRS_TO_COPY[@]}"; do
  src="$EFFECT_SMOL_DIR/$dir"
  dest="$EDIT_DIR/$dir"
  if [[ -d "$src" ]]; then
    cp -r "$src"/* "$dest"/
    echo "  Copied: $dir/"
  else
    echo "  Warning: $src not found, skipping"
  fi
done

echo "Committing patch..."
pnpm patch-commit "$EDIT_DIR"

echo "Done! Patch created at patches/effect.patch"
du -h patches/effect.patch
