#!/bin/bash
# Nemo Code — Local Install (full power, no Docker)
# By ClawdWorks | https://github.com/clawdworks/nemo-code
#
# This installs Nemo Code directly on your machine.
# You get full access to browser automation, MCP servers, filesystem, etc.
# For a sandboxed install, use: curl -fsSL https://nemocode.dev/install.sh | bash

set -e

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${YELLOW}${BOLD}  CLAWD WORKS${RESET}"
echo -e "${CYAN}${BOLD}  nemo-code installer (local)${RESET}"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js not found.${RESET} Install it from https://nodejs.org (v18+)"
    exit 1
fi
NODE_VER=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VER" -lt 18 ]; then
    echo -e "${RED}Node.js v18+ required.${RESET} You have $(node -v)"
    exit 1
fi
echo -e "${GREEN}✓${RESET} Node.js $(node -v)"

# Check Python
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}Python 3 not found.${RESET} Install it from https://python.org"
    exit 1
fi
PYTHON=$(command -v python3 || command -v python)
echo -e "${GREEN}✓${RESET} Python $($PYTHON --version 2>&1)"

# Install Claude Code CLI
echo -e "\n${DIM}Installing Claude Code CLI...${RESET}"
npm install -g @anthropic-ai/claude-code
echo -e "${GREEN}✓${RESET} Claude Code CLI installed"

# Install LiteLLM
echo -e "\n${DIM}Installing LiteLLM proxy...${RESET}"
$PYTHON -m pip install 'litellm[proxy]' --quiet
echo -e "${GREEN}✓${RESET} LiteLLM installed"

# Create Nemo Code directory
NEMO_DIR="$HOME/.nemo-code"
mkdir -p "$NEMO_DIR/workspace/memory"

# Create the launcher script
cat > "$NEMO_DIR/nemo-code" << 'LAUNCHER'
#!/bin/bash
# Nemo Code — ClawdWorks local launcher

NEMO_DIR="$HOME/.nemo-code"
NEMO_MODEL="${NEMO_MODEL:-moonshotai/kimi-k2.5}"
NEMO_MAX_TOKENS="${NEMO_MAX_TOKENS:-16384}"

# Available models
MODELS=(
  "moonshotai/kimi-k2.5"
  "z-ai/glm5"
  "nvidia/nemotron-3-super-120b-a12b"
  "minimaxai/minimax-m2.5"
  "qwen/qwen3.5-397b-a17b"
  "openai/gpt-oss-120b"
)

start_proxy() {
  if [ -z "$NVIDIA_API_KEY" ]; then
    echo "ERROR: NVIDIA_API_KEY not set"
    echo "Get one free at https://build.nvidia.com"
    echo "Then: export NVIDIA_API_KEY='your-key-here'"
    exit 1
  fi

  # Write LiteLLM config
  cat > /tmp/nemo-litellm.yaml << YAML
litellm_settings:
  drop_params: true

model_list:
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: nvidia_nim/${NEMO_MODEL}
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS}
  - model_name: claude-opus-4-6
    litellm_params:
      model: nvidia_nim/${NEMO_MODEL}
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS}
  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: nvidia_nim/${NEMO_MODEL}
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS}
YAML

  litellm --config /tmp/nemo-litellm.yaml --port 4000 --host 127.0.0.1 > /tmp/nemo-litellm.log 2>&1 &
  PROXY_PID=$!

  for i in $(seq 1 30); do
    if curl -s http://127.0.0.1:4000/health > /dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  export ANTHROPIC_BASE_URL="http://127.0.0.1:4000"
  export ANTHROPIC_API_KEY="nemo-code-local"

  # Cleanup proxy on exit
  trap "kill $PROXY_PID 2>/dev/null" EXIT
}

# Splash
clear
echo -e "\033[0;34m     .    *       .          *        .       *      .\033[0m"
echo -e "\033[0;34m  *          .         *           .             *    \033[0m"
echo ""
echo -e "\033[1;33m\033[1m  CLAWD WORKS\033[0m"
echo -e "\033[0;36m\033[1m  nemo-code\033[0m"
echo ""
echo -e "\033[2m  All the security. All the reliability. ALL the ease.\033[0m"
echo ""
echo -e "\033[0;34m     .    *       .          *        .       *      .\033[0m"
echo ""
echo -e "  \033[1;37mModel:\033[0m   \033[0;36m${NEMO_MODEL}\033[0m"
echo -e "  \033[1;37mTokens:\033[0m  \033[0;36m${NEMO_MAX_TOKENS}\033[0m"
echo -e "  \033[1;37mMode:\033[0m    \033[0;36mLocal (full access)\033[0m"
echo ""
echo -e "\033[2m  ────────────────────────────────────────────────────────\033[0m"
echo ""

ACTION="${1:-chat}"
shift 2>/dev/null || true

case "$ACTION" in
  chat)
    start_proxy
    claude \
      --model sonnet \
      --dangerously-skip-permissions \
      "$@"
    ;;
  run)
    start_proxy
    claude -p "$*" \
      --model sonnet \
      --dangerously-skip-permissions \
      --output-format text
    ;;
  models)
    echo "Available NVIDIA NIM models (free tier):"
    echo ""
    for i in "${!MODELS[@]}"; do
      if [ "${MODELS[$i]}" = "${NEMO_MODEL}" ]; then
        echo "  * $((i+1))) ${MODELS[$i]}  (active)"
      else
        echo "    $((i+1))) ${MODELS[$i]}"
      fi
    done
    echo ""
    echo "Switch with: NEMO_MODEL=<model-id> nemo-code"
    ;;
  help|--help|-h)
    echo "Nemo Code by ClawdWorks"
    echo ""
    echo "Usage: nemo-code [command]"
    echo ""
    echo "  chat       Interactive chat (default)"
    echo "  run        Headless — run a prompt and exit"
    echo "  models     List available models"
    echo "  help       Show this help"
    echo ""
    echo "Env vars:"
    echo "  NVIDIA_API_KEY    Your NVIDIA NIM key (required)"
    echo "  NEMO_MODEL        Model (default: moonshotai/kimi-k2.5)"
    echo "  NEMO_MAX_TOKENS   Max tokens (default: 16384)"
    ;;
  *)
    echo "Unknown: $ACTION — run 'nemo-code help'"
    exit 1
    ;;
esac
LAUNCHER

chmod +x "$NEMO_DIR/nemo-code"

# Create default CLAUDE.md
cat > "$NEMO_DIR/workspace/CLAUDE.md" << 'CLAUDEMD'
# Nemo Code Agent

You are Nemo, an AI agent powered by Nemo Code (ClawdWorks). You run free NVIDIA models through the Claude Code CLI framework.

## Rules
- Be direct, helpful, and efficient
- If you don't know something, say so
- You have full access to this machine's filesystem and tools
- For web searches, use the fetch MCP tool or curl

## Capabilities
- Code generation, review, and debugging
- File creation and editing
- Running scripts (Python, Node.js, Bash)
- Web fetching via MCP fetch tool
- Browser automation (if Playwright is installed)
- Git operations
- Any MCP server the user configures
CLAUDEMD

# Symlink to PATH
LINK_DIR="$HOME/.local/bin"
mkdir -p "$LINK_DIR"
ln -sf "$NEMO_DIR/nemo-code" "$LINK_DIR/nemo-code"

echo ""
echo -e "${GREEN}${BOLD}Nemo Code installed!${RESET}"
echo ""
echo -e "  ${WHITE}Next steps:${RESET}"
echo -e "  1. Get a free NVIDIA API key: ${CYAN}https://build.nvidia.com${RESET}"
echo -e "  2. Export it: ${CYAN}export NVIDIA_API_KEY='your-key'${RESET}"
echo -e "  3. Run: ${CYAN}nemo-code${RESET}"
echo ""
echo -e "  Add to your shell profile for persistence:"
echo -e "  ${DIM}echo 'export NVIDIA_API_KEY=\"your-key\"' >> ~/.bashrc${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  CLAWD WORKS${RESET} — ${CYAN}nemo-code${RESET}"
echo -e "${DIM}  All the security. All the reliability. ALL the ease.${RESET}"
echo ""
