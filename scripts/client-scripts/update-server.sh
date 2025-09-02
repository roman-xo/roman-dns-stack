#!/usr/bin/env zsh
set -euo pipefail

##  CONFIG 
SERVER="roman@192.168.1.10"
REMOTE_SCRIPT="/opt/dns-profiles/update-server.sh"
## 

echo "[*] Updating and maintaining the server..."
ssh -t "$SERVER" "sudo bash $REMOTE_SCRIPT"

echo "[✓] Server maintenance completed."
