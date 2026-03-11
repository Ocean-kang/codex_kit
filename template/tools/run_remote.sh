#!/usr/bin/env bash
set -euo pipefail

TASK_DIR="${1:?need TASK_DIR}"
OUT_DIR="${2:?need OUT_DIR}"
CONDA_DIR="${3:?need CONDA_DIR}"
REF_REPO="${4:?need REF_REPO}"

export PATH="${CONDA_DIR}/bin:${PATH}"
export PYTHONPATH="${REF_REPO}:${TASK_DIR}:${PYTHONPATH:-}"

cd "$TASK_DIR"

echo "=== ENV ==="
echo "TASK_DIR=$TASK_DIR"
echo "OUT_DIR=$OUT_DIR"
echo "REF_REPO=$REF_REPO"
echo "CONDA_DIR=$CONDA_DIR"
echo "PWD=$(pwd)"
which python || true
python -V || true

echo
echo "=== SYNC_MANIFEST ==="
cat SYNC_MANIFEST.json 2>/dev/null || echo "SYNC_MANIFEST.json missing"

echo
echo "=== FILE HASHES ==="
sha256sum SPEC.md README.md tools/run_remote.sh tools/standard_auto.sh 2>/dev/null || true
find src -maxdepth 2 -type f | sort | xargs -r sha256sum || true

mkdir -p "$OUT_DIR"

echo
echo "=== TASK RUN ==="
# 这里是你每个任务真正执行的地方
python -m src.projector --out "$OUT_DIR" --seed 123

echo
echo "=== metrics.json ==="
cat "$OUT_DIR/metrics.json"