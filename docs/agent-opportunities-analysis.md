# Agent & Context Awareness Opportunities Analysis

## Executive Summary

Your swarm architecture is solid, but there's a fundamental gap: **the 40-70% context thresholds are documented but not observable**. Claude Code cannot introspect its own context usage at runtime, making the threshold protocol aspirational rather than operational.

This analysis identifies opportunities for:
1. Background agents that work around context blindness
2. Skills that provide context-native capabilities
3. Commands that improve visibility and proactive management
4. Architectural changes to make context awareness practical

---

## Current Architecture Gaps

### The Core Problem: Context Blindness

```
Current Reality:
┌────────────────────────────────────────────────────────────┐
│                     Context Usage                          │
├──────────┬──────────┬──────────┬──────────┬───────────────┤
│  0-40%   │  40-60%  │  60-70%  │  70-80%  │    80%+       │
│  (Good)  │  (Watch) │ (Warning)│(Critical)│  PreCompact   │
├──────────┴──────────┴──────────┴──────────┼───────────────┤
│      NO VISIBILITY - CLAUDE CAN'T SEE     │   HOOK FIRES  │
│      WHERE IT IS IN THIS RANGE            │   (too late)  │
└───────────────────────────────────────────┴───────────────┘
```

**The problem:** Your Context Protocol (auto.md:390-396, README:212-217) defines thresholds, but:
- PreCompact hook fires ONLY at 80% - no earlier triggers
- Claude cannot query "what % of context am I using?"
- Checkpointing at 40%, 60%, 70% is manual/aspirational
- Agents don't know when to compact - they just get cut off

### What's Missing

1. **No runtime context percentage API** - Can't query current usage
2. **No intermediate hooks** - Only PreCompact (80%) exists
3. **No periodic health checks** - Agents run blind until limit
4. **No proactive compaction** - Must wait for emergency save

---

## Opportunity 1: Background Context Guardian Agent

### Concept

A background agent that monitors session health using **proxy signals** since direct context measurement isn't available.

### Implementation: `/guardian` Command

```markdown
---
description: Start background context guardian for proactive session management
allowed-tools: Bash,Read,Write,Glob
---

## Context Guardian Agent

Monitors session health through proxy signals and triggers proactive saves.

### Proxy Signals for Context Usage

Since we can't measure context directly, monitor these indicators:

| Signal | Measurement | Threshold |
|--------|-------------|-----------|
| Message count | Track conversation turns | > 30 turns = warning |
| File reads | Count Read tool invocations | > 50 reads = warning |
| Code edits | Count Edit/Write invocations | > 30 edits = warning |
| Time elapsed | Session duration | > 45 min = warning |
| Response latency | Track if responses slow down | Increasing = warning |
| Output truncation | Monitor for "..." in responses | Truncation = critical |

### Background Process

1. Start a lightweight watcher that:
   - Tracks proxy signals in `.claude/swarm/guardian/metrics.json`
   - Updates every N tool invocations
   - Writes warnings to `.claude/swarm/guardian/alerts.md`

2. Periodic checkpoint triggers:
   - WATCH (2+ proxy warnings): Save soft checkpoint
   - WARNING (3+ proxy warnings): Compact and checkpoint
   - CRITICAL (4+ or truncation): Emergency save + alert

### Integration

- Runs alongside swarm agents
- Writes to shared `.claude/swarm/` directory
- Guardian alerts visible via `/hive` command
```

### Alternative: Hook-Based Health Check

Add a `PostToolUse` hook that counts invocations:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [{
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/health-tick.sh",
          "timeout": 1000
        }]
      }
    ]
  }
}
```

Where `health-tick.sh` increments a counter and triggers saves at thresholds.

---

## Opportunity 2: Context Compaction Skill

### Concept

A skill that Claude can invoke to proactively compact its working memory without waiting for PreCompact.

### Implementation: `context-compact` Skill

```markdown
# context-compact Skill

Proactively compact working memory when context feels heavy.

## When to Use

- After completing a major phase
- When responses feel slower
- Before starting a new complex task
- When you've read many files

## Steps

1. **Summarize current state** (don't repeat file contents):
   ```
   ## Current Working Memory
   - Goal: [active goal]
   - Phase: [current phase]
   - Key files: [list paths only, not contents]
   - Next step: [immediate next action]
   ```

2. **Archive detailed findings** to `.claude/swarm/context/`:
   - Write verbose details to file
   - Keep only summary in memory

3. **Clear mental cache**:
   - Reference files by path, don't hold contents
   - Point to research/plan files instead of recapping

4. **Checkpoint**:
   - Save progress to `.claude/swarm/progress/`
   - Update context pointer

## Output Format

After compacting, state:
```
Context compacted. Working memory now holds:
- Active goal + current phase
- File references (paths only)
- Immediate next steps
- Pointers to: [research|plan|progress files]
```
```

---

## Opportunity 3: Proactive Checkpoint Commands

### `/checkpoint` - Manual Save Point

```markdown
---
description: Create a checkpoint of current session state
allowed-tools: Write,Bash,Glob
---

Quick checkpoint without full save-context flow.

## Usage
/checkpoint [label]

## Steps
1. Generate minimal checkpoint:
   - Current goal
   - Work completed (bullet points)
   - Files modified (paths)
   - Next steps
2. Save to `.claude/swarm/progress/checkpoint-{timestamp}-{label}.md`
3. Update context pointer
4. Report checkpoint created (one line)

## Difference from /save-context
- Faster (no destination picker)
- Minimal format (not full session summary)
- Designed for mid-task use
- No Notion/GitHub integration
```

### `/compact` - Proactive Memory Reduction

```markdown
---
description: Proactively reduce context usage before limits
allowed-tools: Write,Read,Glob
---

Trigger proactive compaction when context feels heavy.

## Usage
/compact

## Steps
1. Save current detailed state to `.claude/swarm/context/detailed-{timestamp}.md`
2. Generate minimal summary for continued work
3. Clear verbose details from working memory
4. Report reduction estimate

## Best Used When
- After reading many files
- Before starting new phase
- When responses feel slower
- Preventatively during long sessions
```

---

## Opportunity 4: Swarm Context Coordinator Agent

### Concept

A meta-agent that coordinates context across swarm agents, preventing collective context exhaustion.

### Implementation: `context-coordinator` Agent

```markdown
# Context Coordinator Agent

Meta-agent that manages context health across the swarm.

## Responsibilities

1. **Monitor swarm health**
   - Track which agents are running
   - Monitor output sizes from each agent
   - Detect agents approaching limits (via output truncation)

2. **Coordinate compaction**
   - Trigger agent checkpoints before limits
   - Rotate agents if one exhausts context
   - Consolidate findings before agent death

3. **Manage handoffs**
   - When agent approaches limit, spawn successor
   - Pass essential context to successor
   - Archive exhausted agent's findings

4. **Aggregate intelligence**
   - Combine findings from multiple agents
   - Deduplicate across agent reports
   - Prioritize by severity + agent consensus

## Output

Writes to `.claude/swarm/coordinator/`:
- `health.json` - Agent health status
- `handoffs/` - Handoff records
- `consolidated.md` - Combined findings
```

---

## Opportunity 5: Session Start Hook for Context Initialization

### Concept

Use the `SessionStart` hook to initialize context tracking at the beginning of every session.

### Implementation

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/session-init.sh",
          "timeout": 5000
        }]
      }
    ]
  }
}
```

`session-init.sh`:
```bash
#!/bin/bash
# Initialize context tracking for new session

mkdir -p .claude/swarm/{guardian,context,progress}

# Initialize metrics
cat > .claude/swarm/guardian/metrics.json << EOF
{
  "session_start": "$(date -Iseconds)",
  "message_count": 0,
  "file_reads": 0,
  "code_edits": 0,
  "last_checkpoint": null,
  "alerts": []
}
EOF

# Check for prior session context to resume
if [ -f .claude/swarm/context/latest-save.txt ]; then
  echo "Prior context available: $(cat .claude/swarm/context/latest-save.txt)"
fi

echo "Context tracking initialized"
```

---

## Opportunity 6: Background Research Agent Pool

### Concept

Instead of one research agent, maintain a pool of specialized researchers that can be spawned for specific tasks.

### Implementation: Agent Pool

```
Research Agent Pool:
├── architecture-researcher   # Codebase structure & patterns
├── dependency-researcher     # Package dependencies & versions
├── api-researcher            # API contracts & endpoints
├── test-researcher           # Test coverage & patterns
├── history-researcher        # Git history & change patterns
└── security-researcher       # Security patterns & vulnerabilities
```

### Benefits

- Each researcher has focused, smaller context
- Can spawn multiple in parallel
- Findings are siloed, reducing main agent load
- Can rotate researchers if one exhausts context

---

## Opportunity 7: Incremental Context Loading

### Concept

Instead of loading full context at session start, load incrementally as needed.

### Implementation: `/context-stream` Command

```markdown
---
description: Stream context from prior session incrementally
allowed-tools: Read,Glob,AskUserQuestion
---

Load context piece by piece instead of all at once.

## Usage
/context-stream [source]

## Steps
1. List available context pieces from source:
   - Research findings
   - Implementation plan
   - Progress checkpoints
   - Agent reports

2. Ask user which pieces to load:
   - Show one-line summary of each
   - Let user select relevant pieces
   - Load only selected items

3. Summarize what was loaded (not full content)

## Difference from /load-context
- Doesn't load everything
- Shows summaries before loading
- User controls what enters context
- Reduces initial context footprint
```

---

## Opportunity 8: Context-Aware Todo Integration

### Concept

Enhance TodoWrite to include context health metadata.

### Implementation: Extended Todo Format

```json
{
  "todos": [
    {
      "content": "Implement auth middleware",
      "status": "in_progress",
      "activeForm": "Implementing auth middleware",
      "context_snapshot": {
        "files_read": 12,
        "edits_made": 5,
        "checkpoint_available": true
      }
    }
  ]
}
```

### Benefits

- Todos track context state when created
- Can see which todos were created when context was fresh
- Helps prioritize: tackle complex todos while context is low

---

## Opportunity 9: Automatic Rotation Agent

### Concept

An agent that monitors the main session and automatically spawns a successor when context approaches limits.

### Implementation: `/auto-rotate` Mode

```markdown
## Auto-Rotation Protocol

When enabled, the session automatically hands off to a successor:

1. **Monitor phase** (continuous):
   - Track proxy signals
   - Watch for limit indicators

2. **Preparation phase** (at 60% estimate):
   - Save full checkpoint
   - Generate continuation prompt
   - Prepare handoff context

3. **Handoff phase** (at 70% estimate):
   - Spawn successor agent via Task tool
   - Pass checkpoint reference
   - Successor loads context and continues
   - Original gracefully exits

4. **Recovery** (if crash):
   - Successor loads from checkpoint
   - Continues from last known state
```

---

## Opportunity 10: Skills to Build

Based on gaps in current architecture:

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `context-compact` | Proactive memory reduction | Manual or auto at thresholds |
| `research-loader` | Load research from prior session | Session start |
| `plan-executor` | Execute plan phases with built-in checkpointing | `/auto` phase 3 |
| `handoff-generator` | Create context for successor agent | Approaching limits |
| `finding-deduper` | Deduplicate agent findings | `/sync` command |
| `checkpoint-validator` | Verify checkpoint is complete and loadable | After save |

---

## Summary: Priority Recommendations

### High Priority (Build First)

1. **Background health tick hook** - Track proxy signals via PostToolUse
2. **`/checkpoint` command** - Fast manual save points
3. **`/compact` command** - Proactive memory reduction
4. **Session init hook** - Initialize tracking every session

### Medium Priority

5. **Context coordinator agent** - Manage swarm context health
6. **`/context-stream` command** - Incremental context loading
7. **Guardian agent** - Background monitoring via proxy signals

### Lower Priority (Nice to Have)

8. **Auto-rotation mode** - Automatic successor spawning
9. **Research agent pool** - Specialized parallel researchers
10. **Extended todo format** - Context metadata in todos

---

## Key Insight

**The 40-70% thresholds will remain aspirational until either:**

1. Claude Code exposes a context usage API (product change), OR
2. You build proxy signal monitoring that estimates context usage

Option 2 is achievable now with hooks and background agents. The proxy signals won't be perfectly accurate, but they'll be far better than the current situation of complete blindness until 80%.

---

## Proposed Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        MAIN SESSION                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Context Guardian (Background)                            │   │
│  │  - Tracks proxy signals                                   │   │
│  │  - Triggers checkpoints at estimated thresholds           │   │
│  │  - Writes alerts to .claude/swarm/guardian/               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Swarm Agents (Parallel)                                  │   │
│  │  - Each has own context window                            │   │
│  │  - Write findings to .claude/swarm/reports/               │   │
│  │  - Coordinator monitors collective health                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Checkpoint System                                        │   │
│  │  - /checkpoint for manual saves                           │   │
│  │  - /compact for proactive reduction                       │   │
│  │  - PreCompact hook for emergency (80%)                    │   │
│  │  - All write to .claude/swarm/progress/                   │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

Hooks:
├── SessionStart → Initialize tracking
├── PostToolUse → Increment counters, check thresholds
└── PreCompact → Emergency save (existing)
```

This architecture provides estimated visibility into the 40-70% range through proxy signals, while maintaining the emergency save at 80%.
