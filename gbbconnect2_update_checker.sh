#!/bin/bash

# This script checks for updates for GbbConnect2.Console and triggers the main installer if needed.
# It is intended to be run by a root cron job.

# --- Configuration - These paths MUST be correctly set by the main installer ---
# The main installer script will replace these placeholders when downloading.
CLONE_DIR="__CLONE_DIR_PLACEHOLDER__"
MAIN_INSTALLER_SCRIPT_PATH="__MAIN_INSTALLER_SCRIPT_PATH_PLACEHOLDER__"
APP_NAME="__APP_NAME_PLACEHOLDER__" # Used for logging consistency
# --- End Configuration ---

LOG_FILE="/var/log/${APP_NAME}_update_checker.log"
BRANCH_TO_TRACK="master" # Or 'main'

# Ensure log file directory exists and script can write to it (as root)
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE" # Will be owned by root

exec >> "$LOG_FILE" 2>&1

echo "---=== [$(date)] Starting Update Check (User: $(whoami)) ===---"

if [ ! -d "$CLONE_DIR" ] || [ ! -d "$CLONE_DIR/.git" ]; then
    echo "[ERROR] Clone directory '$CLONE_DIR' not found or is not a git repository. Cannot check for updates."
    echo "The main application might not have been installed correctly or the clone directory was moved/deleted."
    exit 1
fi

cd "$CLONE_DIR" || { echo "[ERROR] Failed to cd into '$CLONE_DIR'."; exit 1; }

# It's good practice for root to not own the git repository files if possible,
# but for this simple checker, git commands will run as root.
# If the CLONE_DIR was created by a non-root user initially, git operations might fail.
# The main installer should ensure CLONE_DIR is usable by the update process.

CURRENT_GIT_USER=$(git config user.name || echo "not set")
CURRENT_GIT_EMAIL=$(git config user.email || echo "not set")

# Temporarily set a generic user for git operations if not configured, to avoid errors
NEEDS_GIT_CONFIG_RESET=false
if [ "$CURRENT_GIT_USER" == "not set" ] || [ "$CURRENT_GIT_EMAIL" == "not set" ]; then
    echo "[INFO] Git user.name or user.email not set in $CLONE_DIR. Setting temporarily for fetch/pull."
    git config user.name "Update Checker"
    git config user.email "updater@localhost"
    NEEDS_GIT_CONFIG_RESET=true
fi


LOCAL_HASH_BEFORE_FETCH=$(git rev-parse HEAD 2>/dev/null || echo "unknown_local")
echo "[INFO] Current local commit in $CLONE_DIR: $LOCAL_HASH_BEFORE_FETCH"

echo "[INFO] Fetching remote updates for branch '$BRANCH_TO_TRACK' (from origin)..."
if ! git fetch origin "$BRANCH_TO_TRACK"; then
    echo "[ERROR] Failed to fetch from remote repository. Exiting."
    if [ "$NEEDS_GIT_CONFIG_RESET" = true ]; then
        git config --unset user.name
        git config --unset user.email
    fi
    exit 1
fi
echo "[INFO] Fetch complete."

REMOTE_HASH=$(git rev-parse "origin/${BRANCH_TO_TRACK}" 2>/dev/null || echo "unknown_remote")
echo "[INFO] Latest remote commit on 'origin/${BRANCH_TO_TRACK}': $REMOTE_HASH"

if [ "$NEEDS_GIT_CONFIG_RESET" = true ]; then
    echo "[INFO] Resetting temporary git user.name and user.email."
    git config --unset user.name
    git config --unset user.email
fi

if [ "$LOCAL_HASH_BEFORE_FETCH" == "$REMOTE_HASH" ] || [ "$REMOTE_HASH" == "unknown_remote" ]; then
    echo "[INFO] No new commits found. Application is up-to-date."
    echo "---=== [$(date)] Update Check Finished ===---"
    exit 0
fi

echo "[INFO] New version detected! Local: $LOCAL_HASH_BEFORE_FETCH, Remote: $REMOTE_HASH."
echo "[INFO] Triggering main installer in update mode: $MAIN_INSTALLER_SCRIPT_PATH --update"

# The main installer script is called directly; it will run as root (since this checker runs as root).
# The main installer script has its own sudo calls for specific operations if needed,
# but if called by root, sudo is implicit.
if "$MAIN_INSTALLER_SCRIPT_PATH" --update; then
    echo "[SUCCESS] Main installer script completed successfully in update mode."
else
    RETURN_CODE=$?
    echo "[ERROR] Main installer script failed in update mode with exit code $RETURN_CODE."
fi

echo "---=== [$(date)] Update Check Finished (Update Triggered) ===---"
exit 0
