#!/usr/bin/env bash
# Start the Gemma-3-12B llama.cpp server that the *_gemma.ipynb notebooks call
# at http://127.0.0.1:8080. Runs in the background and keeps running after the
# terminal closes. Usage: bash scripts/start_gemma_server.sh
set -euo pipefail

MODEL="${MODEL:-$HOME/hf_data/gguf/gemma-3-12b-it-Q4_K_M.gguf}"
PORT="${PORT:-8080}"
LOG="${LOG:-$HOME/hf_data/llama-server.log}"

# llama-server binary and CUDA libraries bundled with LM Studio
BACKENDS=/opt/LM-Studio/resources/app/.webpack/bin/extensions/backends
BIN_DIR="$BACKENDS/llama.cpp-linux-x86_64-nvidia-cuda-avx2-2.24.0"
CUDA_LIBS="$BACKENDS/vendor/linux-llama-cuda-vendor-v1"

if curl -sf "http://127.0.0.1:$PORT/health" >/dev/null; then
  echo "Server is already running on port $PORT."
  exit 0
fi

[ -f "$MODEL" ] || { echo "Model not found: $MODEL"; exit 1; }
[ -x "$BIN_DIR/llama-server" ] || { echo "llama-server not found in $BIN_DIR"; exit 1; }

cd "$BIN_DIR"
LD_LIBRARY_PATH="$BIN_DIR:$CUDA_LIBS${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  setsid nohup ./llama-server -m "$MODEL" --host 127.0.0.1 --port "$PORT" -ngl 99 -c 8192 \
  > "$LOG" 2>&1 < /dev/null &

echo "Starting server (log: $LOG)..."
for _ in $(seq 60); do
  if curl -sf "http://127.0.0.1:$PORT/health" >/dev/null; then
    echo "Server is ready at http://127.0.0.1:$PORT"
    exit 0
  fi
  sleep 3
done

echo "Server did not become ready in 3 minutes. Last log lines:"
tail -20 "$LOG"
exit 1
