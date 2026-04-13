---
description: Bootstrap the dual-write memory pattern for the current repo — derive a project slug, create CLAUDE.md and MEMORY.md scaffolding, and verify mem0 wiring with a live round-trip test. Use when the user says "init memory", "set up memory for this project", "scaffold memory", "bootstrap mem0", "memory init", or is starting a new repo that should participate in the dual-write memory system. Also use when the user wants to verify that mem0 is wired up correctly for the current project even if setup is already done — the command is idempotent and always runs the round-trip check.
argument-hint: "[slug]"
allowed-tools: Bash, Read, Write, Edit, mcp__mem0-mcp__add_memory, mcp__mem0-mcp__search_memories, mcp__mem0-mcp__get_event_status, mcp__mem0-mcp__delete_memory
---

# Init memory for this project

Bootstrap the **dual-write memory pattern** for the current repo: one store in local markdown (`~/.claude/projects/<sanitized-cwd>/memory/`) and one store in mem0 (scoped by project `app_id`). Idempotent — safe to run on a repo that's already been initialized.

## Arguments

- `$1` (optional) — **slug override**. If omitted, derive the slug from the repo directory name. Use this when the repo name doesn't match what you want the mem0 `app_id` to be (e.g., a repo called `my_special.project-v2` where you want the slug to be `my-project`).

## Why this command exists

Claude Code's local auto-memory is great for rich, markdown-structured notes tied to a specific working directory. mem0 is great for semantic search and cross-session retrieval. Neither alone covers both use cases, so we dual-write. But every new repo needs a small amount of setup to participate: a pinned slug, an index file, and a verified mem0 round trip. This command automates that setup and also serves as a health check — running it against an already-initialized repo re-verifies the mem0 wiring without touching the existing files.

## Step 1 — Detect project root and derive slug

Run in a single bash block and capture both values:

```bash
set -euo pipefail
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
REPO_NAME=$(basename "$PROJECT_ROOT")
echo "PROJECT_ROOT=$PROJECT_ROOT"
echo "REPO_NAME=$REPO_NAME"
echo "IS_GIT_REPO=$(git rev-parse --is-inside-work-tree 2>/dev/null || echo false)"
```

If `IS_GIT_REPO` is `false`, tell the user the current directory isn't inside a git repo and ask whether they want to continue using the cwd basename as the slug. If they decline, stop.

**Derive the slug** from the repo name, or use `$1` if provided:

```bash
# If $1 is provided, use it directly (still normalize for safety)
RAW_SLUG="${1:-$REPO_NAME}"
SLUG=$(echo "$RAW_SLUG" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
echo "SLUG=$SLUG"
```

If `$SLUG` ends up empty (pathological repo name), abort with a clear error — tell the user to pass an explicit slug.

Show the user the detected project root and slug, and if they didn't pass an explicit `$1` override, ask for confirmation **unless** the slug is clearly unambiguous (matches the repo name exactly with no transformation). For obvious cases like `marps → marps`, just proceed with a one-line note.

## Step 2 — Resolve the mem0 user_id

```bash
MEM0_USER_ID="${CLAUDE_MEM0_USER_ID:-$(whoami)}"
echo "MEM0_USER_ID=$MEM0_USER_ID"
```

This is the **person** axis — separate from `app_id` which is the **project** axis. The `mem0-mcp` server's *default* `user_id` is the string `"mem0-mcp"` (the automation identity, not the user), so we always pass `user_id` explicitly on writes. Document this in your summary so the user understands the distinction.

## Step 3 — Compute the local auto-memory directory

Claude Code's auto-memory system puts each project's memories under a sanitized version of the absolute cwd. The sanitization rule is: replace every `/` with `-` and prepend a leading `-`.

```bash
SANITIZED=$(echo "$PROJECT_ROOT" | sed 's|/|-|g')
MEMORY_DIR="$HOME/.claude/projects/${SANITIZED}/memory"
echo "MEMORY_DIR=$MEMORY_DIR"
mkdir -p "$MEMORY_DIR"
```

Create the directory if missing. This is safe to run on an existing dir.

## Step 4 — Check for the global `~/.claude/CLAUDE.md`

The dual-write pattern only works if the user's **global** Claude Code instructions tell future sessions to mirror writes. Check whether `~/.claude/CLAUDE.md` exists and whether it mentions mem0 mirroring.

```bash
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [ ! -f "$GLOBAL_CLAUDE_MD" ]; then
  GLOBAL_STATUS="missing"
elif grep -q "dual-write" "$GLOBAL_CLAUDE_MD" 2>/dev/null || grep -qi "mem0" "$GLOBAL_CLAUDE_MD" 2>/dev/null; then
  GLOBAL_STATUS="present-configured"
else
  GLOBAL_STATUS="present-unconfigured"
fi
echo "GLOBAL_STATUS=$GLOBAL_STATUS"
```

**Do NOT modify `~/.claude/CLAUDE.md` automatically** — that's a user-global file and editing it without consent is too invasive. Instead:

- If `missing`: warn the user that without global instructions, future sessions won't follow the dual-write rule. Point them at the README snippet (`plugins/memory/README.md` → "Dual-write pattern template"). Offer to create a minimal starter if they say yes explicitly.
- If `present-unconfigured`: warn that the file exists but doesn't reference mem0 mirroring. Offer to append a section if they say yes.
- If `present-configured`: good, move on silently.

## Step 5 — Handle the project-level `CLAUDE.md`

Read `$PROJECT_ROOT/CLAUDE.md` if it exists.

**If missing** — create it with this content (substitute `$SLUG` and `$SANITIZED`):

```markdown
# <SLUG>

<one-line description — ask the user or leave as a TODO placeholder>

## Memory

**Project slug**: `<SLUG>` — use this as the `app_id` when mirroring memories to mem0.

**Mem0 user_id**: derived from `$CLAUDE_MEM0_USER_ID` or `$(whoami)` — set per-machine, not per-project.

**Local memory directory**: `~/.claude/projects/<SANITIZED>/memory/`

This project follows the dual-write memory pattern in `~/.claude/CLAUDE.md` — every auto-memory save goes to both the local file system and mem0 (scoped by `user_id` + `app_id: "<SLUG>"`).
```

For the one-line description: if the repo has a `package.json` or `README.md`, try reading the first line/description field and use it. Otherwise leave `<TODO: describe this project>` and mention in the summary that the user should edit it.

**If present** — use the Read tool to inspect it. Check whether it already has a `## Memory` section or mentions the slug.

- **Already has a Memory section mentioning the slug** → leave it alone. Report "project CLAUDE.md already configured".
- **Has content but no memory section** → ask the user whether to append a `## Memory` section. If yes, use Edit to add it after the existing content. Never overwrite.
- **Has a memory section but wrong slug** → show the mismatch to the user and ask whether to update it. Don't silently change slugs — that could orphan old mem0 memories.

## Step 6 — Handle the `MEMORY.md` index

Check `$MEMORY_DIR/MEMORY.md`.

**If missing** — create it:

```markdown
# <SLUG> — memory index

Project slug: `<SLUG>` (mem0 `app_id`). See `~/.claude/CLAUDE.md` for the dual-write pattern.

## Memories

_(none yet — entries will appear here as memories are saved)_
```

**If present** — leave it alone. Report "MEMORY.md already exists".

## Step 7 — Verify mem0 round-trip

This is the health check — even on an already-initialized repo, always run this step so the user knows mem0 is reachable and the scoping works.

1. **Write a test memory** with `mcp__mem0-mcp__add_memory`:
   - `text`: `"memory:init round-trip test for project <SLUG> at <ISO timestamp>. Safe to delete."`
   - `user_id`: `$MEM0_USER_ID`
   - `app_id`: `$SLUG`
   - `metadata`: `{"type": "project", "source": "memory-init-roundtrip", "test": true}`

2. **Poll the event status** with `mcp__mem0-mcp__get_event_status` using the returned `event_id`. Mem0 writes are async and latency varies widely in practice — typical is 10–15s, but 50+s isn't unusual under load. Poll up to ~30 seconds. If still `PENDING` or `RUNNING` after 30s, fall through to the search fallback (step 2b) instead of hard-failing — the write is almost certainly still in flight, just slow.

2b. **Search fallback** — if polling timed out, call `mcp__mem0-mcp__search_memories` with `filters: {"AND": [{"user_id": "<MEM0_USER_ID>"}, {"app_id": "<SLUG>"}]}` and a query matching the test text. If the test memory shows up in results, treat the round-trip as succeeded and extract the `memory_id` from there. If it doesn't, report the event_id and tell the user the write is still queued — the round-trip isn't fully verified but the pipeline is reachable (the initial `add_memory` call didn't error).

3. **Extract the memory_id** from the `results` array of the succeeded event (or from the search fallback). Mem0 sometimes doesn't create a memory at all even on `SUCCEEDED` (it runs its own inference/extraction and may skip content it considers non-factual or meta — the test string "round-trip test, safe to delete" is a common case). If `results` is empty or null, report that the round-trip *succeeded* (the pipeline worked end-to-end) but no memory was materialized for cleanup, and skip the delete. This counts as a pass for health-check purposes.

4. **Delete the test memory** with `mcp__mem0-mcp__delete_memory` using the `memory_id`. This keeps the project's mem0 store clean.

5. **Optional sanity check** — call `mcp__mem0-mcp__search_memories` with `filters: {"AND": [{"user_id": "<MEM0_USER_ID>"}, {"app_id": "<SLUG>"}]}` and a short query. If there are existing memories for this project, mention the count in the summary so the user knows they're not starting from scratch.

If any step fails (MCP unreachable, auth error, timeout), report the exact error. Don't throw — let the user see the failure mode. The CLAUDE.md/MEMORY.md scaffolding stays in place; the mem0 side is the only part that failed.

## Step 8 — Print a summary

End with a concise, scannable report:

```
memory:init — <SLUG>

  Project root:        <PROJECT_ROOT>
  Slug:                <SLUG>           (mem0 app_id)
  Mem0 user_id:        <MEM0_USER_ID>
  Local memory dir:    <MEMORY_DIR>

  Files:
    <status> <PROJECT_ROOT>/CLAUDE.md
    <status> <MEMORY_DIR>/MEMORY.md

  Global ~/.claude/CLAUDE.md: <GLOBAL_STATUS>

  Mem0 round-trip:     <ok | failed: <reason>>
  Existing memories:   <N> found for this project  (optional)
```

Where `<status>` is one of `created`, `updated`, `already configured`, `left alone`.

After the report, if `GLOBAL_STATUS` was `missing` or `present-unconfigured`, remind the user one more time that without global instructions the dual-write pattern won't be followed automatically in future sessions.

## Edge cases

- **Not a git repo** — confirmed with the user in Step 1; proceed with cwd basename.
- **`$1` override provided** — skip the slug confirmation prompt and trust the user.
- **Repo name contains nothing alphanumeric** (e.g., `___`) — abort with a message asking for an explicit slug.
- **mem0 MCP not configured** — detect via the MCP call failing. Report clearly that the plugin needs the `mem0-mcp` server installed, and link the user to the plugin README.
- **User has `$CLAUDE_MEM0_USER_ID` set to something non-standard** — use it as-is. Don't second-guess.
- **Running inside a worktree** — `git rev-parse --show-toplevel` returns the worktree root, not the main repo. Treat worktrees as their own project (distinct `PROJECT_ROOT`, distinct `MEMORY_DIR`, same `SLUG` since the worktree is a copy of the same repo). This means worktrees share mem0 memories but have separate local memory directories. Mention this in the summary if a worktree is detected.

## Philosophy

This command is deliberately "explicit bootstrap" rather than "automatic every cd". Lazy creation is fine for some workflows, but for the dual-write memory pattern there's real value in running an explicit command per repo:

1. You **confirm the slug** once, up front. No wondering later what Claude chose.
2. You **verify mem0 works** at setup time, not at first-save time (when failure would be silent or surprising).
3. The scaffolding exists immediately, so the first memory save is a fast path.
4. It's self-documenting — the files it creates explain the pattern to future-you.

Don't try to make this implicit. The trade-off is intentional.
