#!/bin/bash
# Emergency context save before auto-compact
# Called by PreCompact hook when context reaches 80% threshold
#
# Receives JSON via stdin with:
#   - transcript_path: Path to session transcript
#   - session_id: Current session ID
#   - cwd: Current working directory
#
# Creates emergency save marker in /tmp/claude-contexts/

set -e

# Read JSON input from stdin
input=$(cat)

# Parse JSON fields (requires jq)
if command -v jq &> /dev/null; then
    TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // empty')
    SESSION=$(echo "$input" | jq -r '.session_id // empty')
    CWD=$(echo "$input" | jq -r '.cwd // empty')
else
    # Fallback if jq not available - use basic parsing
    TRANSCRIPT=""
    SESSION=""
    CWD=$(pwd)
fi

# Get project name from cwd
if [ -n "$CWD" ]; then
    PROJECT_DIR=$(basename "$CWD")
else
    PROJECT_DIR="unknown"
fi

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
SAVE_DIR="/tmp/claude-contexts"
SAVE_PATH="${SAVE_DIR}/${TIMESTAMP}-${PROJECT_DIR}-emergency.md"

# Create save directory
mkdir -p "$SAVE_DIR"

# Create emergency save marker
cat > "$SAVE_PATH" << EOF
# Emergency Context Save

**Session:** ${SESSION:-unknown}
**Project:** ${PROJECT_DIR}
**Saved:** $(date -Iseconds)
**Reason:** Auto-compact triggered (80% context threshold)

---

## Recovery Instructions

This was an emergency save triggered by approaching context limits.

### Check these locations for context:

1. **Swarm progress checkpoints:**
   \`\`\`bash
   ls -lt .claude/swarm/progress/*.md 2>/dev/null | head -5
   \`\`\`

2. **Swarm reports:**
   \`\`\`bash
   ls -lt .claude/swarm/reports/*.md 2>/dev/null | head -5
   \`\`\`

3. **Research and plans:**
   \`\`\`bash
   ls -lt .claude/swarm/research/*.md 2>/dev/null | head -5
   ls -lt .claude/swarm/plans/*.md 2>/dev/null | head -5
   \`\`\`

4. **Other context saves:**
   \`\`\`bash
   ls -lt /tmp/claude-contexts/*.md 2>/dev/null | head -5
   \`\`\`

### To resume:

1. Start a new session
2. Run \`/load-context\` and select appropriate source
3. Or run \`/auto --resume\` if you were in auto mode

---

## Transcript Reference

${TRANSCRIPT:+Transcript path: $TRANSCRIPT}
${TRANSCRIPT:-Transcript path not available}

EOF

echo "Emergency save created: $SAVE_PATH" >&2
exit 0
