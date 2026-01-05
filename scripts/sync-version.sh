#!/bin/bash
# sync-version.sh - Update all Arcium version references across the project
# Usage: ./scripts/sync-version.sh 0.5.4

set -eo pipefail

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/sync-version.sh <version>"
  echo "Example: ./scripts/sync-version.sh 0.5.4"
  exit 1
fi

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z (e.g., 0.5.4)"
  exit 1
fi

echo "Syncing all files to Arcium version: $VERSION"
echo ""

# Get the repo root (parent of scripts directory)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Update action.yaml - ONLY the arcium-version default (not node/solana/anchor)
echo "Updating action.yaml (arcium-version only)..."
awk -v ver="$VERSION" '
  /arcium-version:/ { in_arcium=1 }
  in_arcium && /default:/ {
    sub(/default: .*/, "default: '"'"'" ver "'"'"'")
    in_arcium=0
  }
  { print }
' action.yaml > action.yaml.tmp && mv action.yaml.tmp action.yaml

# Update test_project/package.json
echo "Updating test_project/package.json..."
if command -v jq &> /dev/null; then
  jq ".dependencies[\"@arcium-hq/client\"] = \"$VERSION\"" test_project/package.json > test_project/package.json.tmp
  mv test_project/package.json.tmp test_project/package.json
else
  echo "Error: jq is required but not installed"
  exit 1
fi

# Update test_project/programs/test_project/Cargo.toml
echo "Updating test_project/programs/test_project/Cargo.toml..."
sed -i.bak 's/arcium-client = { default-features = false, version = "[^"]*"/arcium-client = { default-features = false, version = "'"$VERSION"'"/' test_project/programs/test_project/Cargo.toml
sed -i.bak 's/arcium-macros = "[^"]*"/arcium-macros = "'"$VERSION"'"/' test_project/programs/test_project/Cargo.toml
sed -i.bak 's/arcium-anchor = "[^"]*"/arcium-anchor = "'"$VERSION"'"/' test_project/programs/test_project/Cargo.toml
rm -f test_project/programs/test_project/Cargo.toml.bak

# Update test_project/encrypted-ixs/Cargo.toml
echo "Updating test_project/encrypted-ixs/Cargo.toml..."
sed -i.bak 's/arcis-imports = "[^"]*"/arcis-imports = "'"$VERSION"'"/' test_project/encrypted-ixs/Cargo.toml
rm -f test_project/encrypted-ixs/Cargo.toml.bak

# Update CLAUDE.md
echo "Updating CLAUDE.md..."
sed -i.bak 's/`arcium-version` | No | `[^`]*`/`arcium-version` | No | `'"$VERSION"'`/' CLAUDE.md
rm -f CLAUDE.md.bak

# Regenerate lock files
echo ""
echo "Regenerating Cargo.lock..."
rm -f test_project/Cargo.lock
(cd test_project && cargo generate-lockfile 2>/dev/null || cargo update)

echo "Regenerating yarn.lock..."
rm -f test_project/yarn.lock
(cd test_project && yarn install)

echo ""
echo "✓ Updated all files to version $VERSION"
echo ""
echo "Changes made:"
git diff --stat 2>/dev/null || echo "(not a git repo or no changes)"
