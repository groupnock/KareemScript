#!/bin/bash
set -euo pipefail  # safer bash options

### CONFIG
REPO_URL="https://github.com/zorp-corp/nockchain"
PROJECT_DIR="$HOME/nockchain"

# Your wallet pubkey
PUBKEY="2qLyi7jNWFsYhFcUe25odS9uHRq9sjkvkcmyrJUWGPiAX1W3CWe3JqKFP3PTjWfNQrjjrckRqPAAwuAxtGDuD7nLomM46Wdw6mNoZdJwPa8gz77Au7Xffpu9R1NvrGCrsnm6"

ENV_FILE="$PROJECT_DIR/.env"
MAKEFILE="$PROJECT_DIR/Makefile"

# Miner Settings
MINER_COUNT=10
START_PORT=3006
SUDOPASS="kareem@1"

# Automatically keep sudo active during script
echo "$SUDOPASS" | sudo -S -v
( while true; do echo "$SUDOPASS" | sudo -S -v; sleep 60; done ) &

echo ""
echo "[!] Purging all files in current working directory..."
rm -rf *
sleep 10
echo "[✔] Directory cleaned. Continuing..."

echo "[+] Nockchain MainNet Bootstrap Starting..."
echo "-------------------------------------------"

# 1. Install Rust
echo "[1/7] Installing Rust toolchain..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# 2. System Dependencies
echo "[2/7] Installing system dependencies..."
echo "$SUDOPASS" | sudo -S apt update
echo "$SUDOPASS" | sudo -S apt install -y git make build-essential clang llvm-dev libclang-dev tmux

# 3. Clone or Update Repo
echo "[3/7] Cloning or updating Nockchain repo..."
if [ ! -d "$PROJECT_DIR" ]; then
  git clone --depth 1 --branch master "$REPO_URL" "$PROJECT_DIR"
else
  cd "$PROJECT_DIR"
  git reset --hard HEAD && git pull origin master
fi
cd "$PROJECT_DIR"

# 4. Create or Update .env
echo "[4/7] Setting pubkey in .env..."
cp -f .env_example .env
sed -i "s|^MINING_PUBKEY=.*|MINING_PUBKEY=$PUBKEY|" "$ENV_FILE"
grep "MINING_PUBKEY" "$ENV_FILE"

# 5. Patch Makefile (optional)
echo "[5/7] Patching Makefile with pubkey..."
if grep -q "^export MINING_PUBKEY" "$MAKEFILE"; then
  sed -i "s|^export MINING_PUBKEY.*|export MINING_PUBKEY := $PUBKEY|" "$MAKEFILE"
else
  echo "export MINING_PUBKEY := $PUBKEY" >> "$MAKEFILE"
fi
grep "MINING_PUBKEY" "$MAKEFILE"

# 6. Build
echo "[6/7] Building Nockchain..."
make install-hoonc
make build
make install-nockchain
make install-nockchain-wallet

# 7. Cleanup
echo "[7/7] Cleaning old node data..."
rm -rf "$PROJECT_DIR/.data.nockchain"

# Reload environment
cd "$PROJECT_DIR"
source .env
export RUST_LOG
export MINIMAL_LOG_FORMAT
export MINING_PUBKEY
PUBKEY="${MINING_PUBKEY:-$PUBKEY}"

### Start miners
echo "[+] Launching $MINER_COUNT miners with tmux..."

for i in $(seq 1 $MINER_COUNT); do
  DIR="$HOME/nockchain_worker_$i"
  SESSION="nock-miner-$i"
  SOCKET="nockchain_$i.sock"
  PORT=$((START_PORT + (i - 1)))

  echo "🧱 Miner $i – Port $PORT"

  [ ! -d "$DIR" ] && cp -r "$PROJECT_DIR" "$DIR"
  cd "$DIR"
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  rm -f "$SOCKET"

  tmux new-session -d -s "$SESSION" bash -c "
    cd $DIR && \
    RUST_BACKTRACE=1 cargo run --release --bin nockchain -- \
      --npc-socket $SOCKET \
      --mining-pubkey $PUBKEY \
      --bind /ip4/0.0.0.0/udp/${PORT}/quic-v1 \
      --mine
  "

  echo "✅ Miner $i started in tmux session: $SESSION"
done

echo ""
echo "🚀 All $MINER_COUNT miners are now running!"
echo "👉 Check: tmux ls"
echo "👉 View one: tmux attach -t nock-miner-1"
