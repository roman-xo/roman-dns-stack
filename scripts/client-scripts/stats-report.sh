#!/usr/bin/env bash
set -euo pipefail

SERVER="roman@192.168.1.10"

## Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

while true; do

echo
echo "     ____  _       __  __      __          ____  _   _______      "
echo "    / __ \(_)     / / / /___  / /__       / __ \/ | / / ___/      "
echo "   / /_/ / /_____/ /_/ / __ \/ / _ \     / / / /  |/ /\__ \       "
echo "  / ____/ /_____/ __  / /_/ / /  __/    / /_/ / /|  /___/ /       "
echo " /_/   /_/     /_/ /_/\____/_/\___/    /_____/_/ |_//____/        "
echo
echo " ----------------------------------- "
echo "   Pi-hole & DNS Server Statistics   "
echo " ----------------------------------- "
echo
echo "Select an option:"
echo "1) Summary stats"
echo "2) Top blocked domains"
echo "3) Top clients"
echo "4) Last 50 FTL log entries"
echo "5) Sus activity report"
echo "6) Exit"
echo
read -rp "Enter choice [1-6]: " choice

case "$choice" in
    1)
        echo "Fetching summary stats..."
        ssh "$SERVER" 'sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries;" | awk "{print \"  Total queries: \" \$1}"'
        ssh "$SERVER" 'sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT COUNT(*) FROM queries WHERE status=2;" | awk "{print \"  Blocked queries: \" \$1}"'
        ;;
    2)
        echo "Fetching top 10 blocked domains..."
        ssh "$SERVER" 'sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT domain, COUNT(*) as blocked FROM queries WHERE status=2 GROUP BY domain ORDER BY blocked DESC LIMIT 10;" | awk -F"|" "{printf \"  %-40s %s blocked\n\", \$1, \$2}"'
        ;;
    3)
        echo "Fetching top 10 clients..."
        ssh "$SERVER" 'sudo sqlite3 /etc/pihole/pihole-FTL.db "SELECT client, COUNT(*) as queries FROM queries GROUP BY client ORDER BY queries DESC LIMIT 10;" | awk -F"|" "{printf \"  %-25s %s queries\n\", \$1, \$2}"'
        ;;
    4)
        echo "Fetching last 50 lines of FTL log..."
        ssh "$SERVER" "sudo journalctl -u pihole-FTL.service -n 50 --no-pager"
        ;;
    5)
        echo "Checking for sus activity (high query clients & top blocked domains)..."
        THRESHOLD=1000
        ssh "$SERVER" 'DB="/etc/pihole/pihole-FTL.db"
if [ ! -f "$DB" ]; then
    echo "Database not found at $DB"
    exit 1
fi

echo "Clients with >'"$THRESHOLD"' queries in the last hour:"
sudo sqlite3 "$DB" "SELECT client, COUNT(*) FROM queries WHERE timestamp > strftime('\''%s'\'','\''now'\'','\''-1 hour'\'') GROUP BY client HAVING COUNT(*) > '"$THRESHOLD"';" \
| awk -F"|" '\''{printf "  %-25s %s queries\n", $1, $2}'\''

echo
echo "Top 10 blocked domains in the last hour:"
sudo sqlite3 "$DB" "SELECT domain, COUNT(*) FROM queries WHERE status=2 AND timestamp > strftime('\''%s'\'','\''now'\'','\''-1 hour'\'') GROUP BY domain ORDER BY COUNT(*) DESC LIMIT 10;" \
| awk -F"|" '\''{printf "  %-40s %s blocked\n", $1, $2}'\'''
        ;;
    6)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        ;;
esac
done
