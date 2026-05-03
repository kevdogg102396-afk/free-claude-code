# Nemo Code by ClawdWorks

> Want these models inside your existing Claude Code install instead? Keep your memories, `CLAUDE.md`, MCP servers, hooks, and local workflow while swapping model backends with [AnyModel](https://kevster527.gumroad.com/l/anymodel).

Free AI coding agent. Zero subscription. One command.

Nemo Code gives you a Claude Code-style CLI experience - tools, file editing, shell commands, MCP servers, autocompact-style workflows, and optional Telegram access - powered by open/free model backends such as NVIDIA-hosted OSS models.

Built around:

- [Claude Code CLI](https://github.com/anthropics/claude-code) as a runtime dependency
- [LiteLLM](https://github.com/BerriAI/litellm) as the local Anthropic-compatible proxy
- [NVIDIA NIM](https://build.nvidia.com) hosted model endpoints

Nemo Code does not bundle or redistribute Claude Code.

## Quick Start

### Mac / Linux / Git Bash

```bash
curl -fsSL https://raw.githubusercontent.com/kevdogg102396-afk/free-claude-code/master/install.sh | bash
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/kevdogg102396-afk/free-claude-code/master/install.ps1 | iex
```

Then open a new terminal and run:

```bash
clawdworks
```

## 2026 Model Slots

Nemo maps Claude Code's model slots to current NVIDIA NIM model IDs. Switch in the TUI with `/model`.

| Claude Code slot | NVIDIA model ID | Best for |
| --- | --- | --- |
| Sonnet (default) | `moonshotai/kimi-k2.6` | Current top coding/default model |
| Opus | `qwen/qwen3.5-397b-a17b` | Large reasoning and complex tasks |
| Haiku | `minimaxai/minimax-m2.7` | Fast agentic coding and document work |

Additional selectable install-time models:

- `z-ai/glm5.1`
- `nvidia/nemotron-3-super-120b-a12b`
- `openai/gpt-oss-120b`

Model availability can change on NVIDIA's side. If a model disappears or rate limits heavily, rerun `clawdworks models` or set `NEMO_MODEL=<model-id>`.

`NEMO_MODEL` controls the Sonnet/default route. Opus and Haiku stay mapped to the fixed large/fast fallback models above.

## Install Modes

### Docker (sandboxed, recommended)

Runs in a container and keeps work inside `/workspace`.

- Requires Docker
- Safer for personal machines
- Command: `clawdworks`
- Telegram bridge included: `TELEGRAM_BOT_TOKEN=xxx clawdworks-telegram`

### Local (full power)

Runs directly on your machine.

- Requires Node.js 18+ and Python 3.8+
- Full filesystem access
- Browser automation and local MCP support if installed
- Command: `clawdworks`

Use local mode on a dedicated dev box or a machine where you are comfortable giving an agent broad access.

## Commands

```bash
clawdworks
clawdworks run "fix the bug in app.js"
clawdworks models
clawdworks help
```

Docker Telegram:

```bash
TELEGRAM_BOT_TOKEN="your-token" clawdworks-telegram
```

Optional Telegram allowlist:

```bash
TELEGRAM_ALLOWED_CHAT_IDS="123456789,987654321" TELEGRAM_BOT_TOKEN="your-token" clawdworks-telegram
```

## Telegram Bridge

The Docker path includes a one-liner Telegram bridge for phone access.

Features:

- Conversation memory for the last 20 exchanges
- Typing indicators during long runs
- No fixed Claude execution timeout
- Optional chat ID allowlist via `TELEGRAM_ALLOWED_CHAT_IDS`
- `/sonnet`, `/opus`, `/haiku`, and `/model` commands

## How It Works

```text
You -> Claude Code CLI -> LiteLLM proxy -> NVIDIA NIM -> open/free model
```

1. Claude Code sends Anthropic-style requests.
2. LiteLLM receives them on `127.0.0.1:4000`.
3. LiteLLM maps Claude model IDs to NVIDIA NIM model IDs.
4. NVIDIA serves the selected model.

The current Claude Code aliases observed in May 2026 are:

- `sonnet` -> `claude-sonnet-4-6`
- `opus` -> `claude-opus-4-7`
- `haiku` -> `claude-haiku-4-5-20251001`

The proxy config maps those IDs to the NVIDIA models above.

## Requirements

Docker mode:

- Docker Desktop or Docker Engine
- NVIDIA API key from [build.nvidia.com](https://build.nvidia.com)

Local mode:

- Node.js 18+
- Python 3.8+
- NVIDIA API key from [build.nvidia.com](https://build.nvidia.com)

Windows:

- Native PowerShell install is supported
- Git Bash is supported
- WSL can run the shell installer

## Security And Disclaimers

### Free models are not Claude

Open/free models available through NVIDIA NIM can be powerful, but they may be more vulnerable to prompt injection than Claude. Treat local agent access with care.

Risks include:

- Prompt injection from malicious files, websites, or pasted content
- Data exfiltration from files the agent can read
- Destructive command execution in local mode
- Accidental filesystem or OS damage

Recommendations:

1. Use Docker mode on personal machines.
2. Use local mode on dedicated development machines.
3. Avoid feeding untrusted content to a full-access agent.
4. Review commands before approving them.

### Not affiliated with Anthropic

Nemo Code is built on top of the Claude Code CLI by Anthropic. The Claude Code CLI is proprietary software distributed under Anthropic's terms. Nemo Code is not affiliated with, endorsed by, or sponsored by Anthropic.

### No warranty

Nemo Code is provided as-is, without warranty. Use it at your own risk.

## Credits

- [Claude Code CLI](https://github.com/anthropics/claude-code) by Anthropic
- [LiteLLM](https://github.com/BerriAI/litellm) by BerriAI
- [NVIDIA NIM](https://build.nvidia.com)
- ClawdWorks - Kevin Cline + Claude

## License

The Nemo Code wrapper, proxy config, splash screen, install scripts, and Telegram bridge are MIT licensed. See [LICENSE](LICENSE).

Nemo Code requires the Claude Code CLI (`@anthropic-ai/claude-code`), which is proprietary software by Anthropic PBC. Your use of the Claude Code CLI is subject to Anthropic's terms. Nemo Code installs the CLI as a runtime dependency via npm and does not bundle or redistribute it.
