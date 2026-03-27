# Nemo Code by ClawdWorks

**Free AI coding agent. Zero cost. One command.**

Nemo Code gives you the full Claude Code CLI experience — tools, file editing, bash, MCP servers, autocompact — powered by NVIDIA's best open models instead of a $200/mo subscription.

Built on the [Claude Code CLI](https://github.com/anthropics/claude-code) (Apache 2.0) + [LiteLLM](https://github.com/BerriAI/litellm) + [NVIDIA NIM](https://build.nvidia.com) free tier.

### Mac / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/kevdogg102396-afk/nemo-code/master/install.sh | bash
```

### Windows (PowerShell)
```powershell
curl.exe -fsSL https://raw.githubusercontent.com/kevdogg102396-afk/nemo-code/master/install.sh -o install.sh; bash install.sh
```

Then:

```bash
clawdworks
```

That's it.

---

## Models (all free)

| Model | Provider | Best for |
|-------|----------|----------|
| **Kimi K2.5** | Moonshot AI | Coding, reasoning (recommended) |
| GLM-5 | ZhipuAI | General purpose |
| Nemotron 3 Super 120B | NVIDIA | Balanced |
| MiniMax M2.5 | MiniMax | Fast responses |
| Qwen 3.5 397B | Alibaba | Complex reasoning |
| GPT-OSS 120B | OpenAI | General purpose |

Switch models anytime: `NEMO_MODEL=z-ai/glm5 clawdworks`

---

## Install Modes

### Docker (sandboxed) — recommended
Runs in a secure container. Can't access your files. Safe for anything.

- Requires: Docker
- Command: `clawdworks`
- Files stay in `/workspace` inside the container

### Local (full power)
Runs directly on your machine. Full filesystem, browser automation, MCP servers.

- Requires: Node.js 18+, Python 3
- Command: `clawdworks`
- Full access to everything on your machine

---

## What You Get

- **Interactive chat** — `clawdworks`
- **Headless mode** — `clawdworks run "fix the bug in app.js"`
- **Model switching** — `clawdworks models`
- **Telegram bridge** — `TELEGRAM_BOT_TOKEN=xxx clawdworks-telegram`
- **MCP servers** — fetch, memory, filesystem built in. Add your own.

### Docker mode includes:
- Read/Write/Edit files (in /workspace)
- Bash commands
- Python and Node.js
- Git
- Web fetch (DuckDuckGo search, any URL)
- MCP: fetch, memory, filesystem

### Local mode adds:
- Full filesystem access
- Browser automation (Playwright)
- Any MCP server you configure
- Computer use capabilities
- Everything Claude Code can do

---

## Telegram

Talk to Nemo from your phone:

1. Create a bot at [@BotFather](https://t.me/BotFather)
2. Run:
```bash
TELEGRAM_BOT_TOKEN="your-token" clawdworks-telegram
```

Features:
- Conversation memory (last 20 messages)
- Typing indicators
- No timeout — let it work on long tasks
- Chat ID allowlist for security

---

## How It Works

```
You → Claude Code CLI → LiteLLM Proxy → NVIDIA NIM → Free Model
```

1. Claude Code CLI thinks it's talking to Anthropic's API
2. LiteLLM intercepts and translates the request
3. NVIDIA NIM serves the model for free
4. You get the full CC experience at zero cost

---

## Requirements

**Docker mode:**
- Docker Desktop or Docker Engine
- NVIDIA API key (free at [build.nvidia.com](https://build.nvidia.com))

**Local mode:**
- Node.js 18+
- Python 3.8+
- NVIDIA API key (free)

**All platforms:** Windows (via WSL), macOS, Linux

---

## Security & Disclaimers

> **Read this before using Nemo Code on a personal machine.**

### Free models are NOT Claude

The open-source models available through NVIDIA NIM (Kimi K2.5, GLM-5, Nemotron, etc.) are powerful but they are **significantly more susceptible to prompt injection attacks** than Claude.

What this means:
- **Prompt injection** — Malicious content in files, web pages, or user inputs can trick free models into executing harmful commands. Claude has extensive training to resist these attacks. Free models do not have the same level of protection.
- **Data exfiltration** — A compromised model could be tricked into reading sensitive files (passwords, API keys, banking info) and sending them somewhere. This risk is much higher with open models.
- **Command execution** — In local mode, Nemo has full access to your machine. A successful prompt injection could result in destructive commands being run — including deleting files, corrupting your OS, or bricking your system.
- **Operating system damage** — Free models don't have Claude's safety training. A prompt injection could cause the agent to run commands that damage your operating system, delete critical files, or make your machine unbootable. This is not theoretical — it's a real risk with unrestricted agents running less-safe models.

### Recommendations

1. **Use Docker mode on personal machines.** If your computer has passwords, banking info, credentials, or anything sensitive — use the sandboxed Docker install. The container cannot access your files.

2. **Use Local mode on dedicated machines only.** Got a Mac Mini, VPS, or dev box that doesn't have personal data? Local mode is perfect. Full power, full access, no risk to sensitive info.

3. **Don't paste untrusted content.** Be cautious about having Nemo analyze files or web pages from unknown sources.

4. **Review before executing.** In local mode, Nemo will ask permission before running commands (just like normal Claude Code). Read what it wants to do before approving. In Docker mode, permissions are skipped since the sandbox protects you.

### Not affiliated with Anthropic

Nemo Code is built **on top of** the Claude Code CLI, which Anthropic released as open source under the Apache 2.0 license. We are not affiliated with, endorsed by, or sponsored by Anthropic. Claude Code is their product — we just built a free alternative interface for it using open models.

### No warranty

Nemo Code is provided as-is, without warranty of any kind. Use at your own risk. The authors are not responsible for any damage, data loss, or security incidents resulting from its use.

---

## Credits

- **[Claude Code CLI](https://github.com/anthropics/claude-code)** by Anthropic (Apache 2.0)
- **[LiteLLM](https://github.com/BerriAI/litellm)** by BerriAI (MIT)
- **[NVIDIA NIM](https://build.nvidia.com)** free inference endpoints
- **ClawdWorks** — Kevin Cline + Claude

---

## License

MIT License. See [LICENSE](LICENSE).

Built with love by [ClawdWorks](https://github.com/clawdworks).
