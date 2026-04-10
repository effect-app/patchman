#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./patch-package-dir.sh <package-name> <source-dir> [target-dir]

Creates a pnpm patch edit directory for the package, replaces target-dir inside the
patched package with source-dir, and commits the patch.

Examples:
  ./patch-package-dir.sh @tanstack/query-core ~/pj/tanstack/tanstack-query/packages/query-core/build
  ./patch-package-dir.sh effect ~/pj/effect/effect/packages/effect/dist dist
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage >&2
  exit 1
fi

PACKAGE_NAME="$1"
SOURCE_DIR="${2%/}"
TARGET_DIR="${3:-$(basename "$SOURCE_DIR")}"
SAFE_NAME="$(printf '%s' "$PACKAGE_NAME" | tr '@/ ' '___')"
EDIT_DIR="node_modules/.patch-edits/${SAFE_NAME}_patch"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

rm -rf "$EDIT_DIR"

echo "Creating patch edit directory for $PACKAGE_NAME..."
pnpm patch "$PACKAGE_NAME" --edit-dir "$EDIT_DIR"

DEST_DIR="$EDIT_DIR/$TARGET_DIR"
rm -rf "$DEST_DIR"
mkdir -p "$(dirname "$DEST_DIR")"

echo "Replacing $TARGET_DIR from $SOURCE_DIR..."
cp -a "$SOURCE_DIR" "$DEST_DIR"

echo "Committing patch..."
pnpm patch-commit "$EDIT_DIR"

echo "Patch committed for $PACKAGE_NAME"