#!/usr/bin/env node
// Nemo Code Telegram Bridge v2
// Maintains conversation history, sends typing indicators,
// and routes through Claude CLI with full context.

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');

const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const ALLOWED_CHAT_IDS = (process.env.TELEGRAM_ALLOWED_CHAT_IDS || '').split(',').map(s => s.trim());
const MEMORY_DIR = '/workspace/memory';
const HISTORY_FILE = path.join(MEMORY_DIR, 'conversation_history.json');
const MAX_HISTORY = 20; // Keep last 20 exchanges for context

if (!BOT_TOKEN) {
  console.error('ERROR: TELEGRAM_BOT_TOKEN not set');
  process.exit(1);
}

// Ensure memory directory exists
if (!fs.existsSync(MEMORY_DIR)) {
  fs.mkdirSync(MEMORY_DIR, { recursive: true });
}

// Load conversation history
function loadHistory() {
  try {
    if (fs.existsSync(HISTORY_FILE)) {
      return JSON.parse(fs.readFileSync(HISTORY_FILE, 'utf-8'));
    }
  } catch {}
  return [];
}

function saveHistory(history) {
  try {
    fs.writeFileSync(HISTORY_FILE, JSON.stringify(history, null, 2));
  } catch (err) {
    console.error(`Failed to save history: ${err.message}`);
  }
}

let offset = 0;
let conversationHistory = loadHistory();

function tgApi(method, params = {}) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(params);
    const req = https.request({
      hostname: 'api.telegram.org',
      path: `/bot${BOT_TOKEN}/${method}`,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) }
    }, (res) => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => {
        try { resolve(JSON.parse(body)); } catch { resolve({ ok: false }); }
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function sendTyping(chatId) {
  await tgApi('sendChatAction', { chat_id: chatId, action: 'typing' });
}

async function sendMessage(chatId, text, replyTo) {
  // Telegram max message length is 4096
  const chunks = [];
  for (let i = 0; i < text.length; i += 4000) {
    chunks.push(text.slice(i, i + 4000));
  }
  for (const chunk of chunks) {
    await tgApi('sendMessage', {
      chat_id: chatId,
      text: chunk,
      parse_mode: 'Markdown',
      ...(replyTo ? { reply_to_message_id: replyTo } : {})
    });
  }
}

// Build prompt with conversation context
function buildPrompt(newMessage) {
  let prompt = '';

  // Add recent conversation history for context
  if (conversationHistory.length > 0) {
    prompt += 'Previous conversation (for context):\n\n';
    const recent = conversationHistory.slice(-MAX_HISTORY);
    for (const entry of recent) {
      prompt += `Kevin: ${entry.user}\n`;
      prompt += `Nemo: ${entry.assistant}\n\n`;
    }
    prompt += '---\n\n';
  }

  prompt += `Kevin: ${newMessage}\n\nRespond as Nemo. Be casual, direct, helpful. Don't repeat your identity every message — just be natural.`;
  return prompt;
}

// Keep typing indicator alive during long responses
function startTypingLoop(chatId) {
  const interval = setInterval(() => sendTyping(chatId), 4000);
  return () => clearInterval(interval);
}

function runClaude(prompt) {
  return new Promise((resolve) => {
    try {
      // Escape for shell
      const escaped = prompt.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/`/g, '\\`').replace(/\$/g, '\\$');
      const result = execSync(
        `claude -p "${escaped}" --model sonnet --dangerously-skip-permissions --bare --system-prompt-file /workspace/CLAUDE.md --add-dir /workspace --mcp-config /workspace/.mcp.json --output-format text`,
        {
          encoding: 'utf-8',
          timeout: 0, // no timeout — let Nemo cook
          env: { ...process.env },
          cwd: '/workspace',
          maxBuffer: 1024 * 1024
        }
      );
      resolve(result.trim());
    } catch (err) {
      const msg = err.stderr || err.message || 'Unknown error';
      resolve(`Hit a snag: ${msg.slice(0, 500)}`);
    }
  });
}

async function pollAndRespond() {
  try {
    const updates = await tgApi('getUpdates', { offset, timeout: 30 });
    if (!updates.ok || !updates.result?.length) return;

    for (const update of updates.result) {
      offset = update.update_id + 1;
      const msg = update.message;
      if (!msg?.text) continue;

      const chatId = String(msg.chat.id);
      if (ALLOWED_CHAT_IDS.length && !ALLOWED_CHAT_IDS.includes(chatId)) {
        console.log(`Blocked message from unauthorized chat: ${chatId}`);
        continue;
      }

      const userName = msg.from?.first_name || 'User';
      console.log(`[${new Date().toISOString()}] ${userName}: ${msg.text.slice(0, 100)}`);

      // Start typing indicator loop
      const stopTyping = startTypingLoop(chatId);

      // Build prompt with conversation context
      const prompt = buildPrompt(msg.text);

      // Run through Claude CLI
      const response = await runClaude(prompt);

      // Stop typing
      stopTyping();

      console.log(`[${new Date().toISOString()}] Nemo: ${response.slice(0, 100)}...`);

      // Save to conversation history
      conversationHistory.push({
        user: msg.text,
        assistant: response,
        timestamp: new Date().toISOString()
      });

      // Trim history to MAX_HISTORY
      if (conversationHistory.length > MAX_HISTORY) {
        conversationHistory = conversationHistory.slice(-MAX_HISTORY);
      }
      saveHistory(conversationHistory);

      // Send response back
      await sendMessage(chatId, response, msg.message_id);
    }
  } catch (err) {
    console.error(`Poll error: ${err.message}`);
  }
}

async function main() {
  console.log('Nemo Code Telegram Bridge v2 started');
  console.log(`Bot token: ...${BOT_TOKEN.slice(-10)}`);
  console.log(`Allowed chats: ${ALLOWED_CHAT_IDS.join(', ')}`);
  console.log(`History: ${conversationHistory.length} messages loaded`);
  console.log('Waiting for messages...\n');

  // Clear pending updates
  await tgApi('getUpdates', { offset: -1 });
  const init = await tgApi('getUpdates', { offset: -1 });
  if (init.result?.length) offset = init.result[init.result.length - 1].update_id + 1;

  while (true) {
    await pollAndRespond();
  }
}

main().catch(console.error);
