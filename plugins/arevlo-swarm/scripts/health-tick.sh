#!/bin/bash
# Health tick - called after each tool use to track context proxy signals
# Used by PostToolUse hook to estimate context usage
#
# Receives JSON via stdin with tool information:
#   - tool_name: Name of the tool that was used
#   - tool_input: Input parameters (may be truncated)
#   - session_id: Current session ID
#   - cwd: Current working directory
#
# Updates metrics in .claude/swarm/guardian/metrics.json
# Triggers alerts when thresholds are exceeded

set -e

# Read JSON input from stdin
input=$(cat)

# Parse JSON fields
if command -v jq &> /dev/null; then
    TOOL_NAME=$(echo "$input" | jq -r '.tool_name // empty')
    SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
    CWD=$(echo "$input" | jq -r '.cwd // empty')
else
    # Fallback - basic extraction without jq
    TOOL_NAME=""
    SESSION_ID=""
    CWD=$(pwd)
fi

# Set working directory
if [ -n "$CWD" ]; then
    cd "$CWD" 2>/dev/null || true
fi

# Ensure guardian directory exists
GUARDIAN_DIR=".claude/swarm/guardian"
mkdir -p "$GUARDIAN_DIR"

METRICS_FILE="$GUARDIAN_DIR/metrics.json"
ALERTS_FILE="$GUARDIAN_DIR/alerts.md"

# Initialize metrics file if it doesn't exist
if [ ! -f "$METRICS_FILE" ]; then
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
fi

# Read current metrics
if command -v jq &> /dev/null; then
    TOOL_COUNT=$(jq -r '.tool_invocations // 0' "$METRICS_FILE")
    MESSAGE_COUNT=$(jq -r '.message_count // 0' "$METRICS_FILE")
    FILE_READS=$(jq -r '.file_reads // 0' "$METRICS_FILE")
    CODE_EDITS=$(jq -r '.code_edits // 0' "$METRICS_FILE")
    CURRENT_LEVEL=$(jq -r '.alert_level // "good"' "$METRICS_FILE")
else
    # Fallback - start fresh each time without jq
    TOOL_COUNT=0
    MESSAGE_COUNT=0
    FILE_READS=0
    CODE_EDITS=0
    CURRENT_LEVEL="good"
fi

# Increment counters based on tool type
TOOL_COUNT=$((TOOL_COUNT + 1))

case "$TOOL_NAME" in
    "Read"|"Glob"|"Grep")
        FILE_READS=$((FILE_READS + 1))
        ;;
    "Edit"|"Write"|"MultiEdit"|"NotebookEdit")
        CODE_EDITS=$((CODE_EDITS + 1))
        ;;
    "Task")
        # Task tool spawns agents - count as multiple operations
        MESSAGE_COUNT=$((MESSAGE_COUNT + 5))
        ;;
    "Bash"|"BashOutput")
        # Shell commands - moderate weight
        MESSAGE_COUNT=$((MESSAGE_COUNT + 1))
        ;;
    *)
        # Other tools
        MESSAGE_COUNT=$((MESSAGE_COUNT + 1))
        ;;
esac

# Calculate alert level based on thresholds
# These are proxy signals - not exact context measurement
WARNING_SIGNALS=0
NEW_LEVEL="good"

# Check thresholds
if [ "$MESSAGE_COUNT" -gt 30 ]; then
    WARNING_SIGNALS=$((WARNING_SIGNALS + 1))
fi

if [ "$FILE_READS" -gt 50 ]; then
    WARNING_SIGNALS=$((WARNING_SIGNALS + 1))
fi

if [ "$CODE_EDITS" -gt 30 ]; then
    WARNING_SIGNALS=$((WARNING_SIGNALS + 1))
fi

if [ "$TOOL_COUNT" -gt 100 ]; then
    WARNING_SIGNALS=$((WARNING_SIGNALS + 1))
fi

# Determine alert level
if [ "$WARNING_SIGNALS" -ge 4 ]; then
    NEW_LEVEL="critical"
elif [ "$WARNING_SIGNALS" -ge 3 ]; then
    NEW_LEVEL="warning"
elif [ "$WARNING_SIGNALS" -ge 2 ]; then
    NEW_LEVEL="watch"
else
    NEW_LEVEL="good"
fi

# Check if level changed (for alerts)
LEVEL_CHANGED="false"
if [ "$NEW_LEVEL" != "$CURRENT_LEVEL" ]; then
    LEVEL_CHANGED="true"
fi

# Update metrics file
if command -v jq &> /dev/null; then
    jq --arg level "$NEW_LEVEL" \
       --argjson tools "$TOOL_COUNT" \
       --argjson msgs "$MESSAGE_COUNT" \
       --argjson reads "$FILE_READS" \
       --argjson edits "$CODE_EDITS" \
       '.alert_level = $level | .tool_invocations = $tools | .message_count = $msgs | .file_reads = $reads | .code_edits = $edits | .last_updated = (now | todate)' \
       "$METRICS_FILE" > "${METRICS_FILE}.tmp" && mv "${METRICS_FILE}.tmp" "$METRICS_FILE"
else
    # Fallback - write simple format
    cat > "$METRICS_FILE" << EOF
{
  "session_start": "$(date -Iseconds)",
  "session_id": "${SESSION_ID:-unknown}",
  "tool_invocations": $TOOL_COUNT,
  "message_count": $MESSAGE_COUNT,
  "file_reads": $FILE_READS,
  "code_edits": $CODE_EDITS,
  "last_checkpoint": null,
  "alert_level": "$NEW_LEVEL",
  "alerts_triggered": []
}
EOF
fi

# Write alert if level changed to watch or higher
if [ "$LEVEL_CHANGED" = "true" ] && [ "$NEW_LEVEL" != "good" ]; then
    TIMESTAMP=$(date -Iseconds)

    # Append to alerts file
    cat >> "$ALERTS_FILE" << EOF

---

## Alert: Context level changed to ${NEW_LEVEL^^}

**Time:** $TIMESTAMP
**Signals:** $WARNING_SIGNALS warning signals active

### Current Metrics
- Tool invocations: $TOOL_COUNT
- Message count: $MESSAGE_COUNT
- File reads: $FILE_READS
- Code edits: $CODE_EDITS

### Recommended Action
EOF

    case "$NEW_LEVEL" in
        "watch")
            echo "- Consider saving a checkpoint soon with \`/checkpoint\`" >> "$ALERTS_FILE"
            ;;
        "warning")
            cat >> "$ALERTS_FILE" << EOF
- Save checkpoint NOW with \`/checkpoint\`
- Consider running \`/compact\` to reduce context
- Wrap up current task before starting new work
EOF
            ;;
        "critical")
            cat >> "$ALERTS_FILE" << EOF
- **IMMEDIATELY** save checkpoint with \`/checkpoint\`
- Run \`/compact\` to reduce context
- Complete current work gracefully
- Avoid starting new complex tasks
EOF
            ;;
    esac
fi

# Output current status for logging (goes to stderr so it doesn't interfere)
echo "Health tick: level=$NEW_LEVEL tools=$TOOL_COUNT reads=$FILE_READS edits=$CODE_EDITS" >&2

exit 0
