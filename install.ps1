# Nemo Code  Windows PowerShell Installer
# By ClawdWorks | One command. Free AI coding agent.
#
# irm https://raw.githubusercontent.com/kevdogg102396-afk/free-claude-code/master/install.ps1 | iex

# Don't use "Stop"  pip/npm write warnings to stderr which PS treats as fatal
$ErrorActionPreference = "Continue"

Clear-Host
Write-Host ""
Write-Host "     .    *       .          *        .       *      ." -ForegroundColor Blue
Write-Host "  *          .         *           .             *    " -ForegroundColor Blue
Write-Host ""
Write-Host "   CLAWD WORKS" -ForegroundColor Yellow
Write-Host "   n e m o - c o d e" -ForegroundColor Cyan
Write-Host ""
Write-Host "   All the security. All the reliability. ALL the ease." -ForegroundColor DarkGray
Write-Host ""
Write-Host "     .    *       .          *        .       *      ." -ForegroundColor Blue
Write-Host ""
Write-Host "  Free AI coding agent powered by NVIDIA's best open models." -ForegroundColor White
Write-Host "  Built on the Claude Code CLI runtime dependency." -ForegroundColor White
Write-Host ""
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# ---- Step 1: NVIDIA API Key ----
Write-Host "  [1/4] NVIDIA API Key" -ForegroundColor Yellow
Write-Host ""

$NvidiaKey = $env:NVIDIA_API_KEY
if ($NvidiaKey) {
    Write-Host "  " -NoNewline; Write-Host "ok" -ForegroundColor Green -NoNewline; Write-Host " Found NVIDIA_API_KEY in your environment"
    Write-Host "  Key: ...$($NvidiaKey.Substring($NvidiaKey.Length - 8))" -ForegroundColor DarkGray
    Write-Host ""
    $use = Read-Host "  Use this key? [Y/n]"
    if ($use -match '^[Nn]') { $NvidiaKey = "" }
}

if (-not $NvidiaKey) {
    Write-Host "  You need a free NVIDIA NIM API key."
    Write-Host "  Get one at: " -NoNewline; Write-Host "https://build.nvidia.com" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  It's free - no credit card. Sign up, generate a key, paste it here." -ForegroundColor DarkGray
    Write-Host ""
    $NvidiaKey = Read-Host "  Paste your NVIDIA API key"
    if (-not $NvidiaKey) {
        Write-Host "  No key provided. Get one at https://build.nvidia.com" -ForegroundColor Red
        exit 1
    }
    if ($NvidiaKey -notmatch '^nvapi-') {
        Write-Host "  Warning: Key doesn't start with nvapi- - might not be valid" -ForegroundColor Red
        $cont = Read-Host "  Continue anyway? [y/N]"
        if ($cont -notmatch '^[Yy]') { exit 1 }
    }
}
Write-Host "  ok API key set" -ForegroundColor Green
Write-Host ""

# ---- Step 2: Model ----
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [2/4] Choose Your Model" -ForegroundColor Yellow
Write-Host ""
Write-Host "  All models are " -NoNewline; Write-Host "free" -ForegroundColor Green -NoNewline; Write-Host " via NVIDIA NIM:"
Write-Host ""
Write-Host "    1) Kimi K2.6           - Moonshot AI, top coding model " -NoNewline; Write-Host "(recommended)" -ForegroundColor Green
Write-Host "    2) GLM-5.1               - ZhipuAI, strong all-rounder"
Write-Host "    3) Nemotron 3 Super     - NVIDIA, 120B params"
Write-Host "    4) MiniMax M2.7         - MiniMax, fast responses"
Write-Host "    5) Qwen 3.5 397B        - Alibaba, massive MoE"
Write-Host "    6) GPT-OSS 120B         - OpenAI open-source"
Write-Host ""
$modelChoice = Read-Host "  Choose [1]"
if (-not $modelChoice) { $modelChoice = "1" }

$NemoModel = switch ($modelChoice) {
    "1" { "moonshotai/kimi-k2.6" }
    "2" { "z-ai/glm5.1" }
    "3" { "nvidia/nemotron-3-super-120b-a12b" }
    "4" { "minimaxai/minimax-m2.7" }
    "5" { "qwen/qwen3.5-397b-a17b" }
    "6" { "openai/gpt-oss-120b" }
    default { "moonshotai/kimi-k2.6" }
}
Write-Host "  ok Selected: $NemoModel" -ForegroundColor Green
Write-Host ""

# ---- Step 3: Install ----
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [3/4] Installing..." -ForegroundColor Yellow
Write-Host ""

# Check Node.js
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    $nodeCmd = Get-Command node.exe -ErrorAction SilentlyContinue
}
if (-not $nodeCmd) {
    # Search common locations
    $candidates = @(
        "C:\Program Files\nodejs\node.exe"
        "$env:USERPROFILE\AppData\Local\fnm_multishells\*\node.exe"
    )
    foreach ($p in $candidates) {
        $found = Get-Item $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $env:PATH = "$($found.DirectoryName);$env:PATH"
            $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
            break
        }
    }
}
if (-not $nodeCmd) {
    Write-Host "  Node.js not found. Install: https://nodejs.org (v18+)" -ForegroundColor Red
    exit 1
}
Write-Host "  ok Node.js $(node -v)" -ForegroundColor Green

# Check Python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) { $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $pythonCmd) {
    Write-Host "  Python 3 not found. Install: https://python.org" -ForegroundColor Red
    exit 1
}
$pythonPath = $pythonCmd.Source
Write-Host "  ok Python $(& $pythonPath --version 2>&1)" -ForegroundColor Green

# Install Claude Code CLI
Write-Host "  Installing Claude Code CLI..." -ForegroundColor DarkGray
npm install -g @anthropic-ai/claude-code 2>&1 | Select-Object -Last 1
Write-Host "  ok Claude Code CLI" -ForegroundColor Green

# Install LiteLLM (suppress stderr  pip prints harmless dependency warnings)
Write-Host "  Installing LiteLLM..." -ForegroundColor DarkGray
$pipOutput = & $pythonPath -m pip install "litellm[proxy]==1.82.6" --quiet 2>&1
Write-Host "  ok LiteLLM" -ForegroundColor Green

# ---- Step 4: Configure ----
Write-Host ""
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [4/4] Configuring..." -ForegroundColor Yellow
Write-Host ""

$NemoDir = "$env:USERPROFILE\.nemo-code"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

New-Item -ItemType Directory -Path $NemoDir -Force | Out-Null
New-Item -ItemType Directory -Path "$NemoDir\workspace\memory" -Force | Out-Null
New-Item -ItemType Directory -Path "$NemoDir\.claude-config" -Force | Out-Null

# Save env file (bash-compatible for Git Bash launcher too)
$envContent = "export NVIDIA_API_KEY=`"$NvidiaKey`"`nexport NEMO_MODEL=`"$NemoModel`""
[IO.File]::WriteAllText("$NemoDir\.env", $envContent, $Utf8NoBom)

# Pre-bake onboarding
$claudeJson = '{"theme":"dark","customApiKeyResponses":{"approved":true}}'
[IO.File]::WriteAllText("$NemoDir\.claude-config\.claude.json", $claudeJson, $Utf8NoBom)

# Copy PowerShell launcher
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $null }
$ps1Source = if ($scriptDir -and (Test-Path "$scriptDir\src\nemo-code.ps1")) {
    "$scriptDir\src\nemo-code.ps1"
} else {
    # Download it
    $ps1Url = "https://raw.githubusercontent.com/kevdogg102396-afk/free-claude-code/master/src/nemo-code.ps1"
    $ps1Dest = "$NemoDir\nemo-code.ps1"
    curl.exe -fsSL $ps1Url -o $ps1Dest 2>$null
    $ps1Dest
}
if ($ps1Source -ne "$NemoDir\nemo-code.ps1") {
    Copy-Item $ps1Source "$NemoDir\nemo-code.ps1" -Force
}
Write-Host "  ok PowerShell launcher" -ForegroundColor Green

# Also copy bash launcher for Git Bash users (download from repo)
$bashUrl = "https://raw.githubusercontent.com/kevdogg102396-afk/free-claude-code/master/install.sh"
# Create a minimal bash launcher inline
$bashLauncher = @'
#!/bin/bash
NEMO_DIR="$HOME/.nemo-code"
if [ -z "$NVIDIA_API_KEY" ]; then
    if [ -f "$NEMO_DIR/.env" ]; then source "$NEMO_DIR/.env"; else echo "NVIDIA_API_KEY not set."; exit 1; fi
fi
case "${NEMO_MODEL:-}" in
    moonshotai/kimi-k2.5) NEMO_MODEL="moonshotai/kimi-k2.6" ;;
    z-ai/glm-5.1) NEMO_MODEL="z-ai/glm5.1" ;;
esac
NEMO_MODEL="${NEMO_MODEL:-moonshotai/kimi-k2.6}"
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
  - model_name: claude-opus-4-7
    litellm_params:
      model: nvidia_nim/qwen/qwen3.5-397b-a17b
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS}
  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: nvidia_nim/minimaxai/minimax-m2.7
      api_key: ${NVIDIA_API_KEY}
      max_tokens: ${NEMO_MAX_TOKENS}
YAML
lsof -ti:4000 2>/dev/null | xargs kill 2>/dev/null; sleep 1
LITELLM_CMD=""
if command -v litellm &> /dev/null; then LITELLM_CMD="litellm"
else
    for C in "$HOME/AppData/Local/Packages/PythonSoftwareFoundation.Python."*/LocalCache/local-packages/Python*/Scripts/litellm.exe \
             "$HOME/AppData/Local/Programs/Python/Python"*/Scripts/litellm.exe \
             "$HOME/.local/bin/litellm" /usr/local/bin/litellm; do
        [ -f "$C" ] && LITELLM_CMD="$C" && break
    done
fi
[ -z "$LITELLM_CMD" ] && echo "LiteLLM not found." && exit 1
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 "$LITELLM_CMD" --config /tmp/nemo-litellm.yaml --port 4000 --host 127.0.0.1 > /tmp/nemo-litellm.log 2>&1 &
PROXY_PID=$!; trap "kill $PROXY_PID 2>/dev/null" EXIT
for i in $(seq 1 30); do curl -s http://127.0.0.1:4000/health > /dev/null 2>&1 && break; sleep 1; done
export ANTHROPIC_BASE_URL="http://127.0.0.1:4000" ANTHROPIC_API_KEY="nemo-code-local"
export CLAUDE_CONFIG_DIR="$NEMO_DIR/.claude-config"
mkdir -p "$CLAUDE_CONFIG_DIR"
cat > "$CLAUDE_CONFIG_DIR/.claude.json" << 'CJSON'
{"theme":"dark","customApiKeyResponses":{"approved":true}}
CJSON
cat > "$NEMO_DIR/CLAUDE.md" << 'IDENTITY'
# Nemo Code Agent
You are **Nemo**  a free AI coding agent running inside Nemo Code (by ClawdWorks).
You are NOT Claude. You are Nemo. You run on NVIDIA's free NIM API. You cost $0  completely free.

## Your Models (switch mid-session with /model)
- **Sonnet** = Kimi K2.6 (Moonshot AI)  top coding model, default
- **Opus** = Qwen 3.5 397B (Alibaba)  biggest brain, massive MoE
- **Haiku** = MiniMax M2.7  fastest responses

All three are free via NVIDIA NIM. Users can type /model in the TUI to switch anytime.

## When asked "how much do you cost?" or "are you free?"
Say: "I'm 100% free. All 3 models run through NVIDIA's free API tier. No subscription, no credit card. Type /model to switch between Kimi K2.6, Qwen 3.5, and MiniMax M2.7."

## Key Facts
- **Cost**: $0. Free. Always. All models.
- **Made by**: ClawdWorks (Kevin Cline + Claude)
- **Open source**: github.com/kevdogg102396-afk/free-claude-code
- **Framework**: Claude Code CLI runtime dependency

## Rules
- Be direct, casual, no corporate tone
- If you don't know something, say so  never make stuff up
- You ARE Nemo, not Claude. Own it.
IDENTITY
echo ""
echo -e "\033[0;34m     .    *       .          *        .       *      .\033[0m"
echo -e "\033[0;34m  *          .         *           .             *    \033[0m"
echo ""
echo -e "\033[1;33m   CLAWD WORKS\033[0m"
echo -e "\033[0;36m   n e m o - c o d e\033[0m"
echo ""
echo -e "\033[0;37m   Kimi K2.6 \033[0;90m(sonnet)\033[0;37m | Qwen 3.5 \033[0;90m(opus)\033[0;37m | MiniMax M2.7 \033[0;90m(haiku)\033[0m"
echo -e "\033[0;90m   /model to switch mid-session  all free via NVIDIA NIM\033[0m"
echo ""
echo -e "\033[0;34m     .    *       .          *        .       *      .\033[0m"
echo ""
CLAUDE_CMD="claude"
command -v winpty &> /dev/null && [ -n "$MSYSTEM" ] && CLAUDE_CMD="winpty claude"
$CLAUDE_CMD --model sonnet --system-prompt-file "$NEMO_DIR/CLAUDE.md" "$@"
'@
[IO.File]::WriteAllText("$NemoDir\nemo-code", $bashLauncher, $Utf8NoBom)
Write-Host "  ok Bash launcher (Git Bash)" -ForegroundColor Green

# Create .cmd wrapper
$binDir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Path $binDir -Force | Out-Null

$cmdContent = "@echo off`r`n`"C:\Program Files\Git\bin\bash.exe`" `"%USERPROFILE%\.nemo-code\nemo-code`" %*"
[IO.File]::WriteAllText("$binDir\clawdworks.cmd", $cmdContent, $Utf8NoBom)
Write-Host "  ok clawdworks.cmd" -ForegroundColor Green

# Add to PATH if needed
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*\.local\bin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$binDir;$userPath", "User")
    Write-Host "  ok Added to PATH" -ForegroundColor Green
    Write-Host "  (Open a new terminal for PATH to take effect)" -ForegroundColor DarkGray
}

# ---- Done ----
Write-Host ""
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Nemo Code installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "  Start chatting:  " -NoNewline; Write-Host "clawdworks" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Model:  $NemoModel" -ForegroundColor Cyan
Write-Host "  Mode:   Local (full power)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  CLAWD WORKS" -ForegroundColor Yellow -NoNewline; Write-Host " - " -NoNewline; Write-Host "nemo-code" -ForegroundColor Cyan
Write-Host "  All the security. All the reliability. ALL the ease." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Open a new terminal, then type: " -NoNewline; Write-Host "clawdworks" -ForegroundColor Cyan
Write-Host ""
