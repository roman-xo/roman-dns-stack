#!/usr/bin/env zsh
set -euo pipefail

## CONFIG
SERVER="roman@192.168.1.10"
REMOTE_SCRIPT="/opt/dns-profiles/switch-profile.sh"
##

echo
echo "     ____  _       __  __      __          ____  _   _______      "
echo "    / __ \(_)     / / / /___  / /__       / __ \/ | / / ___/      "
echo "   / /_/ / /_____/ /_/ / __ \/ / _ \     / / / /  |/ /\__ \       "
echo "  / ____/ /_____/ __  / /_/ / /  __/    / /_/ / /|  /___/ /       "
echo " /_/   /_/     /_/ /_/\____/_/\___/    /_____/_/ |_//____/        "
echo                                                       
## Menu
echo " ツ Choose your focus:"
echo "  1) Work"
echo "  2) Study"
echo "  3) Leisure"
echo

## Read user choice
read -k "choice?Enter choice [1-3]: "
echo

## Map choice to profile
case "$choice" in
  1) PROFILE="work" ;;
  2) PROFILE="study" ;;
  3) PROFILE="leisure" ;;
  *) echo "Invalid choice." && exit 1 ;;
esac

echo "[*] Switching profile to '$PROFILE'..."

## SSH into server and run script with sudo, allocating a TTY
ssh -t "$SERVER" "sudo bash $REMOTE_SCRIPT $PROFILE"

echo "[✓] Profile switched to '$PROFILE'."
