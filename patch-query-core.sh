#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./patch-query-core.sh

Workflow:
1. git fetch --tags in the TanStack Query repo
2. resolve patchman's installed @tanstack/query-core version via pnpm
3. checkout the matching release tag
3. run pnpm clean && pnpm build in packages/query-core
4. regenerate the local pnpm patch in this repo

Environment overrides:
  PATCHMAN_DIR       (default: script directory)
  TANSTACK_REPO_DIR   (default: $HOME/pj/tanstack/tanstack-query)
  QUERY_CORE_PKG_DIR  (default: <repo>/packages/query-core)
  QUERY_CORE_BUILD_DIR(default: <pkg>/build)
EOF
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCHMAN_DIR="${PATCHMAN_DIR:-$SCRIPT_DIR}"
TANSTACK_REPO_DIR="${TANSTACK_REPO_DIR:-$HOME/pj/tanstack/tanstack-query}"
QUERY_CORE_PKG_DIR="${QUERY_CORE_PKG_DIR:-$TANSTACK_REPO_DIR/packages/query-core}"
QUERY_CORE_BUILD_DIR="${QUERY_CORE_BUILD_DIR:-$QUERY_CORE_PKG_DIR/build}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -d "$TANSTACK_REPO_DIR/.git" ]]; then
  echo "TanStack repo not found at: $TANSTACK_REPO_DIR" >&2
  exit 1
fi

if [[ ! -d "$QUERY_CORE_PKG_DIR" ]]; then
  echo "query-core package directory not found at: $QUERY_CORE_PKG_DIR" >&2
  exit 1
fi

if [[ ! -f "$PATCHMAN_DIR/pnpm-lock.yaml" ]]; then
  echo "pnpm-lock.yaml not found at: $PATCHMAN_DIR/pnpm-lock.yaml" >&2
  exit 1
fi

TARGET_VERSION="$({
  pnpm --dir "$PATCHMAN_DIR" ls @tanstack/query-core --depth -1 --json \
    | node -e '
const fs = require("fs")
const input = fs.readFileSync(0, "utf8")
const data = JSON.parse(input)
const version = data?.[0]?.dependencies?.["@tanstack/query-core"]?.version || ""
process.stdout.write(version)
'
} || true)"

if [[ -z "$TARGET_VERSION" ]]; then
  echo "Could not resolve @tanstack/query-core version via pnpm in $PATCHMAN_DIR" >&2
  exit 1
fi

echo "Fetching tags in $TANSTACK_REPO_DIR..."
git -C "$TANSTACK_REPO_DIR" fetch --tags --force

TAG_CANDIDATE_V="v$TARGET_VERSION"
TAG_CANDIDATE_PLAIN="$TARGET_VERSION"
TARGET_TAG=""

if git -C "$TANSTACK_REPO_DIR" rev-parse -q --verify "refs/tags/$TAG_CANDIDATE_V" >/dev/null; then
  TARGET_TAG="$TAG_CANDIDATE_V"
elif git -C "$TANSTACK_REPO_DIR" rev-parse -q --verify "refs/tags/$TAG_CANDIDATE_PLAIN" >/dev/null; then
  TARGET_TAG="$TAG_CANDIDATE_PLAIN"
fi

if [[ -z "$TARGET_TAG" ]]; then
  echo "No git tag found for query-core version $TARGET_VERSION in $TANSTACK_REPO_DIR" >&2
  exit 1
fi

echo "Checking out release tag for installed version $TARGET_VERSION: $TARGET_TAG"
git -C "$TANSTACK_REPO_DIR" checkout "$TARGET_TAG"

echo "Running pnpm clean && pnpm build in $QUERY_CORE_PKG_DIR..."
pnpm -C "$QUERY_CORE_PKG_DIR" clean
pnpm -C "$QUERY_CORE_PKG_DIR" build

"$(dirname "$0")/patch-package-dir.sh" \
  "@tanstack/query-core" \
  "$QUERY_CORE_BUILD_DIR" \
  build