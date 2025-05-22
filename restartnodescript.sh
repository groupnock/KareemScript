#!/bin/bash

set -euo pipefail

# CONFIG
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3MXohQ9ExcSQa1qttFgj15yZi3Xptwh2R99FoAgU5MxZYhFMN9bKhAPRWNmrUfXPy3WJoocvkHicCRfm7WV3BLXx7CHKJTnEPJMpdvdNF5rPRfowUBM6HB7LFgorcp6z464V"
TMUX_SESSION="nock-miner"
SOCKET_FILE="$PROJECT_DIR/.socket/nockchain_npc.sock"

echo "[*] Nockchain Watchdog: full reset mode..."

# 1. Kill ALL tmux sessions
echo "[✂] Killing all tmux sessions..."
tmux ls 2>/dev/null | cut -d: -f1 | xargs -r -n1 tmux kill-session -t

# 2. Cleanup any stale state
echo "[🧹] Removing stale data and sockets..."
rm -rf "$PROJECT_DIR/.data.nockchain"
rm -rf "$SOCKET_FILE"

# 3. Launch miner inside tmux using full shell context
echo "[🚀] Starting new tmux session: $TMUX_SESSION"
tmux new-session -d -s "$TMUX_SESSION" "bash -c 'cd $PROJECT_DIR && nockchain --mining-pubkey $PUBKEY --mine | tee -a miner.log'"

# 4. Verify session
if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo "[✅] Miner successfully launched in tmux session '$TMUX_SESSION'"
  echo "    Attach with: tmux attach -t $TMUX_SESSION"
else
  echo "[❌] Miner failed to launch. Check logs or binary location."
  exit 1
fi
