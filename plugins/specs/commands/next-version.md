---
description: Create next versioned feature spec (v{N+1}) when starting a new dev cycle
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash, Glob, Grep
model: opus
type: plugin
---

# Specs Next Version Skill

Creates the next versioned feature spec when current work is complete and a new development cycle begins. The previous version stays as historical record. New phases get appended to the existing build plan.

Supports two spec conventions (auto-detected):

```
# Flat convention                    # Directory convention (Ralph-Wiggum)
specs/                               specs/
  readme.md                            prompt.md        ← static, auto-discovers
  v1-move-in-playground.md  (history)  v0.1/spec.md     (history)
  v2-new-feature.md         (created)  v0.2/spec.md     (created)
  implementation.md                    implementation.md ← active spec ref updated
  prompt.md                 (updated)
```

## Instructions for Claude

### Step 1: Detect Current Version and Convention

**1a. Detect convention:**

Check for both layouts:
- **Directory convention**: Glob for `specs/v*/spec.md` — if found, set `convention = directory`
- **Flat convention**: Glob for `specs/v*-*.md` — if found, set `convention = flat`
- If both exist, prefer directory convention
- If neither found, stop:
  > No versioned specs found in specs/. Run `/specs:refine` first or use `setup.sh` to create the initial structure.

**1b. Find highest version:**

- **Directory**: List `specs/v*/` directories, sort by semver (`sort -V`), take the highest. Version format: `0.1`, `0.2`, `1.0`, etc.
- **Flat**: List `specs/v*-*.md` files, extract version numbers, find highest N.

Read the current spec to understand what was built. Also read the implementation plan (detect actual filename — `implementation.md`, `implementation-plan.md`, etc.) to understand current phases and status. Read `readme.md` or `README.md` for project context.

**1c. Check if current version is incomplete.** A spec is incomplete if it contains `<!-- TODO` comments, has empty sections (heading followed immediately by another heading or `---`), or has placeholder text like `{TODO}`. Grep for these patterns.

- **If incomplete:** Report which spec has unfilled sections. Set `mode = fill-existing`. Skip to Step 3.
- **If complete:** Report current version found. Set `mode = create-next`. Continue to Step 2.

---

### Step 2: Ask 3 Questions (create-next mode only)

**Skip this step entirely if `mode = fill-existing`.** The name, carry-forward, and build plan decisions are already settled — the spec file exists and just needs its TODOs filled in.

Use a single `AskUserQuestion` call:

**Question 1: New feature name**

Adapt based on convention:
- **Flat**: Question: "What should the v{N+1} feature spec be named? This becomes `v{N+1}-{name}.md`"
- **Directory**: Question: "What's the focus of v{next}? (The spec goes in `v{next}/spec.md`)" — where `{next}` is the next semver (e.g., `0.1` → `0.2`, `1.0` → `1.1`)

- Header: "v{next} name"
- Options:
  - Suggest a name if the user has given context about what's next
  - "Custom name" — user provides their own

**Question 2: What carries forward**
- Question: "What should carry forward from v{N} into v{N+1}?"
- Header: "Carry forward"
- multiSelect: true
- Options:
  - "Decisions table" — Copy resolved decisions from v{N}
  - "Unfinished items" — Carry over incomplete requirements or TODOs
  - "Architecture sections" — Carry over architecture that's still relevant
  - "Clean slate" — Start fresh, just reference v{N} for history

**Question 3: Implementation plan handling**
- Question: "How should the build plan be updated?"
- Header: "Build plan"
- Options:
  - "Append new phases (Recommended)" — Add v{N+1} phases after existing ones, keeping the history of what was built
  - "Add divider + new phases" — Insert a clear version header divider, then new phase skeleton
  - "Manual" — Don't touch build plan, user will update it themselves

---

### Step 3: Scope Interview

Before writing anything, interview the user to understand what the version should deliver. This is the most important step — the spec should be filled in from this conversation, not left as TODOs.

**3a. Ask the user what they want:**

Use `AskUserQuestion` with a single free-form question. Adapt the wording based on mode:

**If `mode = create-next`:**
- Question: "What should v{N+1} deliver? Describe what you want in free form — new features, improvements, problems to solve, anything. I'll refine it into a proper spec."
- Header: "v{N+1} scope"
- Options:
  - "Let me describe it" — user provides free-form description
  - "Not sure yet — just scaffold" — create with TODOs, skip the interview

**If `mode = fill-existing`:**
- Question: "v{N}-{name}.md has unfilled TODO sections. What should this version deliver? Describe the scope and I'll fill in the spec."
- Header: "v{N} scope"
- Options:
  - "Let me describe it" — user provides free-form description
  - "Leave TODOs for now" — keep the spec as-is, abort

If user picks "Not sure yet — just scaffold" or "Leave TODOs for now", skip to Step 4 (create-next mode creates with TODOs; fill-existing mode aborts with no changes).

**3b. Refine through follow-up questions:**

After the user provides their free-form description, analyze it against the existing codebase and v{N} spec. Ask 1-2 clarifying follow-up questions ONLY if genuinely ambiguous. Don't over-interview — if the user's description is clear enough to write a spec, go straight to writing.

Good follow-ups (when needed):
- "You mentioned X — does that mean Y or Z?" (disambiguate)
- "Should X replace the existing Y, or work alongside it?" (architectural choice)

Bad follow-ups (skip these):
- Asking the user to repeat what they already said
- Asking about implementation details that can be decided in the spec
- Asking more than 2 rounds of questions

**3c. Synthesize into spec sections:**

From the interview, derive:
- 1-2 sentence summary (for the H1 subtitle)
- Overview paragraph (problem + desired outcome)
- Numbered requirement sections (grouped by concept, matching v{N} pattern)
- Any interface definitions, screen registries, or data models mentioned
- Decisions table entries (for choices made during the interview)

---

### Step 4: Execute

**Branch based on mode:**

---

#### Fill-existing mode (`mode = fill-existing`)

Edit the current spec in place. Do NOT create a new file.
- **Flat**: Edit `v{N}-{name}.md`
- **Directory**: Edit `v{N}/spec.md`

**4-fill-a. Fill in TODO sections from the interview:**

- Replace `<!-- TODO -->` placeholders with content derived from the scope interview (Step 3c)
- Fill in empty Overview, requirement sections, and decisions table
- Preserve the existing document structure — don't reorder sections or change headings unless the interview revealed a better grouping

**4-fill-b. Update implementation plan TODO phases:**

Read the implementation plan. Find any phases that reference v{N} and still have `{TODO}` placeholders or empty sub-steps. Fill them in with concrete steps derived from the interview. Leave already-completed phases untouched.

**4-fill-c. Skip all cross-ref/readme/prompt updates.**

These were already created when v{N} was scaffolded. Jump to Step 5.

---

#### Create-next mode (`mode = create-next`)

#### 4a. Detect implementation plan filename

Find the actual filename. Use whatever exists. Do NOT rename.

#### 4b. Create new spec file

- **Flat**: Create `v{N+1}-{new-feature}.md`
- **Directory**: Create `v{next}/spec.md` (e.g., `mkdir -p specs/v0.2 && write specs/v0.2/spec.md`)

Follow the same structure as the existing v{N} doc. Match the reference project v1 pattern.

**If the scope interview happened (Step 3)**, fill in all sections from the interview — no TODOs except for genuinely unknown details. The spec should read as a complete feature description.

**If the user chose "just scaffold"**, use TODO placeholders.

Template:

```markdown
# v{N+1}: {New Feature Title}

{1-2 sentence summary of what this version delivers.}

**Ref:** [specs/readme.md](./readme.md) — project spec
**Ref:** [specs/{implementation-file}](./{implementation-file}) — build plan
**Ref:** [specs/v{N}-{old-name}.md](./v{N}-{old-name}.md) — previous version

---

## Changes from v{N}

v{N} delivered:
- {Bullet summary of what v{N} accomplished, derived from reading the v{N} doc and implementation plan checkpoints}

v{N+1} focuses on:
- {Filled in from interview, or TODO if scaffolding}

---

## Overview

{Filled in from interview — problem statement and desired outcome. Or TODO if scaffolding.}

---

## 1. {First Requirement Area}

{Numbered sections derived from the interview. Include interface definitions, tables, etc. as needed.}

---

## N. Decisions (resolved)

| Question | Decision |
|----------|----------|
| {Decisions made during the interview} | {What was decided} |
```

**Carry-forward handling:**
- "Decisions table" → Copy the decisions table from v{N} into v{N+1}
- "Unfinished items" → Grep v{N} doc for TODO, incomplete, or unresolved items. Add under a `## Carried Forward` section before the numbered requirements
- "Architecture sections" → Copy architecture diagrams, layout descriptions, and interface definitions that are still relevant
- "Clean slate" → Just the template, no content copied from v{N}

#### 4c. Leave `v{N}-{old-name}.md` untouched

Do NOT modify the previous version. It's historical record.

#### 4d. Mark completed phases in the implementation plan

Before appending new phases, mark all existing v{N} phases as complete:
- Add ✅ to each phase heading: `## Phase N: Title` → `## Phase N: Title ✅`
- Check all validation checkboxes: `- [ ]` → `- [x]`

This preserves the build history and makes it clear where v{N} ended and v{N+1} begins.

#### 4e. Update implementation plan — append new phases

Read the current build plan. Find the last phase number.

**If "Append new phases":**

Append after the last phase:

```markdown

---

## Phase {last+1}: {TODO — v{N+1} scope}

**Ref:** [v{N+1}-{name}.md](./v{N+1}-{name}.md) — feature spec

### {last+1}a. {TODO}

- {TODO: Define sub-steps with file paths}

### {last+1}b. {TODO}

- {TODO: Define sub-steps}

### Validation — After Phase {last+1}

- [ ] {TODO: Define validation checkpoints}
```

**If "Add divider + new phases":**

Append with a version header:

```markdown

---

# v{N+1} — {New Feature Title}

**Ref:** [specs/v{N+1}-{name}.md](./v{N+1}-{name}.md) — feature spec

## Phase {last+1}: {TODO}

### {last+1}a. {TODO}

- {TODO: Define sub-steps}

### Validation — After Phase {last+1}

- [ ] {TODO: Define validation checkpoints}
```

Update the `**Ref:**` lines at the top of the implementation plan to include v{N+1}:

```markdown
**Ref:** [specs/v{N+1}-{name}.md](./v{N+1}-{name}.md) — feature spec (current)
**Ref:** [specs/v{N}-{old-name}.md](./v{N}-{old-name}.md) — feature spec (previous)
**Ref:** [specs/readme.md](./readme.md) — project spec
```

**If "Manual":** Only update the `**Ref:**` lines. Don't touch the body.

#### 4f. Update `readme.md`

Update the spec files listing to include the new v{N+1} doc. Add it to any tools/features reference section if applicable. If the readme has a version reference, update it.

#### 4g. Update `prompt.md`

**Flat convention:** Update file references to point to v{N+1} as the active feature spec:

```markdown
Read specs/readme.md and specs/v{N+1}-{name}.md to understand the project and current feature scope.
Read specs/{implementation-file} for the build plan.
```

**Directory convention:** `prompt.md` is static and auto-discovers the latest `v*/` directory — **do NOT modify it**. Instead, update the `> Active spec:` line in `implementation.md`:

```markdown
> Active spec: v{next}/spec.md
```

---

### Step 5: Report

Show the user:

**If `mode = fill-existing`:**

1. Final `specs/` file listing (use `ls -la specs/`)
2. Summary: "Filled in v{N}-{name}.md — TODO sections replaced with scope from interview."
3. List which sections were filled in
4. If implementation plan phases were also updated, note that

**If `mode = create-next`:**

1. Final `specs/` file listing (use `ls -la specs/`)
2. Summary: "Created v{N+1}-{name}.md. v{N}-{old-name}.md preserved as history."
3. What was carried forward (if anything)
4. How the build plan was updated (new phases appended / divider added / manual)
5. If the scope interview happened: summarize what was captured in the spec
6. If scaffolding only: remind user to fill in the TODO sections and define new phases