# Nemo Code  PowerShell Launcher
# By ClawdWorks | Runs claude directly, no bash needed

$NemoDir = "$env:USERPROFILE\.nemo-code"
$EnvFile = "$NemoDir\.env"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Model registry
$Models = @(
    @{ id = "moonshotai/kimi-k2.6";                name = "Kimi K2.6 (Moonshot AI)";          desc = "top coding model" }
    @{ id = "z-ai/glm5.1";                           name = "GLM-5.1 (ZhipuAI)";                  desc = "strong all-rounder" }
    @{ id = "nvidia/nemotron-3-super-120b-a12b";   name = "Nemotron 3 Super 120B (NVIDIA)";    desc = "120B params" }
    @{ id = "minimaxai/minimax-m2.7";              name = "MiniMax M2.7";                      desc = "fast responses" }
    @{ id = "qwen/qwen3.5-397b-a17b";              name = "Qwen 3.5 397B (Alibaba)";           desc = "massive MoE" }
    @{ id = "openai/gpt-oss-120b";                 name = "GPT-OSS 120B (OpenAI)";             desc = "open-source" }
)

# Load .env
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*export\s+(\w+)="?([^"]*)"?\s*$') {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], "Process")
        }
    }
}

if ($env:NEMO_MODEL -eq "moonshotai/kimi-k2.5") {
    $env:NEMO_MODEL = "moonshotai/kimi-k2.6"
} elseif ($env:NEMO_MODEL -eq "z-ai/glm-5.1") {
    $env:NEMO_MODEL = "z-ai/glm5.1"
}

# Handle subcommands
$firstArg = if ($args.Count -gt 0) { $args[0] } else { "" }

if ($firstArg -eq "models") {
    Write-Host ""
    Write-Host "  Available NVIDIA NIM models (free tier):" -ForegroundColor White
    Write-Host ""
    $currentModel = if ($env:NEMO_MODEL) { $env:NEMO_MODEL } else { "moonshotai/kimi-k2.6" }
    for ($i = 0; $i -lt $Models.Count; $i++) {
        $m = $Models[$i]
        $num = $i + 1
        if ($m.id -eq $currentModel) {
            Write-Host "  * $num) $($m.name)" -ForegroundColor Green -NoNewline
            Write-Host "  (active)" -ForegroundColor Green
        } else {
            Write-Host "    $num) $($m.name)" -NoNewline
            Write-Host "  - $($m.desc)" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    $pick = Read-Host "  Switch to [enter to keep current]"
    if ($pick -and $pick -match '^\d+$') {
        $idx = [int]$pick - 1
        if ($idx -ge 0 -and $idx -lt $Models.Count) {
            $newModel = $Models[$idx].id
            $envContent = "export NVIDIA_API_KEY=`"$env:NVIDIA_API_KEY`"`nexport NEMO_MODEL=`"$newModel`""
            [IO.File]::WriteAllText($EnvFile, $envContent, $Utf8NoBom)
            Write-Host "  Switched to: $($Models[$idx].name)" -ForegroundColor Green
            Write-Host "  Run 'clawdworks' to start with the new model." -ForegroundColor DarkGray
        } else {
            Write-Host "  Invalid choice." -ForegroundColor Red
        }
    } else {
        Write-Host "  Keeping: $currentModel" -ForegroundColor DarkGray
    }
    Write-Host ""
    exit 0
}

if ($firstArg -eq "help" -or $firstArg -eq "--help" -or $firstArg -eq "-h") {
    Write-Host ""
    Write-Host "  Nemo Code by ClawdWorks" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Usage: clawdworks [command]"
    Write-Host ""
    Write-Host "    (no args)    Interactive chat (default)"
    Write-Host "    models       List and switch NVIDIA models"
    Write-Host "    help         Show this help"
    Write-Host ""
    Write-Host "  Environment:"
    Write-Host "    NVIDIA_API_KEY    Your NVIDIA NIM key (required)"
    Write-Host "    NEMO_MODEL        Model to use (saved in ~/.nemo-code/.env)"
    Write-Host ""
    exit 0
}

# ---- Main launcher (chat mode) ----

if (-not $env:NVIDIA_API_KEY) {
    Write-Host "NVIDIA_API_KEY not set. Get one free at https://build.nvidia.com" -ForegroundColor Red
    exit 1
}

$NemoModel = if ($env:NEMO_MODEL) { $env:NEMO_MODEL } else { "moonshotai/kimi-k2.6" }
$MaxTokens = if ($env:NEMO_MAX_TOKENS) { $env:NEMO_MAX_TOKENS } else { "16384" }

# Friendly model name
$FriendlyModel = ($Models | Where-Object { $_.id -eq $NemoModel } | Select-Object -First 1).name
if (-not $FriendlyModel) { $FriendlyModel = $NemoModel }

# Write LiteLLM config (no BOM)
$yamlContent = @"
litellm_settings:
  drop_params: true
model_list:
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: nvidia_nim/$NemoModel
      api_key: $env:NVIDIA_API_KEY
      max_tokens: $MaxTokens
  - model_name: claude-opus-4-7
    litellm_params:
      model: nvidia_nim/qwen/qwen3.5-397b-a17b
      api_key: $env:NVIDIA_API_KEY
      max_tokens: $MaxTokens
  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: nvidia_nim/minimaxai/minimax-m2.7
      api_key: $env:NVIDIA_API_KEY
      max_tokens: $MaxTokens
"@
# Write LiteLLM config into $NemoDir (ACL-restricted to the user profile)
# rather than $env:TEMP which is world-readable on multi-user systems.
$yamlPath = "$NemoDir\litellm.yaml"
[IO.File]::WriteAllText($yamlPath, $yamlContent, $Utf8NoBom)

# Check if proxy is already running
$proxyUp = $false
try {
    $null = curl.exe -s -o NUL -w "%{http_code}" "http://127.0.0.1:4000/health" 2>$null
    if ($LASTEXITCODE -eq 0) { $proxyUp = $true }
} catch {}

$proxyProcess = $null
if (-not $proxyUp) {
    # Find litellm
    $litellmPath = $null
    $found = Get-Command litellm -ErrorAction SilentlyContinue
    if ($found) {
        $litellmPath = $found.Source
    } else {
        $candidates = @(
            "$env:USERPROFILE\AppData\Local\Programs\Python\Python*\Scripts\litellm.exe"
            "$env:USERPROFILE\AppData\Local\Packages\PythonSoftwareFoundation.Python.*\LocalCache\local-packages\Python*\Scripts\litellm.exe"
        )
        foreach ($pattern in $candidates) {
            $match = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($match) { $litellmPath = $match.FullName; break }
        }
    }

    if (-not $litellmPath) {
        Write-Host "LiteLLM not found. Install: pip install 'litellm[proxy]'" -ForegroundColor Red
        exit 1
    }

    # Start proxy in background
    $env:PYTHONIOENCODING = "utf-8"
    $env:PYTHONUTF8 = "1"
    $proxyProcess = Start-Process -FilePath $litellmPath -ArgumentList "--config `"$yamlPath`" --port 4000 --host 127.0.0.1" -WindowStyle Hidden -PassThru

    Write-Host "  Starting proxy..." -ForegroundColor DarkGray
    for ($i = 0; $i -lt 30; $i++) {
        try {
            $null = curl.exe -s -o NUL "http://127.0.0.1:4000/health" 2>$null
            if ($LASTEXITCODE -eq 0) { $proxyUp = $true; break }
        } catch {}
        Start-Sleep -Seconds 1
    }

    if (-not $proxyUp) {
        Write-Host "LiteLLM proxy failed to start." -ForegroundColor Red
        exit 1
    }
}

# Set env for claude
$env:ANTHROPIC_BASE_URL = "http://127.0.0.1:4000"
$env:ANTHROPIC_API_KEY = "nemo-code-local"
$env:CLAUDE_CONFIG_DIR = "$NemoDir\.claude-config"

# Pre-bake onboarding (no BOM)
$configDir = "$NemoDir\.claude-config"
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
$claudeJson = @'
{
  "theme": "dark",
  "customApiKeyResponses": { "approved": true }
}
'@
[IO.File]::WriteAllText("$configDir\.claude.json", $claudeJson, $Utf8NoBom)

# Write identity (no BOM)
$identity = @'
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
'@
[IO.File]::WriteAllText("$NemoDir\CLAUDE.md", $identity, $Utf8NoBom)

# Branding
Write-Host ""
Write-Host "     .    *       .          *        .       *      ." -ForegroundColor Blue
Write-Host "  *          .         *           .             *    " -ForegroundColor Blue
Write-Host ""
Write-Host "   CLAWD WORKS" -ForegroundColor Yellow
Write-Host "   n e m o - c o d e" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Kimi K2.6 " -ForegroundColor White -NoNewline
Write-Host "(sonnet)" -ForegroundColor DarkGray -NoNewline
Write-Host " | Qwen 3.5 " -ForegroundColor White -NoNewline
Write-Host "(opus)" -ForegroundColor DarkGray -NoNewline
Write-Host " | MiniMax M2.7 " -ForegroundColor White -NoNewline
Write-Host "(haiku)" -ForegroundColor DarkGray
Write-Host "   /model to switch mid-session  all free via NVIDIA NIM" -ForegroundColor DarkGray
Write-Host ""
Write-Host "     .    *       .          *        .       *      ." -ForegroundColor Blue
Write-Host ""

# CC's interactive TUI needs winpty on Windows (comes with Git for Windows)
$winpty = "C:\Program Files\Git\usr\bin\winpty.exe"

if ((Test-Path $winpty) -and -not ($args -contains "--print")) {
    # winpty gives claude a proper PTY for its TUI
    & $winpty claude --model sonnet --system-prompt-file "$NemoDir\CLAUDE.md" @args
} else {
    # --print mode works without winpty, or winpty not installed
    & claude --model sonnet --system-prompt-file "$NemoDir\CLAUDE.md" @args
}

# Kill proxy on exit if we started it
if ($proxyProcess -and -not $proxyProcess.HasExited) {
    Stop-Process -Id $proxyProcess.Id -Force -ErrorAction SilentlyContinue
}
