#!/bin/bash

set -euo pipefail

# CONFIG
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3KqWPYrkZxM2FjiJ6v1fdff87j9EqARRJifZp67u5jSTvFhqPWkcj37dkUHAMhfDUT5NUtC7Fzjymd6Kd377f4JNzf1ZEZb82wwERPLMw4KriHrrVnJumcWr4A7J2Yq1qtqQ"
TMUX_SESSION="nock-miner"
SOCKET_DIR="$PROJECT_DIR/.socket"
SOCKET_FILE="$SOCKET_DIR/nockchain_npc.sock"

echo "[*] Nockchain Watchdog starting..."

# Check if miner tmux session is running
if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo "[✓] Tmux session '$TMUX_SESSION' already running. No action needed."
else
  echo "[!] Tmux session not found. Restarting miner..."

  # Clean stale data
  echo "[~] Removing old data and socket..."
  rm -rf "$PROJECT_DIR/.data.nockchain"
  rm -rf "$SOCKET_FILE"

  echo "[↻] Launching miner..."
  tmux new-session -d -s "$TMUX_SESSION" "cd $PROJECT_DIR && nockchain --mining-pubkey $PUBKEY --mine | tee -a miner.log"

  echo "[✔] Miner restarted in tmux session '$TMUX_SESSION'"
fi
