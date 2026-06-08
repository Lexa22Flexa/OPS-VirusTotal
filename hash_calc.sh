#!/usr/bin/env bash
HASH_FILE="otisky.sha256"

ps -o pid= | while read -r pid; do lsof -p "$pid" 2>/dev/null | grep txt | awk '{print $NF}'; done | xargs -r sha256sum > "$HASH_FILE"
