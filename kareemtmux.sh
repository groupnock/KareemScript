#!/bin/bash
set -e

# Load environment variables
source .env
export RUST_LOG
export MINIMAL_LOG_FORMAT
export MINING_PUBKEY

# Your wallet pubkey (fallback in case .env doesn't override)
PUBKEY="${MINING_PUBKEY:-2qLyi7jNWFsYhFcUe25odS9uHRq9sjkvkcmyrJUWGPiAX1W3CWe3JqKFP3PTjWfNQrjjrckRqPAAwuAxtGDuD7nLomM46Wdw6mNoZdJwPa8gz77Au7Xffpu9R1NvrGCrsnm6}"

# Base nockchain directory (must be compiled)
BASE_DIR="$HOME/nockchain"

# Port starting point
START_PORT=3006

# How many seconds to wait between checks
CHECK_INTERVAL=30

# Target minimum CPU usage
TARGET_CPU=80

# Initial number of miners
INITIAL_MINERS=12

# Maximum number of miners allowed
MAX_MINERS=30

# Count of miners launched
MINER_COUNT=0

function launch_miner() {
  if (( MINER_COUNT >= MAX_MINERS )); then
    echo "❌ Reached maximum number of miners ($MAX_MINERS). No more will be launched."
    return
  fi

  MINER_COUNT=$((MINER_COUNT + 1))
  PORT=$((START_PORT + (MINER_COUNT - 1) * 2))
  DIR="$HOME/nockchain_worker_$MINER_COUNT"
  SESSION="nock-miner-$MINER_COUNT"
  SOCKET="nockchain_$MINER_COUNT.sock"

  echo "🚀 Launching miner $MINER_COUNT on port $PORT"

  if [ ! -d "$DIR" ]; then
    cp -r "$BASE_DIR" "$DIR"
  fi

  cd "$DIR"
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  rm -f "$SOCKET"

  tmux new-session -d -s "$SESSION" bash -c "
    cd $DIR && \
    RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
      --npc-socket $SOCKET \
      --mining-pubkey $PUBKEY \
      --bind /ip4/0.0.0.0/udp/${PORT}/quic-v1 \
      --mine"
}

function get_cpu_usage() {
  top -bn2 | grep "Cpu(s)" | tail -n1 | awk '{print 100 - $8}' | cut -d. -f1
}

# Launch initial miners
for i in $(seq 1 $INITIAL_MINERS); do
  launch_miner
done

# Start monitoring CPU usage
while true; do
  sleep "$CHECK_INTERVAL"
  CPU_LOAD=$(get_cpu_usage)
  echo "🧠 CPU usage: ${CPU_LOAD}%"

  if (( CPU_LOAD < TARGET_CPU )); then
    echo "⚠️ CPU below ${TARGET_CPU}%, adding another miner..."
    launch_miner
  else
    echo "✅ CPU usage stable. No new miner needed."
  fi
done
