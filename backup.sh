#!/bin/bash
# ==========================================================
# Project: Automated Backup System
# Author: Kilaru Venkatesh (RIS00472)
# Description: Complete backup automation with compression,
#              checksum, dry-run, exclusion, list, and restore.
# ==========================================================

# === Setup Paths ===
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_ROOT="$PROJECT_DIR/backups"
BACKUP_TXT="$PROJECT_DIR/backup.txt"
LOG_FILE="$PROJECT_DIR/backup.log"
CONFIG_FILE="$PROJECT_DIR/backup.conf"

# === Load config file if exists ===
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  BACKUP_DESTINATION="$BACKUP_ROOT"
  EXCLUDE_PATTERNS=".git node_modules .cache temp"
  DAILY_KEEP=7
  WEEKLY_KEEP=4
  MONTHLY_KEEP=3
fi

# === Defaults ===
COMPRESS=false
DRY_RUN=false
RECENT=false
RECENT_DAYS=1
KEEP_COUNT=5
LIST_MODE=false
RESTORE_MODE=false
RESTORE_FILE=""
RESTORE_PATH=""

# === Redirect output to backup.txt ===
exec > >(tee "$BACKUP_TXT") 2>&1

# === Helpers ===
timestamp() { date +"[%a, %b %e, %Y %I:%M:%S %p]"; }
log() { echo "$(timestamp) $1" | tee -a "$LOG_FILE"; }

# === Parse Arguments ===
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --compress) COMPRESS=true ;;
    --dry-run) DRY_RUN=true ;;
    --list) LIST_MODE=true ;;
    --restore) RESTORE_MODE=true; shift; RESTORE_FILE="$1" ;;
    --to) shift; RESTORE_PATH="$1" ;;
    --recent) RECENT=true; shift; RECENT_DAYS=${1//[!0-9]/} ;;
    --help)
      echo "Usage: $0 [options] [file1 file2 ...]"
      echo
      echo "Options:"
      echo "  --compress       Compress backup into .tar.gz"
      echo "  --dry-run        Preview backup actions only"
      echo "  --recent [Xd]    Backup files modified in last X days"
      echo "  --list           Show all available backups"
      echo "  --restore <file> Restore backup to target directory"
      echo "  --to <path>      Destination for restore"
      echo "  --help           Show help menu"
      exit 0 ;;
    *) ARGS+=("$1") ;;
  esac
  shift
done

# === List Mode ===
if [[ "$LIST_MODE" == "true" ]]; then
  log "📂 Listing available backups in $BACKUP_DESTINATION"
  echo "--------------------------------------------"
  ls -lh "$BACKUP_DESTINATION" | awk '{print $6, $7, $8, $9}'
  echo "--------------------------------------------"
  exit 0
fi

# === Restore Mode ===
if [[ "$RESTORE_MODE" == "true" ]]; then
  if [[ -z "$RESTORE_FILE" || -z "$RESTORE_PATH" ]]; then
    log "❌ Usage: ./backup.sh --restore <file> --to <path>"
    exit 1
  fi

  log "🧩 Starting restore process..."
  log "Source file: $RESTORE_FILE"
  log "Destination: $RESTORE_PATH"

  mkdir -p "$RESTORE_PATH"

  if [[ "$RESTORE_FILE" == *.tar.gz ]]; then
    tar -xzf "$RESTORE_FILE" -C "$RESTORE_PATH"
  else
    cp -r "$RESTORE_FILE"/* "$RESTORE_PATH"/
  fi

  log "✅ Restore completed successfully."
  exit 0
fi

# === Normal Backup Mode ===
BACKUP_DIR="$BACKUP_DESTINATION/$(date +"%Y-%m-%d_%H-%M-%S")"
mkdir -p "$BACKUP_DIR"

log "🚀 Starting backup..."

# === Collect Files ===
FILES_TO_BACKUP=()
if [[ "$RECENT" == "true" ]]; then
  while IFS= read -r -d '' file; do
    FILES_TO_BACKUP+=("$file")
  done < <(find "$PROJECT_DIR" -type f -mtime -"$RECENT_DAYS" -print0)
else
  FILES_TO_BACKUP=("${ARGS[@]}")
fi

if [[ ${#FILES_TO_BACKUP[@]} -eq 0 ]]; then
  DEFAULT_DIR="$PROJECT_DIR/data"
  if [ -d "$DEFAULT_DIR" ]; then
    log "📂 No files specified — defaulting to all files in data/"
    FILES_TO_BACKUP=("$DEFAULT_DIR"/*)
  else
    log "❌ No files or data folder found!"
    exit 1
  fi
fi

# === Exclusion Logic ===
EXCLUDE_ARGS=()
for pattern in $EXCLUDE_PATTERNS; do
  EXCLUDE_ARGS+=(--exclude="$pattern")
done

# === Backup Files ===
PREVIOUS_BACKUP=$(ls -1dt "$BACKUP_DESTINATION"/*/ 2>/dev/null | head -n 1)
NEW_FILES=()

for FILE in "${FILES_TO_BACKUP[@]}"; do
  BASENAME=$(basename "$FILE")

  for pattern in $EXCLUDE_PATTERNS; do
    if [[ "$FILE" == *"$pattern"* ]]; then
      log "⚠️  Skipped (excluded): $FILE"
      continue 2
    fi
  done

  if [[ -f "$FILE" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log "🧪 Would back up: data/$BASENAME"
    else
      cp "$FILE" "$BACKUP_DIR"/
      log "✅ Backed up: data/$BASENAME"
    fi

    if [[ -d "$PREVIOUS_BACKUP" && -f "$PREVIOUS_BACKUP/$BASENAME" ]]; then
      :
    else
      NEW_FILES+=("data/$BASENAME")
    fi
  fi
done

# === Newly Added File Summary ===
if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
  log "🆕 Newly Added Files:"
  echo "--------------------------------------------" | tee -a "$LOG_FILE"
  for NEW_FILE in "${NEW_FILES[@]}"; do
    echo "$NEW_FILE" | tee -a "$LOG_FILE"
  done
  echo "--------------------------------------------" | tee -a "$LOG_FILE"
fi

# === Compression ===
if [[ "$COMPRESS" == "true" && "$DRY_RUN" != "true" ]]; then
  TAR_FILE="$BACKUP_DESTINATION/backup_$(date +"%Y-%m-%d_%H-%M-%S").tar.gz"
  tar -czf "$TAR_FILE" -C "$BACKUP_DIR" . >/dev/null 2>&1
  rm -rf "$BACKUP_DIR"
  BACKUP_OUTPUT="$TAR_FILE"
  log "📦 Compressed backup created: $(basename "$TAR_FILE")"
else
  BACKUP_OUTPUT="$BACKUP_DIR"
fi

# === Checksum ===
if [[ "$DRY_RUN" != "true" ]]; then
  CHECKSUM_FILE="$BACKUP_OUTPUT.sha256"
  find "$BACKUP_OUTPUT" -type f -exec sha256sum {} \; > "$CHECKSUM_FILE"
  log "🔐 Checksum file created: $(basename "$CHECKSUM_FILE")"
fi

# === Cleanup Rotation ===
if [[ "$DRY_RUN" != "true" ]]; then
  BACKUP_COUNT=$(ls -1t "$BACKUP_DESTINATION" | wc -l)
  if (( BACKUP_COUNT > KEEP_COUNT )); then
    OLD_BACKUPS=$(ls -1t "$BACKUP_DESTINATION" | tail -n +$((KEEP_COUNT + 1)))
    for OLD in $OLD_BACKUPS; do
      rm -rf "$BACKUP_DESTINATION/$OLD"
      log "🧹 Removed old backup: $OLD"
    done
  fi
fi

# === Completion ===
if [[ "$DRY_RUN" == "true" ]]; then
  log "🧪 Dry-run completed — no files copied or deleted."
else
  log "🎯 Backup process completed successfully."
  log "✅ Backup saved at: backups/$(basename "$BACKUP_OUTPUT")"
  log "📘 Log file: backup.log"
fi

echo ""
