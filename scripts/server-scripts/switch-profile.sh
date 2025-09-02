#!/usr/bin/env bash
set -euo pipefail

DB="/etc/pihole/gravity.db"

## config
BASELINE_GROUP="baseline"
TOGGLE_GROUPS=("work" "study" "leisure")  # exactly one will be enabled
##

usage() { echo "Usage: $0 {work|study|leisure}"; exit 1; }
[[ $# -eq 1 ]] || usage
PROFILE="$1"

## check requested profile is valid
valid="false"
for g in "${TOGGLE_GROUPS[@]}"; do
  [[ "$g" == "$PROFILE" ]] && valid="true"
done
[[ "$valid" == "true" ]] || usage

## helper to get group id by name (fails if missing)
gid() {
  local name="$1"
  local id
  id=$(sqlite3 "$DB" "SELECT id FROM 'group' WHERE name='$name';" || true)
  if [[ -z "$id" ]]; then
    echo "ERROR: Group '$name' not found in Pi-hole." >&2
    exit 2
  fi
  echo "$id"
}

## fetch ids
BASELINE_ID=$(gid "$BASELINE_GROUP")
declare -A GIDS=()
for g in "${TOGGLE_GROUPS[@]}"; do GIDS[$g]=$(gid "$g"); done

echo "[*] Enabling baseline group: $BASELINE_GROUP (id $BASELINE_ID)"
sqlite3 "$DB" "UPDATE 'group' SET enabled=1 WHERE id=$BASELINE_ID;"

echo "[*] Switching profile to: $PROFILE"
for g in "${TOGGLE_GROUPS[@]}"; do
  if [[ "$g" == "$PROFILE" ]]; then
    sqlite3 "$DB" "UPDATE 'group' SET enabled=1 WHERE id=${GIDS[$g]};"
  else
    sqlite3 "$DB" "UPDATE 'group' SET enabled=0 WHERE id=${GIDS[$g]};"
  fi
done

##
## uncomment the next line to disable every other group:
## sqlite3 "$DB" "UPDATE 'group' SET enabled=0 WHERE id NOT IN ($BASELINE_ID, ${GIDS[$PROFILE]});"

echo "[*] Reloading Pi-hole (FTL) to apply group changes..."
/usr/local/bin/pihole restartdns reload-lists >/dev/null

echo "[*] Current groups:"
sqlite3 "$DB" "SELECT id, name, enabled FROM 'group' ORDER BY id;" | awk -F'|' '{printf "  id=%s  name=%s  enabled=%s\n",$1,$2,$3}'

echo "[✓] Profile switched to '$PROFILE' (baseline always on)."
