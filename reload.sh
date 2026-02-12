#!/bin/bash
set -e

PROFILE_NAME="${PROFILE_NAME:-ai-agent}"
PROFILE_SOURCE="./ai-agent.apparmor"
PROFILE_DEST="/etc/apparmor.d/$PROFILE_NAME"
BACKUP_DIR="/var/backups/apparmor"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Check if source profile exists
if [ ! -f "$PROFILE_SOURCE" ]; then
    echo "Error: Profile file not found: $PROFILE_SOURCE"
    exit 1
fi

# Backup existing profile if it exists
if [ -f "$PROFILE_DEST" ]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/$PROFILE_NAME.$(date +%Y%m%d-%H%M%S)"
    cp "$PROFILE_DEST" "$BACKUP_FILE"
    echo "Backed up existing profile to $BACKUP_FILE"
fi

# Copy and reload profile
cp "$PROFILE_SOURCE" "$PROFILE_DEST"
echo "Installing profile..."

if apparmor_parser -r "$PROFILE_DEST"; then
    echo "Profile installed and loaded successfully"
else
    echo "Error: Failed to load profile"
    exit 1
fi
