#!/bin/bash

set -euo pipefail

# === CONFIGURATION ===
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3MXohQ9ExcSQa1qttFgj15yZi3Xptwh2R99FoAgU5MxZYhFMN9bKhAPRWNmrUfXPy3WJoocvkHicCRfm7WV3BLXx7CHKJTnEPJMpdvdNF5rPRfowUBM6HB7LFgorcp6z464V"
TMUX_SESSION="nock-miner"

echo ""
echo "[🔥] Nockchain Watchdog (Full Restart Mode)"

# 1. Kill all tmux sessions
echo "[✂️] Killing all tmux sessions..."
tmux ls 2>/dev/null | cut -d: -f1 | xargs -r -n1 tmux kill-session -t || true

# 2. Clean up old data
echo "[🧹] Cleaning up old chain data and sockets..."
rm -rf "$PROJECT_DIR/.data.nockchain"
rm -rf "$PROJECT_DIR/.socket/nockchain_npc.sock"

# 3. Start miner in tmux
echo "[🚀] Starting miner inside new tmux session: $TMUX_SESSION"
cd "$PROJECT_DIR"
tmux new-session -d -s "$TMUX_SESSION" "bash -c 'nockchain --mining-pubkey $PUBKEY --mine | tee -a miner.log'"

echo ""
echo "[✅] Miner launched inside tmux!"
echo "    • To view logs: tmux attach -t $TMUX_SESSION"
echo "    • To detach:   Ctrl + B, then D"
echo ""
