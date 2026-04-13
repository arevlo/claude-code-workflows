# Save a memory

Evaluate and persist a user-provided memory to both local markdown and mem0.

## Arguments

- `<text>` (required) — natural language description of what to remember. Can be a fact, preference, decision, reference, or anything the user considers worth persisting.

## What this command does

The user is explicitly asking you to save something to memory. But **you are still the filter** — not everything belongs in memory. Evaluate the input, save it if it's worth keeping, and explain your decision either way.

## Step 1 — Detect project context

```bash
set -euo pipefail
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
REPO_NAME=$(basename "$PROJECT_ROOT")
SLUG=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
SANITIZED=$(echo "$PROJECT_ROOT" | sed 's|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/${SANITIZED}/memory"
MEM0_USER_ID="${CLAUDE_MEM0_USER_ID:-$(whoami)}"
echo "SLUG=$SLUG"
echo "MEMORY_DIR=$MEMORY_DIR"
echo "MEM0_USER_ID=$MEM0_USER_ID"
```

If the project doesn't have memory initialized (no `MEMORY.md`), tell the user to run `/memory:init` first. Don't silently bootstrap — that command exists for a reason.

## Step 2 — Evaluate the input

Read the user's `<text>` and determine:

### A) Is this worth saving?

**Save** if it's:
- A user preference, role detail, or working style that shapes future interactions
- Feedback or a correction (something they want you to do or stop doing)
- Non-obvious project context that can't be derived from the code or git history
- A reference to an external resource and its purpose
- A decision and its rationale

**Don't save** if it's:
- Derivable from the codebase (file paths, code patterns, architecture)
- Derivable from git history (who changed what, recent commits)
- Already documented in CLAUDE.md files
- Ephemeral task context (current debugging session, in-progress work)
- A fixable issue — fix it instead (see: "fix it, don't memo it")

If you decide not to save, explain why in one sentence and suggest an alternative if relevant (e.g., "that's already in your CLAUDE.md" or "I can fix that right now instead of saving a note about it").

### B) Classify the memory type

| Type | When |
|------|------|
| `user` | About the person — role, preferences, knowledge, goals |
| `feedback` | Guidance on approach — corrections AND validated choices |
| `project` | Non-derivable project context — decisions, constraints, stakeholders |
| `reference` | Pointers to external resources — URLs, tools, channels |

### C) Determine the scope

Which project does this memory belong to? Usually the current one, but the user might be saying something that applies globally or to a different project. Use your judgment:

- If it's clearly about the current project → save under current project's slug
- If it's about a specific other project → save under that project's slug (check that its memory dir exists)
- If it's about the user generally (preferences, role, working style) → save under the parent working directory's memory (the global-ish scope)

### D) Choose a filename

Derive from the type and a short topic slug: `{type}_{topic}.md`

Examples: `user_design_background.md`, `feedback_no_summaries.md`, `project_merge_freeze.md`, `reference_linear_bugs.md`

## Step 3 — Check for duplicates

Read `MEMORY.md` for the target scope. If an existing memory covers the same ground, **update it** instead of creating a new one. Use `Edit` on the local file, then `mcp__mem0-mcp__update_memory` (find the `memory_id` via `search_memories` with the same `app_id`).

## Step 4 — Write

If saving:

1. **Local file** — write the memory file with frontmatter:

```markdown
---
name: <short name>
description: <one-line description — specific enough for relevance matching>
type: <user|feedback|project|reference>
---

<memory content>

For feedback/project types, structure as:
- The fact or rule
- **Why:** <motivation>
- **How to apply:** <when/where this kicks in>
```

2. **MEMORY.md** — add a one-line entry to the index.

3. **mem0** — call `mcp__mem0-mcp__add_memory` with:
   - `text`: concise one-to-two sentence summary (not the full markdown body)
   - `user_id`: the resolved user ID
   - `app_id`: the target project slug
   - `metadata`: `{ "type": "<type>", "file": "<filename>.md", "source": "auto-memory-mirror" }`

## Step 5 — Confirm

Report back concisely:

```
Saved: <name> → <filename>.md (type: <type>, scope: <slug>)
```

Or if you decided not to save:

```
Skipped: <one-sentence reason>
```

Keep it short. The user doesn't need a paragraph about what you did.
