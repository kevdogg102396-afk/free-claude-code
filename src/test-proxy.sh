#!/bin/bash
export NVIDIA_API_KEY="${NVIDIA_API_KEY}"
export NEMO_MODEL="${NEMO_MODEL:-moonshotai/kimi-k2.5}"
export NEMO_MAX_TOKENS="${NEMO_MAX_TOKENS:-16384}"

echo "Starting proxy..."
source nemo-proxy

echo "=== Models endpoint ==="
curl -s http://127.0.0.1:4000/v1/models

echo ""
echo "=== Anthropic messages endpoint ==="
curl -s -X POST http://127.0.0.1:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: nemo-code-local" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":50,"messages":[{"role":"user","content":"say hi"}]}'

echo ""
echo "=== Done ==="
