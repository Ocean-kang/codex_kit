#!/usr/bin/env bash
set -euo pipefail

TASK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REMOTE_HOST="${REMOTE_HOST:?need REMOTE_HOST}"
REMOTE_BASE_DIR="${REMOTE_BASE_DIR:?need REMOTE_BASE_DIR}"
REMOTE_REF_REPO="${REMOTE_REF_REPO:?need REMOTE_REF_REPO}"
CONDA_DIR="${CONDA_DIR:?need CONDA_DIR}"
LOCAL_LOG_BASE="${LOCAL_LOG_BASE:-$TASK_DIR/logs}"

RUN_ID="$(date '+%Y%m%d_%H%M%S')"
TASK_NAME="$(basename "$TASK_DIR")"
REMOTE_TASK_DIR="${REMOTE_BASE_DIR}/${TASK_NAME}"
REMOTE_OUT_DIR="${REMOTE_TASK_DIR}/outputs/${RUN_ID}"

LOCAL_MASTER_LOG="${LOCAL_LOG_BASE}/local_master/standard_auto_${RUN_ID}.log"
LOCAL_REMOTE_DIR="${LOCAL_LOG_BASE}/remote/${RUN_ID}"
LOCAL_LOCAL_DIR="${LOCAL_LOG_BASE}/local/${RUN_ID}"

mkdir -p "$(dirname "$LOCAL_MASTER_LOG")" "$LOCAL_REMOTE_DIR" "$LOCAL_LOCAL_DIR"

exec > >(tee -a "$LOCAL_MASTER_LOG") 2>&1

echo "[info] TASK_DIR=$TASK_DIR"
echo "[info] REMOTE_HOST=$REMOTE_HOST"
echo "[info] REMOTE_TASK_DIR=$REMOTE_TASK_DIR"
echo "[info] REMOTE_REF_REPO=$REMOTE_REF_REPO"
echo "[info] CONDA_DIR=$CONDA_DIR"
echo "[info] RUN_ID=$RUN_ID"

echo "[step] prepare manifest"
bash "$TASK_DIR/tools/prepare_manifest.sh" "$TASK_DIR" "$REMOTE_REF_REPO" "$TASK_NAME" \
  | tee "$LOCAL_LOCAL_DIR/manifest.log"

echo "[step] sync to remote"
bash "$TASK_DIR/tools/sync_to_remote.sh" "$TASK_DIR" "$REMOTE_HOST" "$REMOTE_TASK_DIR"

echo "[step] remote run"
ssh "$REMOTE_HOST" "
  set -euo pipefail
  mkdir -p '$REMOTE_OUT_DIR'
  bash '$REMOTE_TASK_DIR/tools/run_remote.sh' \
    '$REMOTE_TASK_DIR' \
    '$REMOTE_OUT_DIR' \
    '$CONDA_DIR' \
    '$REMOTE_REF_REPO'
" | tee "$LOCAL_REMOTE_DIR/run.log"

echo "[step] fetch remote outputs"
mkdir -p "$LOCAL_REMOTE_DIR/output_files"
scp -r "$REMOTE_HOST:$REMOTE_OUT_DIR/." "$LOCAL_REMOTE_DIR/output_files/" || true

echo "[step] refresh log/last_run"
mkdir -p "$TASK_DIR/log/last_run"
cp -f "$LOCAL_REMOTE_DIR/run.log" "$TASK_DIR/log/last_run/run.log" || true
cp -f "$LOCAL_REMOTE_DIR/output_files/metrics.json" "$TASK_DIR/log/last_run/metrics.json" || true

echo "[done]"
echo "[logs] local master: $LOCAL_MASTER_LOG"
echo "[logs] local run:    $LOCAL_LOCAL_DIR"
echo "[logs] remote run:   $LOCAL_REMOTE_DIR"