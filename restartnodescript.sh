#!/bin/bash

set -euo pipefail  # Safer bash options

### CONFIG
REPO_URL="https://github.com/zorp-corp/nockchain"
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3MXohQ9ExcSQa1qttFgj15yZi3Xptwh2R99FoAgU5MxZYhFMN9bKhAPRWNmrUfXPy3WJoocvkHicCRfm7WV3BLXx7CHKJTnEPJMpdvdNF5rPRfowUBM6HB7LFgorcp6z464V"
TMUX_SESSION="nock-miner"

echo ""
echo "[+] Starting Nockchain miner in tmux..."
echo "----------------------------------------"

# Kill existing session if exists
tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

# Start new session with mining command
tmux new-session -d -s "$TMUX_SESSION" "cd $PROJECT_DIR && nockchain --mining-pubkey $PUBKEY --mine | tee -a miner.log"

echo ""
echo "✅ Nockchain MainNet Miner launched successfully!"
echo "   - To view miner logs: tmux attach -t $TMUX_SESSION"
echo "   - Wallet PubKey used: $PUBKEY"
