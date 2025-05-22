#!/bin/bash
set -euo pipefail   # exit on error, undefined var, or pipe failure

# ─── CONFIG ────────────────────────────────────────────────────────────────────
SESSION="nock-miner"
PROJECT_DIR="$HOME/nockchain"
PUBKEY="3KqWPYrkZxM2FjiJ6v1fdff87j9EqARRJifZp67u5jSTvFhqPWkcj37dkUHAMhfDUT5NUtC7Fzjymd6Kd377f4JNzf1ZEZb82wwERPLMw4KriHrrVnJumcWr4A7J2Yq1qtqQ"
BINARY="$PROJECT_DIR/target/release/nockchain"
LOG_FILE="$PROJECT_DIR/miner.log"

# ─── LAUNCH ────────────────────────────────────────────────────────────────────
echo "[+] Launching Nockchain miner in tmux session ‘$SESSION’…"

# kill old session if it exists
tmux kill-session -t "$SESSION" 2>/dev/null || true

# start a new detached session and run the miner
tmux new-session -d -s "$SESSION" \
  "cd \"$PROJECT_DIR\" && \"$BINARY\" --mining-pubkey \"$PUBKEY\" --mine | tee -a \"$LOG_FILE\""

echo "✅ Started! Attach to it with:"
echo "    tmux attach -t $SESSION"
