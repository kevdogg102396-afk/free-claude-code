FROM node:22-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates python3 python3-pip expect \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install LiteLLM (Anthropic-to-OpenAI proxy)
RUN pip3 install 'litellm[proxy]' --break-system-packages

# Create sandboxed workspace with memory persistence
RUN useradd -m -s /bin/bash nemo
RUN mkdir -p /workspace/memory && chown -R nemo:nemo /workspace

# Copy Nemo Code wrapper + config
COPY src/nemo-code.sh /usr/local/bin/nemo-code
COPY src/splash.sh /usr/local/bin/nemo-splash
COPY src/start-proxy.sh /usr/local/bin/nemo-proxy
COPY src/test-proxy.sh /usr/local/bin/nemo-test
COPY src/telegram-bridge.js /usr/local/bin/nemo-telegram
RUN chmod +x /usr/local/bin/nemo-code /usr/local/bin/nemo-splash /usr/local/bin/nemo-proxy /usr/local/bin/nemo-test /usr/local/bin/nemo-telegram

# Copy default CLAUDE.md and MCP config for the sandboxed agent
COPY src/CLAUDE.md /workspace/CLAUDE.md
COPY src/mcp.json /workspace/.mcp.json
RUN chown nemo:nemo /workspace/CLAUDE.md /workspace/.mcp.json

# Pre-configure CC so it skips first-run wizard
RUN mkdir -p /home/nemo/.claude && chown -R nemo:nemo /home/nemo/.claude

USER nemo

# Create the global config that CC actually reads (~/.claude.json)
RUN echo '{"hasCompletedOnboarding":true,"lastOnboardingVersion":"2.1.83","theme":"dark","numStartups":1,"bypassPermissionsModeAccepted":true,"customApiKeyResponses":{"approved":["nemo-code-local"],"rejected":[]},"projects":{"/workspace":{"hasTrustDialogAccepted":true,"allowedTools":[],"mcpContextUris":[],"enabledMcpjsonServers":[],"disabledMcpjsonServers":[],"hasCompletedProjectOnboarding":true}}}' > /home/nemo/.claude.json && \
    mkdir -p /home/nemo/.claude && \
    echo '{"skipDangerousModePermissionPrompt":true}' > /home/nemo/.claude/settings.json

WORKDIR /workspace

# Default env vars (overridable)
ENV NVIDIA_API_KEY=""
ENV NEMO_MODEL="moonshotai/kimi-k2.5"
ENV NEMO_MAX_TOKENS="16384"

ENTRYPOINT ["nemo-code"]
