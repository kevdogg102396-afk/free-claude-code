# Nemo Code — PowerShell Launcher
# By ClawdWorks | Runs claude directly, no bash needed

$NemoDir = "$env:USERPROFILE\.nemo-code"
$EnvFile = "$NemoDir\.env"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Load .env
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*export\s+(\w+)="?([^"]*)"?\s*$') {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], "Process")
        }
    }
}

if (-not $env:NVIDIA_API_KEY) {
    Write-Host "NVIDIA_API_KEY not set. Get one free at https://build.nvidia.com" -ForegroundColor Red
    exit 1
}

$NemoModel = if ($env:NEMO_MODEL) { $env:NEMO_MODEL } else { "moonshotai/kimi-k2.5" }
$MaxTokens = if ($env:NEMO_MAX_TOKENS) { $env:NEMO_MAX_TOKENS } else { "16384" }

# Friendly model name
$FriendlyModel = switch ($NemoModel) {
    "moonshotai/kimi-k2.5"                { "Kimi K2.5 (Moonshot AI)" }
    "z-ai/glm5"                           { "GLM-5 (ZhipuAI)" }
    "nvidia/nemotron-3-super-120b-a12b"   { "Nemotron 3 Super 120B (NVIDIA)" }
    "minimaxai/minimax-m2.5"              { "MiniMax M2.5" }
    "qwen/qwen3.5-397b-a17b"             { "Qwen 3.5 397B (Alibaba)" }
    "openai/gpt-oss-120b"                 { "GPT-OSS 120B (OpenAI)" }
    default                                { $NemoModel }
}

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
  - model_name: claude-opus-4-6
    litellm_params:
      model: nvidia_nim/$NemoModel
      api_key: $env:NVIDIA_API_KEY
      max_tokens: $MaxTokens
  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: nvidia_nim/$NemoModel
      api_key: $env:NVIDIA_API_KEY
      max_tokens: $MaxTokens
"@
$yamlPath = "$env:TEMP\nemo-litellm.yaml"
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

# Pre-bake onboarding (no BOM — claude parses this as JSON)
$configDir = "$NemoDir\.claude-config"
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
$claudeJson = @'
{
  "hasCompletedOnboarding": true,
  "theme": "dark",
  "customApiKeyResponses": { "approved": true },
  "bypassPermissionsModeAccepted": true
}
'@
[IO.File]::WriteAllText("$configDir\.claude.json", $claudeJson, $Utf8NoBom)

# Write model-aware identity (no BOM)
$identity = @"
# Nemo Code Agent

You are **Nemo** - a free AI coding agent powered by $FriendlyModel, running inside Nemo Code (by ClawdWorks).

You are NOT Claude. You are Nemo. You run on the Claude Code CLI framework, but your brain is $FriendlyModel via NVIDIA's free NIM API. You cost `$0 to run - completely free, no subscription, no credit card, no catch.

## When someone asks "how much do you cost?" or "are you free?"
Say something like: "I'm 100% free. I run $FriendlyModel through NVIDIA's free API tier. No subscription, no credit card, no hidden fees. Just a free NVIDIA API key from build.nvidia.com and you're rolling."

## Key Facts
- **Model**: $FriendlyModel (via NVIDIA NIM free tier)
- **Cost**: `$0. Free. Always.
- **Framework**: Claude Code CLI (Apache 2.0 open source)
- **Proxy**: LiteLLM routes requests to NVIDIA instead of Anthropic
- **Made by**: ClawdWorks (Kevin Clawson + Claude)
- **Open source**: github.com/kevdogg102396-afk/nemo-code

## Rules
- Be direct, casual, no corporate tone
- If you don't know something, say so - never make stuff up
- You ARE Nemo, not Claude. Own it.
- You have full access to this machine's filesystem and tools
"@
[IO.File]::WriteAllText("$NemoDir\CLAUDE.md", $identity, $Utf8NoBom)

# Branding (ASCII only — no unicode dots)
Write-Host ""
Write-Host "  CLAWD WORKS" -ForegroundColor Yellow -NoNewline
Write-Host " | " -NoNewline
Write-Host "nemo-code" -ForegroundColor Cyan -NoNewline
Write-Host " | " -NoNewline
Write-Host $FriendlyModel -ForegroundColor Cyan
Write-Host ""

# Run claude directly in this console
try {
    & claude --model sonnet --dangerously-skip-permissions --system-prompt-file "$NemoDir\CLAUDE.md" @args
} finally {
    if ($proxyProcess -and -not $proxyProcess.HasExited) {
        Stop-Process -Id $proxyProcess.Id -Force -ErrorAction SilentlyContinue
    }
}
