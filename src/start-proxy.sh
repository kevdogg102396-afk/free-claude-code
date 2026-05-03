#!/bin/bash
# Start LiteLLM proxy in the background
# Translates Anthropic API calls from CC CLI to NVIDIA NIM OpenAI-compatible format

case "${NEMO_MODEL:-}" in
  moonshotai/kimi-k2.5) NEMO_MODEL="moonshotai/kimi-k2.6" ;;
  z-ai/glm-5.1) NEMO_MODEL="z-ai/glm5.1" ;;
esac
MODEL="${NEMO_MODEL:-moonshotai/kimi-k2.6}"

# LiteLLM config: route Anthropic model requests to NVIDIA NIM
cat > /tmp/litellm_config.yaml << YAML
litellm_settings:
  drop_params: true

model_list:
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: nvidia_nim/${MODEL}
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS:-16384}
  - model_name: claude-opus-4-7
    litellm_params:
      model: nvidia_nim/qwen/qwen3.5-397b-a17b
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS:-16384}
  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: nvidia_nim/minimaxai/minimax-m2.7
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS:-16384}
YAML

# Start LiteLLM proxy on port 4000
litellm --config /tmp/litellm_config.yaml --port 4000 --host 127.0.0.1 > /tmp/litellm.log 2>&1 &
PROXY_PID=$!

# Wait for proxy to be ready (use /health/readiness  fast, doesn't call models)
for i in $(seq 1 60); do
  if curl -s --max-time 2 http://127.0.0.1:4000/health/readiness > /dev/null 2>&1; then
    echo "Proxy ready (PID: $PROXY_PID)"
    return 0 2>/dev/null || exit 0
  fi
  sleep 1
done

echo "ERROR: LiteLLM proxy failed to start. Check /tmp/litellm.log"
cat /tmp/litellm.log
exit 1
