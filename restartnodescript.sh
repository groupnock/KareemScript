#!/bin/bash

set -euo pipefail

# CONFIG
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3MXohQ9ExcSQa1qttFgj15yZi3Xptwh2R99FoAgU5MxZYhFMN9bKhAPRWNmrUfXPy3WJoocvkHicCRfm7WV3BLXx7CHKJTnEPJMpdvdNF5rPRfowUBM6HB7LFgorcp6z464V"
TMUX_SESSION="nock-miner"
SOCKET_FILE="$PROJECT_DIR/.socket/nockchain_npc.sock"

echo "[*] Nockchain Watchdog: resetting miner..."

# 1. Kill ALL tmux sessions
echo "[✂] Killing all tmux sessions..."
tmux ls 2>/dev/null | cut -d: -f1 | xargs -r -n1 tmux kill-session -t || true

# 2. Clean up stale files
echo "[🧹] Removing stale data..."
rm -rf "$PROJECT_DIR/.data.nockchain"
rm -rf "$SOCKET_FILE"

# 3. Launch miner with bash context inside tmux
echo "[🚀] Starting new tmux session: $TMUX_SESSION"
tmux new-session -d -s "$TMUX_SESSION" bash -c "
  cd '$PROJECT_DIR' && \
  echo '[→] Starting miner with pubkey $PUBKEY' && \
  nockchain --mining-pubkey '$PUBKEY' --mine 2>&1 | tee -a miner.log
"

# 4. Wait briefly before listing
sleep 2
echo ""
echo "[✓] If all went well, tmux session '$TMUX_SESSION' should now be running."
echo "    View with: tmux attach -t $TMUX_SESSION"
echo "    Or check:  tmux ls"
