#!/usr/bin/env bash
set -euo pipefail
# Requires: curl, jq
# Auth priority:
#  1. --token/-t <token> CLI argument
#  2. First positional arg if it looks like a token
#  3. GITHUB_TOKEN env var
#  4. gh CLI auth (if available)  (not yet implemented – placeholder for future)

usage() {
  cat <<EOF
Usage: $0 [--token <token>] | [<token>]

Creates or updates the GitHub release for the current version (hard‑coded TAG below).

Authentication:
  Provide a classic/repo-scoped token via --token, positional arg, or GITHUB_TOKEN env var.

Environment variables:
  GITHUB_TOKEN   Personal access token (repo scope) if not passed as an argument.

Examples:
  export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
  $0
  $0 --token ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
  $0 ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
EOF
}

TOKEN="${GITHUB_TOKEN:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--token)
      shift
      TOKEN="${1:-}"
      shift || true
      ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      # If token not set yet, treat first free arg as token
      if [[ -z "$TOKEN" ]]; then
        TOKEN="$1"; shift
      else
        echo "Unexpected argument: $1" >&2
        usage; exit 1
      fi
      ;;
  esac
done

if [[ -z "${TOKEN}" ]]; then
  echo "No GitHub token provided. Use --token or set GITHUB_TOKEN." >&2
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
existing=$(curl -s -H "Authorization: Bearer $TOKEN" "$api_repo/releases/tags/$TAG" || true)
if echo "$existing" | grep -q '"tag_name"'; then
  release_id=$(echo "$existing" | jq -r '.id')
  if [[ -z "$release_id" || "$release_id" == "null" ]]; then
    echo "Failed to parse existing release id" >&2
    exit 1
  fi
  echo "Updating existing release id=$release_id tag=$TAG" >&2
  curl -s -X PATCH -H "Authorization: Bearer $TOKEN" \
    -d @<(jq -n --arg tag "$TAG" --arg name "$title_line" --arg body "$body" '{tag_name:$tag,name:$name,body:$body,draft:false,prerelease:false}') \
    "$api_repo/releases/$release_id" >/dev/null
else
  echo "Creating new release $TAG" >&2
  curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -d @<(jq -n --arg tag "$TAG" --arg name "$title_line" --arg body "$body" '{tag_name:$tag,name:$name,body:$body,draft:false,prerelease:false}') \
    "$api_repo/releases" >/dev/null
fi

echo "GitHub release for $TAG updated."