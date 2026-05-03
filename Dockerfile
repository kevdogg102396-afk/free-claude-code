FROM node:22-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates python3 python3-pip expect \
    && rm -rf /var/lib/apt/lists/*

# Install LiteLLM (Anthropic-to-OpenAI proxy)
# PINNED to 1.82.6  versions 1.82.7 and 1.82.8 were compromised in a supply chain attack (March 2026)
RUN pip3 install 'litellm[proxy]==1.82.6' --break-system-packages

# NOTE: Claude Code CLI is installed at runtime by the entrypoint script,
# not at build time. This keeps the Docker image free of proprietary code.
# The CLI is subject to Anthropic's Commercial Terms of Service.

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

# Give nemo user write access to npm global prefix (for runtime CLI install)
RUN mkdir -p /usr/local/lib/node_modules /usr/local/bin && \
    chown -R nemo:nemo /usr/local/lib/node_modules /usr/local/bin

# Pre-configure CC so it skips first-run wizard
RUN mkdir -p /home/nemo/.claude && chown -R nemo:nemo /home/nemo/.claude

USER nemo

# Create the global config that CC actually reads (~/.claude.json)
RUN echo '{"hasCompletedOnboarding":true,"lastOnboardingVersion":"2.1.126","theme":"dark","numStartups":1,"bypassPermissionsModeAccepted":true,"customApiKeyResponses":{"approved":["nemo-code-local"],"rejected":[]},"projects":{"/workspace":{"hasTrustDialogAccepted":true,"allowedTools":[],"mcpContextUris":[],"enabledMcpjsonServers":[],"disabledMcpjsonServers":[],"hasCompletedProjectOnboarding":true}}}' > /home/nemo/.claude.json && \
    mkdir -p /home/nemo/.claude && \
    echo '{"skipDangerousModePermissionPrompt":true}' > /home/nemo/.claude/settings.json

WORKDIR /workspace

# Default env vars (overridable)
ENV NVIDIA_API_KEY=""
ENV NEMO_MODEL="moonshotai/kimi-k2.6"
ENV NEMO_MAX_TOKENS="16384"

ENTRYPOINT ["nemo-code"]
