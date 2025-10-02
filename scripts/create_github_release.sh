#!/usr/bin/env bash
set -euo pipefail
# Requires: curl, jq, env GITHUB_TOKEN

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN env var required (with repo scope)." >&2
  exit 1
fi

VERSION_FILE="RELEASE_NOTES_v1.3.0.md"
TAG="v1.3.0"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Release notes file $VERSION_FILE not found" >&2
  exit 1
fi

title_line=$(grep -m1 '^# ' "$VERSION_FILE" | sed 's/^# //')
body=$(sed '1d' "$VERSION_FILE")

# Create or update release (idempotent)
api_repo="https://api.github.com/repos/go-mailer-ltd/go-mailer-push-sdk"
existing=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$api_repo/releases/tags/$TAG" || true)
if echo "$existing" | grep -q '"tag_name"'; then
  release_id=$(echo "$existing" | grep '"id"' | head -1 | sed 's/[^0-9]*//g')
  echo "Updating existing release $release_id" >&2
  curl -s -X PATCH -H "Authorization: Bearer $GITHUB_TOKEN" \
    -d @<(jq -n --arg tag "$TAG" --arg name "$title_line" --arg body "$body" '{tag_name:$tag,name:$name,body:$body,draft:false,prerelease:false}') \
    "$api_repo/releases/$release_id" >/dev/null
else
  echo "Creating new release $TAG" >&2
  curl -s -X POST -H "Authorization: Bearer $GITHUB_TOKEN" \
    -d @<(jq -n --arg tag "$TAG" --arg name "$title_line" --arg body "$body" '{tag_name:$tag,name:$name,body:$body,draft:false,prerelease:false}') \
    "$api_repo/releases" >/dev/null
fi

echo "GitHub release for $TAG updated."