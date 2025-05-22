#!/bin/bash

set -euo pipefail

# CONFIG
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3MXohQ9ExcSQa1qttFgj15yZi3Xptwh2R99FoAgU5MxZYhFMN9bKhAPRWNmrUfXPy3WJoocvkHicCRfm7WV3BLXx7CHKJTnEPJMpdvdNF5rPRfowUBM6HB7LFgorcp6z464V"
TMUX_SESSION="nock-miner"
SOCKET_FILE="$PROJECT_DIR/.socket/nockchain_npc.sock"

echo "[*] Nockchain Watchdog starting..."

# Check if tmux session exists
if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo "[✓] Tmux session '$TMUX_SESSION' is already running."
  exit 0
fi

echo "[!] Session not found. Cleaning up and restarting..."

# Cleanup
rm -rf "$PROJECT_DIR/.data.nockchain"
rm -rf "$SOCKET_FILE"

# Start miner inside tmux with bash shell context
tmux new-session -d -s "$TMUX_SESSION" "bash -c 'cd $PROJECT_DIR && nockchain --mining-pubkey $PUBKEY --mine | tee -a miner.log'"

# Confirm
if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo "[✔] Miner restarted in tmux session '$TMUX_SESSION'"
else
  echo "[✗] Miner failed to launch. Check if nockchain is installed and the path is correct."
  exit 1
fi
