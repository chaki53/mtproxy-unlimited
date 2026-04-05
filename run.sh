#!/bin/bash
set -e

WORKERS=${WORKERS:-2}

echo "============================================"
echo "  MTProxy Unlimited"
echo "  Max secrets: 10000 | Workers: $WORKERS"
echo "============================================"

# Generate secret if not provided
if [ -z "$SECRET" ]; then
  SECRET=$(openssl rand -hex 16)
  echo "[+] No secret provided. Generated: $SECRET"
fi

# Validate and build secret command
IFS=',' read -ra SECS <<< "$SECRET"
SECRET_CMD=""
VALID=0
for S in "${SECS[@]}"; do
  S=$(echo "$S" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
  [ -z "$S" ] && continue
  if ! echo "$S" | grep -qE '^[0-9a-f]{32}$'; then
    echo "[!] Skipping invalid secret: $S (must be 32 hex chars)"
    continue
  fi
  SECRET_CMD="$SECRET_CMD -S $S"
  VALID=$((VALID + 1))
done

if [ "$VALID" -eq 0 ]; then
  echo "[F] No valid secrets found"
  exit 1
fi

echo "[+] Loaded $VALID secrets"

# Download proxy configuration from Telegram
echo "[*] Downloading proxy config..."
for i in 1 2 3; do
  curl -sf https://core.telegram.org/getProxyConfig -o /etc/telegram/backend.conf && break
  echo "[!] Retry $i..."
  sleep 2
done

[ ! -f /etc/telegram/backend.conf ] && { echo "[F] Cannot download proxy config"; exit 2; }

# Detect IP addresses
IP=$(curl -sf -4 https://ifconfig.me 2>/dev/null || curl -sf -4 https://api.ipify.org 2>/dev/null || echo "")
INTERNAL_IP=$(ip -4 route get 8.8.8.8 2>/dev/null | grep -Po 'src \K[\d.]+' || echo "")

[ -z "$IP" ] && { echo "[F] Cannot determine external IP"; exit 3; }
[ -z "$INTERNAL_IP" ] && INTERNAL_IP="$IP"

echo "[+] External IP: $IP"
echo "[+] Internal IP: $INTERNAL_IP"
echo "[+] Port: 443"
echo "[+] Starting proxy..."
echo ""

exec /usr/local/bin/mtproto-proxy \
  -p 2398 -H 443 \
  -M "$WORKERS" \
  -C 60000 \
  --aes-pwd /etc/telegram/hello-explorers-how-are-you-doing \
  -u root \
  /etc/telegram/backend.conf \
  --allow-skip-dh \
  --nat-info "$INTERNAL_IP:$IP" \
  $SECRET_CMD
