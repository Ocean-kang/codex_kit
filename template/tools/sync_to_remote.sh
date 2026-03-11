#!/usr/bin/env bash
set -euo pipefail

LOCAL_TASK_DIR="${1:?need LOCAL_TASK_DIR}"
REMOTE_HOST="${2:?need REMOTE_HOST}"
REMOTE_TASK_DIR="${3:?need REMOTE_TASK_DIR}"

if command -v rsync >/dev/null 2>&1; then
  echo "[sync] using rsync"
  rsync -az --delete \
    --exclude '.git' \
    --exclude '__pycache__' \
    --exclude '.pytest_cache' \
    --exclude 'outputs' \
    --exclude 'log/last_run' \
    "${LOCAL_TASK_DIR}/" \
    "${REMOTE_HOST}:${REMOTE_TASK_DIR}/"
else
  echo "[sync] rsync not found, fallback to tar over ssh"
  ssh "$REMOTE_HOST" "mkdir -p '$REMOTE_TASK_DIR'"
  tar \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='.pytest_cache' \
    --exclude='outputs' \
    --exclude='log/last_run' \
    -czf - -C "$LOCAL_TASK_DIR" . \
  | ssh "$REMOTE_HOST" "tar -xzf - -C '$REMOTE_TASK_DIR'"
fi

echo "[ok] synced to ${REMOTE_HOST}:${REMOTE_TASK_DIR}"