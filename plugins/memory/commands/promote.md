---
description: After a memory is saved, scan other projects for the same concept and — if it recurs across projects but isn't yet in global ~/.claude/CLAUDE.md — propose a one-line global entry. Use when the dual-write rule says "promote", when the user says "promote that memory", "check if this should be global", "audit cross-project memories", or runs /memory:promote. Idempotent and safe to re-run.
argument-hint: "<memory-file-path>"
allowed-tools: Bash, Read, Edit, Grep
---

# Promote a memory to global CLAUDE.md

Project-scoped memory is great for project-specific facts (DB schemas, conventions, in-flight work), but it traps cross-project knowledge — tool installs, behavioral rules — inside whichever cwd they were first saved under. Future sessions in other projects can't see them.

This command is the consolidation step. After a memory write, it asks: **"Does this concept already echo in other projects? If yes and global CLAUDE.md is silent, should we promote it?"**

Anti-bloat is a first-class concern. The skill always asks before editing global CLAUDE.md, caps each section at ~10 entries, writes one bullet per concept, and links to the source memory rather than inlining the body.

## Arguments

- `$1` (required) — path to the memory file just written. Absolute path or relative to cwd. Must exist and have valid frontmatter (`name`, `description`, `type`).

## When NOT to promote

Skip promotion (exit silently with a one-line report) when any of these are true:

- `type: user` — facts about the person rarely belong in global CLAUDE.md (it's instructions for Claude, not a profile of the user). Exception: working-style rules that translate to "do/don't" guidance.
- `type: project` — project context is by definition project-scoped. Don't promote unless the same project context appears in 2+ projects (rare).
- The memory file doesn't exist or has malformed frontmatter — report the error and stop.
- Global `~/.claude/CLAUDE.md` already mentions the concept — case-insensitive substring match on the memory's `name` or filename slug.
- No other project has a memory referencing the same concept.

## Step 1 — Resolve context

```bash
set -euo pipefail

MEMORY_FILE="${1:?usage: /memory:promote <memory-file-path>}"
[ -f "$MEMORY_FILE" ] || { echo "Not found: $MEMORY_FILE"; exit 1; }
MEMORY_FILE=$(cd "$(dirname "$MEMORY_FILE")" && pwd)/$(basename "$MEMORY_FILE")

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SANITIZED=$(echo "$PROJECT_ROOT" | sed 's|/|-|g')
CURRENT_MEMORY_DIR="$HOME/.claude/projects/${SANITIZED}/memory"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo "MEMORY_FILE=$MEMORY_FILE"
echo "CURRENT_MEMORY_DIR=$CURRENT_MEMORY_DIR"
```

## Step 2 — Parse the memory's frontmatter

Read `$MEMORY_FILE` and extract:

- `name` (string, single line)
- `description` (string, single line)
- `type` (one of `user`, `feedback`, `project`, `reference`)

If any field is missing or `type` is invalid, print `Skipped: malformed frontmatter (<reason>)` and stop. Don't repair — that's the responsibility of `/memory:save`.

## Step 3 — Decide whether this type is promotable at all

| Type | Promote? | Notes |
|------|----------|-------|
| `reference` | yes — most common case (tools, external resources) | These are typically the things future sessions miss. |
| `feedback` | yes if behavioral and not project-specific | E.g., "always use voice input" applies everywhere; "prefer Postgres for this repo" doesn't. |
| `user` | rarely — only if it's a working-style rule that translates to Claude behavior | E.g., "user prefers terse output" → promote. "user is a Go developer" → don't. |
| `project` | rarely — only if explicitly cross-project | Default skip. Exit with `Skipped: project-type memories stay project-scoped`. |

If type is non-promotable for this content, exit with a one-line `Skipped: <reason>`.

## Step 4 — Build search keys

Derive keys from the memory:

- The filename stem (without `.md` and without the `<type>_` prefix) — e.g., `feedback_browser_access.md` → `browser_access`
- The `name` field, lowercased
- Any obvious noun phrase from the body — extract the first bolded term or backticked identifier as a third key

Three keys is enough — naive but works for tool names and rule names. Don't over-engineer NLP for v1.

## Step 5 — Cross-project search

```bash
# Search all project memory dirs except the current one
KEYS=("$KEY1" "$KEY2" "$KEY3")  # from Step 4
HIT_PROJECTS=()

for KEY in "${KEYS[@]}"; do
  while IFS= read -r match; do
    HIT_PROJECTS+=("$match")
  done < <(
    grep -ril -- "$KEY" "$HOME/.claude/projects/"*/memory/ 2>/dev/null \
      | grep -v "^${CURRENT_MEMORY_DIR}/" \
      | xargs -n1 dirname 2>/dev/null \
      | sort -u
  )
done

# Deduplicate hit project dirs
HIT_PROJECTS=($(printf '%s\n' "${HIT_PROJECTS[@]}" | sort -u))
echo "Cross-project hits: ${#HIT_PROJECTS[@]}"
printf '  %s\n' "${HIT_PROJECTS[@]}"
```

If `${#HIT_PROJECTS[@]}` is 0, exit with `Skipped: no cross-project echo for <name>`. The memory may still be valuable, but there's no signal yet that it's cross-project.

If 1+ hits, continue.

## Step 6 — Check global CLAUDE.md for existing coverage

```bash
if [ ! -f "$GLOBAL_CLAUDE_MD" ]; then
  echo "Skipped: ~/.claude/CLAUDE.md does not exist — run /memory:init first or create it manually"
  exit 0
fi

for KEY in "${KEYS[@]}"; do
  if grep -qi -- "$KEY" "$GLOBAL_CLAUDE_MD"; then
    echo "Skipped: '$KEY' already mentioned in ~/.claude/CLAUDE.md"
    exit 0
  fi
done
```

## Step 7 — Decide the destination section

Map `type` → section heading in global CLAUDE.md:

| Type | Section heading |
|------|-----------------|
| `reference` (tool / CLI / repo) | `## Locally installed tools (apply to all projects)` |
| `reference` (external service / dashboard / channel) | `## External references (apply to all projects)` (lazily created) |
| `feedback` | `## Cross-project conventions` (lazily created) |
| `user` (rare, only working-style) | `## Cross-project conventions` |

Check whether the target section exists in the file. If not, the entry creation step also creates the section (with a one-line preamble describing the format rule).

## Step 8 — Draft the entry

Compose a one-line bullet:

```markdown
- **<short bold term>** (<install path or location>) — <one-sentence purpose>. Reference: <path-to-source-memory>.
```

Constraints:

- One bullet per concept
- ≤2 lines wrapped
- Bold the most identifying term first (tool name, rule name)
- Always end with `Reference: <path>` pointing to the source memory file in `~/.claude/projects/...`

If the section already exists and has ≥10 entries, **do not auto-append**. Show the user the section as-is, point out the cap, and ask whether to consolidate an existing entry, demote one, or override the cap. Don't silently bloat.

## Step 9 — Show the user the proposed change and ask

Print, with no edits made yet:

```
Promote candidate: <name> (type: <type>)

Source memory:    <MEMORY_FILE>
Cross-project hits in:
  <hit project 1>
  <hit project 2>
  ...

Proposed addition to ~/.claude/CLAUDE.md → ## <section heading>:

  - **<term>** (<location>) — <purpose>. Reference: <path>.

Section status: <new | exists, N/10 entries used>

Promote? (y / n / e to edit the entry first)
```

Wait for the user to respond. On `y`, apply. On `e`, accept their rewritten line and apply. On `n` or anything else, print `Skipped: declined by user` and stop.

## Step 10 — Apply

Use `Edit` (not Bash sed) to insert the bullet:

- **Existing section**: insert the new bullet as the last bullet under the section, before the next `## ` heading or EOF. Preserve the format-rule footer line if one exists.
- **New section**: append the section after the most-related existing section (e.g., new "Cross-project conventions" goes after "Locally installed tools" if it exists, otherwise after "Building skills, commands, and agents"). Include a one-line preamble describing the format rule.

## Step 11 — Report

Print a concise final report:

```
Promoted: <name>
  → ~/.claude/CLAUDE.md ## <section heading>
  Entry: - **<term>** (<location>) — <purpose>. Reference: <path>.
  Section now: <N/10 entries>
```

Or, on any skip:

```
Skipped: <one-line reason>
```

## Edge cases

- **Memory file path is inside `vault/` or some non-standard location** — accept it; the path doesn't have to be inside `~/.claude/projects/`. The cross-project search still scans the standard location.
- **Frontmatter present but `name` contains a colon, slash, or other markdown-breaking char** — escape with backticks in the proposed entry.
- **Multiple memories on the same concept across projects, with conflicting framings** — show all hits in step 9 so the user can choose which framing to canonicalize. Don't merge automatically.
- **User runs the command twice on the same file** — step 6 catches the second run as already-promoted; idempotent.
- **Cap exceeded (≥10 entries in target section)** — never silently append. Always ask the user how to handle the cap (consolidate, demote, override).
- **Section heading is misspelled in CLAUDE.md vs the routing table** — fall through to "section does not exist" and create a new (correctly-spelled) one. Tell the user there appears to be a near-duplicate section so they can fix it manually.

## Philosophy

The memory system has two failure modes: too little (concepts get re-discovered every session) and too much (CLAUDE.md becomes a wall of stale notes nobody reads). This command attacks the first failure mode while explicitly defending against the second.

It's deliberately conservative: it only promotes things that have already proven cross-project relevance (echo in 2+ projects), it always asks, it caps section size, and it never inlines memory bodies. The goal is for global CLAUDE.md to stay scannable on a phone screen forever.

If a category outgrows the cap, that's a signal the global file should split — e.g., spin out a `~/.claude/memory-index/` of detail files referenced by short pointers in CLAUDE.md. Don't try to compress your way past the cap.
