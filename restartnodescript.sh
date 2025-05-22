#!/bin/bash
set -euo pipefail

PROJECT_DIR="$HOME/nockchain"
PUBKEY="3MXohQ9ExcSQa1qttFgj15yZi3Xptwh2R99FoAgU5MxZYhFMN9bKhAPRWNmrUfXPy3WJoocvkHicCRfm7WV3BLXx7CHKJTnEPJMpdvdNF5rPRfowUBM6HB7LFgorcp6z464V"
SESSION="nock-miner"

# 1) kill any old session
tmux kill-session -t "$SESSION" 2>/dev/null || true

# 2) start a brand-new, detached session
tmux new-session -d -s "$SESSION" -n miner-shell

# 3) send the startup commands (they run inside that session)
tmux send-keys -t "$SESSION" "cd $PROJECT_DIR" C-m
tmux send-keys -t "$SESSION" "nockchain --mining-pubkey $PUBKEY --mine | tee -a miner.log" C-m

echo "✅ Launched miner in tmux session '$SESSION'"
echo "   To attach: tmux attach -t $SESSION"
