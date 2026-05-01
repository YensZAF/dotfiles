#!/bin/bash
# smb_sync.sh — Select folder from Finder-mounted mybackups, rsync with auto-resume
# Requires: share already mounted via Finder at /Volumes/mybackups

SHARE_PATH="/Volumes/mybackups"
RUN_DIR="$(pwd)"
RETRY_WAIT=30

# Verify share is mounted
if [ ! -d "$SHARE_PATH" ]; then
  echo "ERROR: $SHARE_PATH not found."
  echo "Mount the share first: Finder → Go → Connect to Server → smb://192.168.88.32/mybackups"
  exit 1
fi

# ── Browse folders (navigate into subfolders) ─────────────────────────────────

browse_path="$SHARE_PATH"

while true; do
  folders=()
  while IFS= read -r name; do
    [[ "$name" == .* ]] && continue
    [ -d "$browse_path/$name" ] || continue
    folders+=("$name")
  done < <(ls -1 "$browse_path" 2>/dev/null | sort)

  rel_path="${browse_path#$SHARE_PATH}"
  rel_path="${rel_path#/}"
  display="${rel_path:-mybackups (root)}"

  echo ""
  echo "Location: $display"
  echo "──────────────────────────────"

  # Back option if not at root
  offset=0
  if [ "$browse_path" != "$SHARE_PATH" ]; then
    echo "   0) .. (go back)"
    offset=1
  fi

  if [ ${#folders[@]} -eq 0 ]; then
    echo "  (no subfolders)"
  else
    for i in "${!folders[@]}"; do
      printf "  %2d) %s\n" "$((i+1))" "${folders[$i]}"
    done
  fi

  echo "──────────────────────────────"
  echo "   s) Sync THIS folder"
  echo ""

  read -rp "Choice [0-${#folders[@]}/s]: " choice

  if [ "$choice" = "s" ]; then
    break
  elif [ "$choice" = "0" ] && [ "$browse_path" != "$SHARE_PATH" ]; then
    browse_path="$(dirname "$browse_path")"
  elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#folders[@]}" ]; then
    browse_path="$browse_path/${folders[$((choice-1))]}"
  else
    echo "  Invalid."
  fi
done

SRC="$browse_path/"
FOLDER_NAME="$(basename "$browse_path")"
DEST="$RUN_DIR/$FOLDER_NAME"
mkdir -p "$DEST"

LOG="$RUN_DIR/sync_progress.log"
rel="${browse_path#$SHARE_PATH/}"

echo ""
echo "Selected : $rel"
echo "Source   : $SRC"
echo "Dest     : $DEST"
echo "Log      : $LOG"
echo ""

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"
}

# ── Sync loop ─────────────────────────────────────────────────────────────────

attempt=0
log "SESSION START — $rel → $DEST"

while true; do
  attempt=$((attempt + 1))
  echo "────────────────────────────────────────────────────────"
  echo "[Attempt $attempt] $(date '+%Y-%m-%d %H:%M:%S')"
  log "Attempt $attempt started"
  echo ""

  rsync -avP --partial --timeout=60 "$SRC" "$DEST/"
  rsync_exit=$?

  if [ $rsync_exit -eq 0 ]; then
    file_count=$(find "$DEST" -type f | wc -l | tr -d ' ')
    log "COMPLETE — $file_count files in $DEST"
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo "DONE. All files synced to $DEST"
    echo "Log saved: $LOG"
    echo "════════════════════════════════════════════════════════"
    exit 0
  fi

  log "Attempt $attempt failed (exit $rsync_exit) — waiting ${RETRY_WAIT}s"
  echo ""
  echo "rsync failed (exit $rsync_exit). Waiting ${RETRY_WAIT}s..."

  sleep "$RETRY_WAIT"
  while [ ! -d "$SHARE_PATH" ]; do
    log "Share offline — waiting ${RETRY_WAIT}s"
    echo "Share offline. Waiting ${RETRY_WAIT}s..."
    sleep "$RETRY_WAIT"
  done

  log "Share back online"
  echo "Share back. Resuming..."
  echo ""
done
