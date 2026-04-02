# Nemo Code by ClawdWorks

> **Want these models inside YOUR Claude Code instead?** Keep all your memories, CLAUDE.md, MCP servers, hooks — just swap the brain. Check out [AnyModel](https://kevster527.gumroad.com/l/anymodel) — 28+ models, 9 providers, switch mid-session.

---

**Free AI coding agent. Zero cost. One command.**

Nemo Code gives you the full Claude Code CLI experience — tools, file editing, bash, MCP servers, autocompact — powered by NVIDIA's best open models instead of a $200/mo subscription.

Built on the [Claude Code CLI](https://github.com/anthropics/claude-code) + [LiteLLM](https://github.com/BerriAI/litellm) + [NVIDIA NIM](https://build.nvidia.com) free tier.

### Mac / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/kevdogg102396-afk/nemo-code/master/install.sh | bash
```

### Windows (PowerShell — no bash needed)
```powershell
irm https://raw.githubusercontent.com/kevdogg102396-afk/free-claude-code/master/install.ps1 | iex
```

Then:

```bash
clawdworks
```

That's it.

---

## Models (all free — switch mid-session!)

Nemo Code maps 3 NVIDIA models to Claude Code's model slots. Switch anytime with `/model` in the TUI:

| `/model` slot | NVIDIA Model | Best for |
|---------------|-------------|----------|
| **Sonnet** (default) | Kimi K2.5 (Moonshot AI) | Top coding model |
| **Opus** | Qwen 3.5 397B (Alibaba) | Biggest brain, complex reasoning |
| **Haiku** | MiniMax M2.5 | Fastest responses |

Just type `/model` during a session to switch between them — no restart needed. All three are free via NVIDIA NIM.

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
- **Model switching** — `/model` in the TUI (switch mid-session!)
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

Nemo Code is built **on top of** the Claude Code CLI by Anthropic. The Claude Code CLI is proprietary software (© Anthropic PBC, all rights reserved) distributed under Anthropic's [Commercial Terms of Service](https://www.anthropic.com/legal/commercial-terms). We are not affiliated with, endorsed by, or sponsored by Anthropic. Claude Code is their product — we built a free alternative interface on top of it using open models. Nemo Code does not redistribute or modify the Claude Code CLI binary; it is installed separately via npm as a runtime dependency.

### No warranty

Nemo Code is provided as-is, without warranty of any kind. Use at your own risk. The authors are not responsible for any damage, data loss, or security incidents resulting from its use.

---

## Credits

- **[Claude Code CLI](https://github.com/anthropics/claude-code)** by Anthropic (proprietary — see [Anthropic's terms](https://www.anthropic.com/legal/commercial-terms))
- **[LiteLLM](https://github.com/BerriAI/litellm)** by BerriAI (MIT)
- **[NVIDIA NIM](https://build.nvidia.com)** free inference endpoints
- **ClawdWorks** — Kevin Cline + Claude

---

## License

The Nemo Code wrapper (proxy config, splash screen, install scripts, Telegram bridge) is MIT licensed. See [LICENSE](LICENSE).

**Important:** Nemo Code requires the Claude Code CLI (`@anthropic-ai/claude-code`), which is proprietary software by Anthropic PBC. Your use of the Claude Code CLI is subject to [Anthropic's terms](https://www.anthropic.com/legal/commercial-terms). Nemo Code does not bundle or redistribute the CLI — it is installed as a runtime dependency via npm.

Built with love by [ClawdWorks](https://github.com/clawdworks).
