#!/bin/bash
# validate-versions.sh - Validate that all Arcium version references are consistent
# Used in CI to catch version mismatches before merge

set -e

# Get the repo root (parent of scripts directory)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "Checking version consistency..."
echo ""

# Extract versions from each file
ACTION_V=$(grep 'arcium-version:' action.yaml | grep default | sed "s/.*default: '//" | sed "s/'//")
PKG_V=$(grep '@arcium-hq/client' test_project/package.json | sed 's/.*: "//' | tr -d '",')
CARGO_CLIENT=$(grep 'arcium-client' test_project/programs/test_project/Cargo.toml | sed 's/.*version = "//' | tr -d '"' | tr -d '}')
CARGO_MACROS=$(grep 'arcium-macros' test_project/programs/test_project/Cargo.toml | sed 's/.*= "//' | tr -d '"')
CARGO_ANCHOR=$(grep 'arcium-anchor' test_project/programs/test_project/Cargo.toml | sed 's/.*= "//' | tr -d '"')
ARCIS=$(grep 'arcis-imports' test_project/encrypted-ixs/Cargo.toml | sed 's/.*= "//' | tr -d '"')

echo "  action.yaml (arcium-version):     $ACTION_V"
echo "  package.json (@arcium-hq/client): $PKG_V"
echo "  Cargo.toml (arcium-client):       $CARGO_CLIENT"
echo "  Cargo.toml (arcium-macros):       $CARGO_MACROS"
echo "  Cargo.toml (arcium-anchor):       $CARGO_ANCHOR"
echo "  Cargo.toml (arcis-imports):       $ARCIS"
echo ""

ERRORS=0

# Check action.yaml matches package.json
if [ "$ACTION_V" != "$PKG_V" ]; then
  echo "::error::Version mismatch: action.yaml ($ACTION_V) != package.json ($PKG_V)"
  ERRORS=$((ERRORS+1))
fi

# Check action.yaml matches Cargo arcium-* crates
if [ "$ACTION_V" != "$CARGO_CLIENT" ]; then
  echo "::error::Version mismatch: action.yaml ($ACTION_V) != arcium-client ($CARGO_CLIENT)"
  ERRORS=$((ERRORS+1))
fi

if [ "$ACTION_V" != "$CARGO_MACROS" ]; then
  echo "::error::Version mismatch: action.yaml ($ACTION_V) != arcium-macros ($CARGO_MACROS)"
  ERRORS=$((ERRORS+1))
fi

if [ "$ACTION_V" != "$CARGO_ANCHOR" ]; then
  echo "::error::Version mismatch: action.yaml ($ACTION_V) != arcium-anchor ($CARGO_ANCHOR)"
  ERRORS=$((ERRORS+1))
fi

if [ "$ACTION_V" != "$ARCIS" ]; then
  echo "::error::Version mismatch: action.yaml ($ACTION_V) != arcis-imports ($ARCIS)"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "Found $ERRORS version mismatch(es)!"
  echo "Run ./scripts/sync-version.sh <version> to fix."
  exit 1
fi

echo "✓ All versions consistent: $ACTION_V"
