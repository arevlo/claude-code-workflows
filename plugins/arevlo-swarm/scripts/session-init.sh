#!/bin/bash
# Session initialization - called at SessionStart hook
# Sets up context tracking for new session
#
# Receives JSON via stdin with session information:
#   - session_id: Current session ID
#   - cwd: Current working directory
#
# Creates guardian directory structure and initializes metrics

set -e

# Read JSON input from stdin
input=$(cat)

# Parse JSON fields
if command -v jq &> /dev/null; then
    SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
    CWD=$(echo "$input" | jq -r '.cwd // empty')
else
    SESSION_ID=""
    CWD=$(pwd)
fi

# Set working directory
if [ -n "$CWD" ]; then
    cd "$CWD" 2>/dev/null || true
fi

# Create directory structure
mkdir -p .claude/swarm/{guardian,context,progress,reports,research,plans}

GUARDIAN_DIR=".claude/swarm/guardian"
METRICS_FILE="$GUARDIAN_DIR/metrics.json"
SESSION_LOG="$GUARDIAN_DIR/session.log"

# Initialize fresh metrics for new session
cat > "$METRICS_FILE" << EOF
{
  "session_start": "$(date -Iseconds)",
  "session_id": "${SESSION_ID:-unknown}",
  "tool_invocations": 0,
  "message_count": 0,
  "file_reads": 0,
  "code_edits": 0,
  "last_checkpoint": null,
  "alert_level": "good",
  "alerts_triggered": []
}
EOF

# Clear previous alerts (start fresh each session)
echo "# Context Health Alerts" > "$GUARDIAN_DIR/alerts.md"
echo "" >> "$GUARDIAN_DIR/alerts.md"
echo "Session started: $(date -Iseconds)" >> "$GUARDIAN_DIR/alerts.md"
echo "" >> "$GUARDIAN_DIR/alerts.md"

# Log session start
echo "$(date -Iseconds) - Session initialized: ${SESSION_ID:-unknown}" >> "$SESSION_LOG"

# Check for prior context that could be resumed
PRIOR_CONTEXT=""
OUTPUT_MSG="Context tracking initialized."

# Check swarm progress checkpoints
if [ -d ".claude/swarm/progress" ]; then
    LATEST_CHECKPOINT=$(ls -t .claude/swarm/progress/*.md 2>/dev/null | head -1)
    if [ -n "$LATEST_CHECKPOINT" ]; then
        PRIOR_CONTEXT="$LATEST_CHECKPOINT"
    fi
fi

# Check context pointer
if [ -f ".claude/swarm/context/latest-save.txt" ]; then
    SAVED_PATH=$(cat .claude/swarm/context/latest-save.txt)
    if [ -f "$SAVED_PATH" ]; then
        PRIOR_CONTEXT="$SAVED_PATH"
    fi
fi

# Check /tmp saves
if [ -d "/tmp/claude-contexts" ]; then
    PROJECT_NAME=$(basename "$CWD")
    LATEST_TMP=$(ls -t /tmp/claude-contexts/*${PROJECT_NAME}*.md 2>/dev/null | head -1)
    if [ -n "$LATEST_TMP" ]; then
        if [ -z "$PRIOR_CONTEXT" ]; then
            PRIOR_CONTEXT="$LATEST_TMP"
        fi
    fi
fi

# Output status
if [ -n "$PRIOR_CONTEXT" ]; then
    echo "$OUTPUT_MSG Prior context available: $PRIOR_CONTEXT"
else
    echo "$OUTPUT_MSG No prior context found."
fi

exit 0
