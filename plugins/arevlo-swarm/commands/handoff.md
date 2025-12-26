---
description: Prepare handoff to successor agent when approaching context limits
allowed-tools: Bash,Write,Read,Task,AskUserQuestion
---

Create continuation context and spawn successor agent.

## Usage

```
/handoff [goal]
```

## When to Use

- Guardian shows CRITICAL alert (70%+ estimate)
- PreCompact hook fires (80%)
- Responses slowing significantly
- Proactively before long implementation phases

## Steps

### 1. Export Final State

Prompt user:

```
Handoff preparation.

Please run the following command:

/export

Save to: .claude/swarm/handoff/session-final-$(date +%Y%m%d-%H%M%S).txt

(You can download the export or copy to clipboard, then save to the path above)
```

Wait for user confirmation that export was saved.

### 2. Generate Continuation Prompt

From the export and current working memory, create:

```markdown
## Continuation Prompt for Successor Agent

### Context Source

Load from: .claude/swarm/handoff/session-final-{timestamp}.txt

### Mission

[Original goal from export or args]

### Progress So Far

- [Completed work]
- [Current state]
- [Blockers/challenges encountered]

### Files Modified

- `path/file.ts` - [changes made]
- `path/other.ts` - [changes made]

### Critical Context

[Essential information successor needs]

### Immediate Next Steps

1. [Next action]
2. [After that]
3. [Long-term goal]

### Approach/Strategy

[How to proceed, lessons learned]

### Available Resources

- Research: [path if exists]
- Plan: [path if exists]
- Progress checkpoints: [paths]
- Full session export: .claude/swarm/handoff/session-final-{timestamp}.txt
```

Save to: `.claude/swarm/handoff/continuation-prompt-{timestamp}.md`

### 3. Spawn Successor Agent

Use Task tool with subagent_type: "general-purpose"

Prompt:

```
You are continuing work from a prior session that reached context limits.

Load context from: .claude/swarm/handoff/continuation-prompt-{timestamp}.md

Your mission: {goal}

Current state: {state from prompt}
Next steps: {steps from prompt}

Continue the work seamlessly. Full session history available at:
.claude/swarm/handoff/session-final-{timestamp}.txt
(Reference if you need detailed context)

IMPORTANT: You have a fresh context window. Work efficiently to complete the mission.
```

### 4. Graceful Exit

Original agent reports:

```
✓ Handoff complete

Successor agent spawned to continue work.
Continuation prompt: .claude/swarm/handoff/continuation-prompt-{timestamp}.md
Full context: .claude/swarm/handoff/session-final-{timestamp}.txt

Original session ending gracefully.
```

## Notes

- Handoff preserves ALL context via export
- Continuation prompt provides structured entry point
- Successor loads summary, references export as needed
- Seamless continuation without context loss
- Successor has fresh context window to complete work
