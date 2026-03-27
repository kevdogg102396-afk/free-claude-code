#!/bin/bash
# Nemo Code — Universal Installer
# By ClawdWorks | One command. Free AI coding agent.
#
# curl -fsSL https://nemocode.dev/install.sh | bash

set -e

# Colors
CYAN='\033[0;36m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# Splash
clear
echo ""
echo -e "${BLUE}     .    *       .          *        .       *      .${RESET}"
echo -e "${BLUE}  *          .         *           .             *    ${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}   ██████╗██╗      █████╗ ██╗    ██╗██████╗ ${RESET}"
echo -e "${YELLOW}${BOLD}  ██╔════╝██║     ██╔══██╗██║    ██║██╔══██╗${RESET}"
echo -e "${YELLOW}${BOLD}  ██║     ██║     ███████║██║ █╗ ██║██║  ██║${RESET}"
echo -e "${YELLOW}${BOLD}  ██║     ██║     ██╔══██║██║███╗██║██║  ██║${RESET}"
echo -e "${YELLOW}${BOLD}  ╚██████╗███████╗██║  ██║╚███╔███╔╝██████╔╝${RESET}"
echo -e "${YELLOW}${BOLD}   ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═════╝ ${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  ██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗███████╗${RESET}"
echo -e "${YELLOW}${BOLD}  ██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝${RESET}"
echo -e "${YELLOW}${BOLD}  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ ███████╗${RESET}"
echo -e "${YELLOW}${BOLD}  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ ╚════██║${RESET}"
echo -e "${YELLOW}${BOLD}  ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗███████║${RESET}"
echo -e "${YELLOW}${BOLD}   ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝${RESET}"
echo ""
echo -e "${CYAN}${BOLD}                  n e m o - c o d e${RESET}"
echo ""
echo -e "${DIM}       All the security. All the reliability. ALL the ease.${RESET}"
echo ""
echo -e "${BLUE}     .    *       .          *        .       *      .${RESET}"
echo ""
echo -e "  ${WHITE}Free AI coding agent powered by NVIDIA's best open models.${RESET}"
echo -e "  ${WHITE}Built on the Claude Code CLI framework (Apache 2.0).${RESET}"
echo ""
echo -e "${DIM}  ────────────────────────────────────────────────────────${RESET}"
echo ""

# ─── Step 1: NVIDIA API Key ──────────────────────────────────────────

echo -e "${YELLOW}${BOLD}  [1/4] NVIDIA API Key${RESET}"
echo ""

if [ -n "$NVIDIA_API_KEY" ]; then
    echo -e "  ${GREEN}✓${RESET} Found NVIDIA_API_KEY in your environment"
    echo -e "  ${DIM}Key: ...${NVIDIA_API_KEY: -8}${RESET}"
    echo ""
    echo -n "  Use this key? [Y/n]: "
    read -r USE_EXISTING
    if [[ "$USE_EXISTING" =~ ^[Nn] ]]; then
        NVIDIA_API_KEY=""
    fi
fi

if [ -z "$NVIDIA_API_KEY" ]; then
    echo -e "  You need a free NVIDIA NIM API key."
    echo -e "  Get one at: ${CYAN}https://build.nvidia.com${RESET}"
    echo ""
    echo -e "  ${DIM}It's free — no credit card. Sign up, generate a key, paste it here.${RESET}"
    echo ""
    echo -n "  Paste your NVIDIA API key: "
    read -r NVIDIA_API_KEY
    echo ""

    if [ -z "$NVIDIA_API_KEY" ]; then
        echo -e "  ${RED}No key provided.${RESET} Get one at https://build.nvidia.com"
        exit 1
    fi

    if [[ ! "$NVIDIA_API_KEY" =~ ^nvapi- ]]; then
        echo -e "  ${RED}Warning:${RESET} Key doesn't start with nvapi- — might not be valid"
        echo -n "  Continue anyway? [y/N]: "
        read -r CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy] ]]; then
            exit 1
        fi
    fi
fi

echo -e "  ${GREEN}✓${RESET} API key set"
echo ""

# ─── Step 2: Pick a Model ────────────────────────────────────────────

echo -e "${DIM}  ────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  [2/4] Choose Your Model${RESET}"
echo ""
echo -e "  All models are ${GREEN}free${RESET} via NVIDIA NIM:"
echo ""
echo -e "    ${CYAN}1)${RESET} Kimi K2.5           ${DIM}— Moonshot AI, top coding model${RESET} ${GREEN}(recommended)${RESET}"
echo -e "    ${CYAN}2)${RESET} GLM-5               ${DIM}— ZhipuAI, strong all-rounder${RESET}"
echo -e "    ${CYAN}3)${RESET} Nemotron 3 Super     ${DIM}— NVIDIA, 120B params${RESET}"
echo -e "    ${CYAN}4)${RESET} MiniMax M2.5         ${DIM}— MiniMax, fast responses${RESET}"
echo -e "    ${CYAN}5)${RESET} Qwen 3.5 397B        ${DIM}— Alibaba, massive MoE${RESET}"
echo -e "    ${CYAN}6)${RESET} GPT-OSS 120B         ${DIM}— OpenAI open-source${RESET}"
echo ""
echo -n "  Choose [1]: "
read -r MODEL_CHOICE

case "${MODEL_CHOICE:-1}" in
    1) NEMO_MODEL="moonshotai/kimi-k2.5" ;;
    2) NEMO_MODEL="z-ai/glm5" ;;
    3) NEMO_MODEL="nvidia/nemotron-3-super-120b-a12b" ;;
    4) NEMO_MODEL="minimaxai/minimax-m2.5" ;;
    5) NEMO_MODEL="qwen/qwen3.5-397b-a17b" ;;
    6) NEMO_MODEL="openai/gpt-oss-120b" ;;
    *) NEMO_MODEL="moonshotai/kimi-k2.5" ;;
esac

echo -e "  ${GREEN}✓${RESET} Selected: ${CYAN}${NEMO_MODEL}${RESET}"
echo ""

# ─── Step 3: Install Mode ────────────────────────────────────────────

echo -e "${DIM}  ────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  [3/4] Installation Mode${RESET}"
echo ""
echo -e "    ${CYAN}1)${RESET} ${BOLD}Docker (sandboxed)${RESET}      ${GREEN}(recommended)${RESET}"
echo -e "       ${DIM}Secure container. Can't touch your files. Safe for anything.${RESET}"
echo ""
echo -e "    ${CYAN}2)${RESET} ${BOLD}Local (full power)${RESET}"
echo -e "       ${DIM}Full machine access. Browser, filesystem, MCP servers, everything.${RESET}"
echo ""

HAS_DOCKER=false
if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
    HAS_DOCKER=true
fi

if [ "$HAS_DOCKER" = false ]; then
    echo -e "  ${DIM}Docker not detected — option 1 requires Docker${RESET}"
    echo ""
fi

echo -n "  Choose [1]: "
read -r INSTALL_MODE

echo ""

# ─── Step 4: Install ─────────────────────────────────────────────────

echo -e "${DIM}  ────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  [4/4] Installing...${RESET}"
echo ""

NEMO_DIR="$HOME/.nemo-code"
mkdir -p "$NEMO_DIR"

if [ "${INSTALL_MODE:-1}" = "1" ]; then
    # ═══ DOCKER INSTALL ═══

    if [ "$HAS_DOCKER" = false ]; then
        echo -e "  ${RED}Docker required.${RESET} Install: ${CYAN}https://docs.docker.com/get-docker/${RESET}"
        exit 1
    fi

    echo -e "  ${DIM}Building Nemo Code image (first time takes ~2 min)...${RESET}"

    SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
    if [ -f "$SCRIPT_DIR/Dockerfile" ]; then
        cd "$SCRIPT_DIR"
    else
        echo -e "  ${DIM}Downloading Nemo Code source...${RESET}"
        CLONE_DIR=$(mktemp -d)
        git clone --depth 1 https://github.com/kevdogg102396-afk/nemo-code.git "$CLONE_DIR" 2>&1 | tail -1
        cd "$CLONE_DIR"
    fi
    docker build -t nemo-code:latest . 2>&1 | grep -E "^(#|Successfully|DONE)" | tail -5
    echo -e "  ${GREEN}✓${RESET} Docker image ready"

    # Docker launcher
    cat > "$NEMO_DIR/nemo-code" << LAUNCHER
#!/bin/bash
exec docker run -it --rm --dns 8.8.8.8 --dns 8.8.4.4 \
    -e NVIDIA_API_KEY="${NVIDIA_API_KEY}" \
    -e NEMO_MODEL="${NEMO_MODEL}" \
    nemo-code:latest \
    "\${@:-chat}"
LAUNCHER
    chmod +x "$NEMO_DIR/nemo-code"

    # Telegram launcher
    cat > "$NEMO_DIR/nemo-telegram" << TGLAUNCHER
#!/bin/bash
if [ -z "\$TELEGRAM_BOT_TOKEN" ]; then
    echo "Usage: TELEGRAM_BOT_TOKEN=xxx nemo-telegram"
    echo "Create a bot: https://t.me/BotFather"
    exit 1
fi
docker stop nemo-tg 2>/dev/null; docker rm nemo-tg 2>/dev/null
exec docker run -it --name nemo-tg \
    --dns 8.8.8.8 --dns 8.8.4.4 \
    -e NVIDIA_API_KEY="${NVIDIA_API_KEY}" \
    -e NEMO_MODEL="${NEMO_MODEL}" \
    -e TELEGRAM_BOT_TOKEN="\$TELEGRAM_BOT_TOKEN" \
    -e TELEGRAM_ALLOWED_CHAT_IDS="\${TELEGRAM_ALLOWED_CHAT_IDS:-}" \
    -e ANTHROPIC_API_KEY="nemo-code-local" \
    -e ANTHROPIC_BASE_URL="http://127.0.0.1:4000" \
    nemo-code:latest telegram
TGLAUNCHER
    chmod +x "$NEMO_DIR/nemo-telegram"

else
    # ═══ LOCAL INSTALL ═══

    if ! command -v node &> /dev/null; then
        echo -e "  ${RED}Node.js not found.${RESET} Install: ${CYAN}https://nodejs.org${RESET} (v18+)"
        exit 1
    fi
    echo -e "  ${GREEN}✓${RESET} Node.js $(node -v)"

    PYTHON=$(command -v python3 || command -v python || echo "")
    if [ -z "$PYTHON" ]; then
        echo -e "  ${RED}Python 3 not found.${RESET} Install: ${CYAN}https://python.org${RESET}"
        exit 1
    fi
    echo -e "  ${GREEN}✓${RESET} Python $($PYTHON --version 2>&1)"

    echo -e "  ${DIM}Installing Claude Code CLI...${RESET}"
    npm install -g @anthropic-ai/claude-code 2>&1 | tail -1
    echo -e "  ${GREEN}✓${RESET} Claude Code CLI"

    echo -e "  ${DIM}Installing LiteLLM...${RESET}"
    $PYTHON -m pip install 'litellm[proxy]==1.82.6' --quiet 2>&1 | tail -1
    echo -e "  ${GREEN}✓${RESET} LiteLLM"

    mkdir -p "$NEMO_DIR/workspace/memory"

    cat > "$NEMO_DIR/workspace/CLAUDE.md" << 'NEMOIDENTITY'
# Nemo Code Agent

You are Nemo, an AI agent powered by Nemo Code (ClawdWorks). You run free NVIDIA models through the Claude Code CLI framework.

## Rules
- Be direct, helpful, and efficient
- If you don't know something, say so
- You have full access to this machine's filesystem and tools

## Capabilities
- Code generation, review, and debugging
- File creation and editing
- Running scripts (Python, Node.js, Bash)
- Web fetching via curl, wget, or MCP fetch tool
- Browser automation (if Playwright installed)
- Git operations
- Any MCP server you configure
NEMOIDENTITY

    # Local launcher
    cat > "$NEMO_DIR/nemo-code" << 'LOCALLAUNCHER'
#!/bin/bash
NEMO_DIR="$HOME/.nemo-code"

if [ -z "$NVIDIA_API_KEY" ]; then
    if [ -f "$NEMO_DIR/.env" ]; then
        source "$NEMO_DIR/.env"
    else
        echo "NVIDIA_API_KEY not set. Run: export NVIDIA_API_KEY='your-key'"
        exit 1
    fi
fi

NEMO_MODEL="${NEMO_MODEL:-moonshotai/kimi-k2.5}"
NEMO_MAX_TOKENS="${NEMO_MAX_TOKENS:-16384}"

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

# Kill any existing LiteLLM on our port
lsof -ti:4000 2>/dev/null | xargs kill 2>/dev/null
sleep 1

# Find litellm — might not be on PATH (especially Windows)
LITELLM_CMD=""
if command -v litellm &> /dev/null; then
    LITELLM_CMD="litellm"
else
    # Search common Python script locations
    for CANDIDATE in \
        "$HOME/AppData/Local/Packages/PythonSoftwareFoundation.Python."*/LocalCache/local-packages/Python*/Scripts/litellm.exe \
        "$HOME/AppData/Local/Programs/Python/Python"*/Scripts/litellm.exe \
        "$HOME/.local/bin/litellm" \
        /usr/local/bin/litellm; do
        if [ -f "$CANDIDATE" ]; then
            LITELLM_CMD="$CANDIDATE"
            break
        fi
    done
fi

if [ -z "$LITELLM_CMD" ]; then
    echo "LiteLLM not found. Installing..."
    PYTHON_CMD=$(command -v python3 || command -v python)
    $PYTHON_CMD -m pip install 'litellm[proxy]==1.82.6' --quiet 2>&1 | tail -1
    # Try again after install
    if command -v litellm &> /dev/null; then
        LITELLM_CMD="litellm"
    else
        for CANDIDATE in \
            "$HOME/AppData/Local/Packages/PythonSoftwareFoundation.Python."*/LocalCache/local-packages/Python*/Scripts/litellm.exe \
            "$HOME/AppData/Local/Programs/Python/Python"*/Scripts/litellm.exe \
            "$HOME/.local/bin/litellm" \
            /usr/local/bin/litellm; do
            if [ -f "$CANDIDATE" ]; then
                LITELLM_CMD="$CANDIDATE"
                break
            fi
        done
    fi
fi

if [ -z "$LITELLM_CMD" ]; then
    echo "ERROR: Could not find litellm after install. Add Python Scripts to your PATH."
    exit 1
fi

PYTHONIOENCODING=utf-8 PYTHONUTF8=1 "$LITELLM_CMD" --config /tmp/nemo-litellm.yaml --port 4000 --host 127.0.0.1 > /tmp/nemo-litellm.log 2>&1 &
PROXY_PID=$!
trap "kill $PROXY_PID 2>/dev/null" EXIT

# Wait for proxy to be ready
PROXY_READY=false
for i in $(seq 1 30); do
    if curl -s http://127.0.0.1:4000/health > /dev/null 2>&1; then
        PROXY_READY=true
        break
    fi
    sleep 1
done

if [ "$PROXY_READY" = false ]; then
    echo "LiteLLM proxy failed to start. Check /tmp/nemo-litellm.log"
    exit 1
fi

export ANTHROPIC_BASE_URL="http://127.0.0.1:4000"
export ANTHROPIC_API_KEY="nemo-code-local"

# Use separate config dir so Nemo doesn't conflict with existing Claude Code
export CLAUDE_CONFIG_DIR="$NEMO_DIR/.claude-config"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Pre-bake onboarding so CC doesn't ask setup questions
cat > "$CLAUDE_CONFIG_DIR/.claude.json" << CJSON
{
  "hasCompletedOnboarding": true,
  "theme": "dark",
  "customApiKeyResponses": { "approved": true },
  "bypassPermissionsModeAccepted": true
}
CJSON

echo ""
echo -e "\033[1;33m\033[1m  CLAWD WORKS\033[0m · \033[0;36mnemo-code\033[0m · \033[0;36m${NEMO_MODEL}\033[0m"
echo ""

# Use winpty on Windows (Git Bash mintty needs it for TUI)
CLAUDE_CMD="claude"
if command -v winpty &> /dev/null && [ -n "$MSYSTEM" ]; then
    CLAUDE_CMD="winpty claude"
fi

$CLAUDE_CMD --model sonnet --dangerously-skip-permissions --system-prompt-file "$NEMO_DIR/CLAUDE.md" "$@"
LOCALLAUNCHER
    chmod +x "$NEMO_DIR/nemo-code"

    # Save env
    echo "export NVIDIA_API_KEY=\"${NVIDIA_API_KEY}\"" > "$NEMO_DIR/.env"
    echo "export NEMO_MODEL=\"${NEMO_MODEL}\"" >> "$NEMO_DIR/.env"
fi

# ─── Add to PATH (Linux/Mac + Windows) ───────────────────────────────

# Linux/Mac symlinks
LINK_DIR="$HOME/.local/bin"
mkdir -p "$LINK_DIR"
ln -sf "$NEMO_DIR/nemo-code" "$LINK_DIR/clawdworks"
[ -f "$NEMO_DIR/nemo-telegram" ] && ln -sf "$NEMO_DIR/nemo-telegram" "$LINK_DIR/clawdworks-telegram"

# Add to bashrc if not already there
if ! grep -q "/.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Windows: create .cmd wrapper so it works from PowerShell
if [ -d "/mnt/c/Users" ]; then
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    WIN_BIN="/mnt/c/Users/${WIN_USER}/.local/bin"
    mkdir -p "$WIN_BIN"

    cat > "${WIN_BIN}/clawdworks.cmd" << WINCMD
@echo off
wsl -e bash -lc "clawdworks %*"
WINCMD

    if [ -f "$NEMO_DIR/nemo-telegram" ]; then
        cat > "${WIN_BIN}/clawdworks-telegram.cmd" << WINTG
@echo off
wsl -e bash -lc "clawdworks-telegram %*"
WINTG
    fi

    # Add to Windows PATH if not already there
    WIN_PATH_DIR="C:\\Users\\${WIN_USER}\\.local\\bin"
    echo ""
    echo -e "  ${DIM}Adding to Windows PATH...${RESET}"
    powershell.exe -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH','User') + ';${WIN_PATH_DIR}', 'User')" 2>/dev/null
    echo -e "  ${GREEN}✓${RESET} Added to PATH"
    echo -e "  ${DIM}(Open a new terminal for PATH to take effect)${RESET}"
fi

# ─── Done ─────────────────────────────────────────────────────────────

echo ""
echo -e "${DIM}  ────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${GREEN}${BOLD}Nemo Code installed successfully!${RESET}"
echo ""
echo -e "  ${WHITE}Start chatting:${RESET}  ${CYAN}clawdworks${RESET}"
echo -e "  ${WHITE}List models:${RESET}     ${CYAN}clawdworks models${RESET}"
echo -e "  ${WHITE}Get help:${RESET}        ${CYAN}clawdworks help${RESET}"
[ -f "$NEMO_DIR/nemo-telegram" ] && echo -e "  ${WHITE}Telegram:${RESET}        ${CYAN}TELEGRAM_BOT_TOKEN=xxx clawdworks-telegram${RESET}"
echo ""
echo -e "  ${WHITE}Model:${RESET}  ${CYAN}${NEMO_MODEL}${RESET}"
echo -e "  ${WHITE}Mode:${RESET}   ${CYAN}$([ "${INSTALL_MODE:-1}" = "1" ] && echo "Docker (sandboxed)" || echo "Local (full power)")${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  CLAWD WORKS${RESET} — ${CYAN}nemo-code${RESET}"
echo -e "${DIM}  All the security. All the reliability. ALL the ease.${RESET}"
echo ""
echo -e "  ${WHITE}${BOLD}Open a new terminal, then type: ${CYAN}clawdworks${RESET}"
echo ""
