#!/usr/bin/env bash
set -euo pipefail

## CONFIG
LOG_FILE="/var/log/dns-maintenance.log"
UNBOUND_ROOT_HINTS="/var/lib/unbound/root.hints"
UPDATE_UNBOUND=true   # set to false if you don't want to update root hints
##

echo
echo "[!] SSH Success."
echo
echo "=================================="
echo "      DNS Server Maintenance"
echo "=================================="
echo "[*] Updating and maintaining the server..."

##    Update Pi-hole gravity (blocklists)
echo "[$(date '+%F %T')] Updating Pi-hole gravity..."
sudo pihole -g >> "$LOG_FILE" 2>&1
echo "[✓] Gravity update complete."

##    Update Unbound root hints
if [ "$UPDATE_UNBOUND" = true ]; then
    echo "[$(date '+%F %T')] Updating Unbound root hints..."
    sudo curl -s https://www.internic.net/domain/named.cache > "$UNBOUND_ROOT_HINTS"
    sudo chown unbound:unbound "$UNBOUND_ROOT_HINTS"
    sudo chmod 644 "$UNBOUND_ROOT_HINTS"
    echo "[✓] Unbound root hints updated."
fi

##    Reload Pi-hole lists
echo "[$(date '+%F %T')] Reloading Pi-hole lists..."
sudo pihole reloadlists >> "$LOG_FILE" 2>&1
echo "[✓] Pi-hole lists reloaded."

##    Restart Pi-hole FTL
echo "[$(date '+%F %T')] Restarting Pi-hole FTL..."
sudo pihole restartdns ftl >> "$LOG_FILE" 2>&1
echo "[✓] Pi-hole FTL restarted."

echo "[✓] Server maintenance completed."
