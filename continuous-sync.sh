#!/bin/bash

# Continuous Synchronization Monitor
# Keeps local project perfectly synced with GitHub

set -e

WATCH_DIR="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
SYNC_INTERVAL=30  # seconds

echo "🔄 Bridge Template - Continuous Sync Monitor"
echo "============================================"
echo "Monitoring: $WATCH_DIR"
echo "Sync interval: ${SYNC_INTERVAL}s"
echo ""

cd "$WATCH_DIR"

# Function to sync changes
sync_changes() {
    if [ -n "$(git status --porcelain)" ]; then
        echo "📝 Changes detected, syncing..."
        
        # Add all changes
        git add .
        
        # Create timestamp commit
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        git commit -m "🔄 Auto-sync: $TIMESTAMP

Automated synchronization of local changes to GitHub.
Ensuring RAG system has latest codebase updates."
        
        # Push to GitHub
        git push origin main
        
        echo "✅ Sync complete at $TIMESTAMP"
    else
        echo "📊 No changes to sync at $(date +"%H:%M:%S")"
    fi
}

# Initial sync
echo "🚀 Starting continuous synchronization..."
sync_changes

# Continuous monitoring loop
while true; do
    sleep $SYNC_INTERVAL
    sync_changes
done
