#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_BODY_FILE="$SCRIPT_DIR/output/pr-description.txt"
BODY_FILE="${1:-$DEFAULT_BODY_FILE}"
BASE_BRANCH="${2:-main}"
CURRENT_BRANCH="${3:-$(git branch --show-current)}"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh command is not installed." >&2
  exit 1
fi

if [[ ! -f "$BODY_FILE" ]]; then
  echo "Error: body file not found: $BODY_FILE" >&2
  exit 1
fi

TITLE_LINE="$(grep -m1 '^PRタイトル案:' "$BODY_FILE" || true)"
TITLE="${TITLE_LINE#PRタイトル案: }"

if [[ -z "$TITLE" || "$TITLE" == "$TITLE_LINE" ]]; then
  echo "Error: title line not found. Expected first title line starting with 'PRタイトル案:'" >&2
  exit 1
fi

TMP_BODY_FILE="$(mktemp)"
trap 'rm -f "$TMP_BODY_FILE"' EXIT

tail -n +2 "$BODY_FILE" | sed '1{/^[[:space:]]*$/d;}' > "$TMP_BODY_FILE"

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: gh is not authenticated. Run 'gh auth login' first." >&2
  exit 1
fi

gh pr create \
  --base "$BASE_BRANCH" \
  --head "$CURRENT_BRANCH" \
  --title "$TITLE" \
  --body-file "$TMP_BODY_FILE"

echo "PR created from $BODY_FILE (base=$BASE_BRANCH, head=$CURRENT_BRANCH)."