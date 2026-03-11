#!/usr/bin/env bash
set -euo pipefail

TASK_DIR="${1:-$(pwd)}"
REF_REPO="${2:-}"
TASK_NAME="${3:-$(basename "$TASK_DIR")}"

cd "$TASK_DIR"

sha256_file() {
  local f="$1"
  if [ -f "$f" ]; then
    sha256sum "$f" | awk '{print $1}'
  else
    echo ""
  fi
}

REF_VERSION=""
if [ -n "$REF_REPO" ] && [ -d "$REF_REPO/.git" ]; then
  REF_VERSION="$(git -C "$REF_REPO" rev-parse HEAD 2>/dev/null || true)"
fi

cat > SYNC_MANIFEST.json <<EOF
{
  "task_name": "${TASK_NAME}",
  "generated_at": "$(date '+%Y-%m-%dT%H:%M:%S%z')",
  "spec_sha256": "$(sha256_file SPEC.md)",
  "run_remote_sha256": "$(sha256_file tools/run_remote.sh)",
  "standard_auto_sha256": "$(sha256_file tools/standard_auto.sh)",
  "readme_sha256": "$(sha256_file README.md)",
  "ref_repo": "${REF_REPO}",
  "ref_repo_version": "${REF_VERSION}"
}
EOF

echo "[ok] wrote $TASK_DIR/SYNC_MANIFEST.json"
cat SYNC_MANIFEST.json