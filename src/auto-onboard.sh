#!/bin/bash
# Auto-complete CC's first-run onboarding wizard
# Uses unbuffer/expect to handle interactive prompts

export ANTHROPIC_API_KEY="nemo-code-local"
export ANTHROPIC_BASE_URL="http://127.0.0.1:4000"
export TERM=xterm-256color

# Check if expect is available
if ! command -v expect &> /dev/null; then
    echo "Installing expect..."
    apt-get update -qq && apt-get install -y -qq expect > /dev/null 2>&1
fi

# Use expect to auto-answer the onboarding wizard
expect << 'EXPECT_SCRIPT'
set timeout 60
spawn claude --model sonnet --dangerously-skip-permissions

# API key prompt - select Yes (1)
expect {
    "Do you want to use this API key?" {
        send "1\r"
        exp_continue
    }
    "Choose the text style" {
        send "1\r"
        exp_continue
    }
    "Dark mode" {
        send "\r"
        exp_continue
    }
    "Press Enter to continue" {
        send "\r"
        exp_continue
    }
    "Yes, I trust this folder" {
        send "\r"
        exp_continue
    }
    "trust this" {
        send "1\r"
        exp_continue
    }
    ">" {
        send "/exit\r"
    }
    timeout {
        send "/exit\r"
    }
}

expect eof
EXPECT_SCRIPT

echo "Onboarding complete!"
