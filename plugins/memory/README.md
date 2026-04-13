# memory

Bootstraps and manages the **dual-write memory pattern**: every Claude Code auto-memory you save locally is mirrored to [mem0](https://mem0.ai) with a project-scoped `app_id`, so each repo gets two complementary stores.

- **Local markdown files** (`~/.claude/projects/<sanitized-cwd>/memory/`) — rich, structured, versioned with your dotfiles.
- **mem0** — semantic search, cross-session retrieval, cross-project lookups.

You decide *whether* something is worth saving once, then it lands in both stores.

## Installation

```
/plugin install memory@claude-code-workflows
```

## Commands

| Command | Description |
|---------|-------------|
| `/memory:init [slug]` | Bootstrap the dual-write pattern in the current repo — derives a project slug, writes `CLAUDE.md` + `MEMORY.md` scaffolding, and verifies mem0 wiring with a live round-trip test. Idempotent. |
| `/memory:save <text>` | Evaluate and persist a memory. Claude analyzes the input, decides if it's worth saving (vs. derivable, ephemeral, or fixable), classifies the type, checks for duplicates, and dual-writes to local markdown + mem0. |

## Prerequisites

- **mem0 MCP server** — installed and enabled. The plugin calls `mcp__mem0-mcp__add_memory`, `search_memories`, `delete_memory`.
- **Global memory instructions** — a `~/.claude/CLAUDE.md` describing the dual-write rule. `/memory:init` will warn if it's missing and offer a starter template. See the [dual-write pattern template](#dual-write-pattern-template) below.
- **Git** — the command uses `git rev-parse --show-toplevel` to detect the repo root, with a cwd fallback for non-git directories.

## How the scoping works

| Axis | Value | Meaning |
|------|-------|---------|
| `user_id` | `$CLAUDE_MEM0_USER_ID` (falls back to `$(whoami)`) | The person |
| `app_id` | the project slug, e.g. `marps` | Which codebase this came from |
| `metadata.type` | `user` \| `feedback` \| `project` \| `reference` | The auto-memory category |

Retrieval filter for the current project:

```json
{"AND": [{"user_id": "<you>"}, {"app_id": "<slug>"}]}
```

The slug is derived as `basename $(git rev-parse --show-toplevel)`, lowercased, with non-alphanumeric characters collapsed to `-`. Pass an explicit slug to override: `/memory:init my-slug`.

## Dual-write pattern template

`/memory:init` doesn't modify your global `~/.claude/CLAUDE.md`, but if it's missing you'll want instructions there so that Claude follows the dual-write rule in every session. A minimal version looks like:

```markdown
## Memory system — dual-write to local files + mem0

When you save an auto-memory to the local file system under
`~/.claude/projects/<sanitized-cwd>/memory/`, also mirror it to mem0 via
`mcp__mem0-mcp__add_memory` with:

- `text`: a concise summary (not the full markdown body)
- `user_id`: the unix user (or $CLAUDE_MEM0_USER_ID if set)
- `app_id`: the project slug (see the repo's CLAUDE.md)
- `metadata`: { "type": "<user|feedback|project|reference>", "file": "<filename>.md", "source": "auto-memory-mirror" }

Don't mirror MEMORY.md index edits or trivial typo fixes. Use
`update_memory` when editing existing content if you can find its memory_id.

Every project gets a MEMORY.md index in its local memory directory and
a CLAUDE.md at the repo root pinning the slug — run `/memory:init` to
bootstrap a new repo.
```

## What `/memory:init` creates

Running `/memory:init` in a clean repo produces:

```
<repo>/
└── CLAUDE.md                                    # slug pinned, one-line description
~/.claude/projects/<sanitized-cwd>/memory/
├── MEMORY.md                                    # empty index, ready to grow
```

And verifies mem0 round-trip by writing a throwaway memory with `app_id: <slug>` and deleting it.

## Idempotency

Running `/memory:init` on an already-bootstrapped repo is safe:

- Existing `CLAUDE.md` with a memory section → left alone
- Existing `CLAUDE.md` without a memory section → offers to append
- Existing `MEMORY.md` → left alone
- Existing local memory dir → left alone

The mem0 round-trip test always runs so you can verify wiring even on a re-run.
