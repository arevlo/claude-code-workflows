---
description: Restructure existing specs/ to match canonical 4-file pattern (project spec, feature spec, build plan, prompt)
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash, Glob, Grep
model: opus
type: plugin
---

# Specs Refine Skill

Restructures an existing `specs/` directory to match the canonical spec pattern used by reference project:

```
specs/
  readme.md                — Project spec (stable base — architecture, tools, rules, layout)
  v1-feature-name.md       — Feature spec (WHAT we're building this version)
  implementation-plan.md   — Build plan (HOW — phases with sub-steps, validation checkpoints)
  prompt.md                — Ralph iteration prompt
```

The key separation: **WHAT** (requirements, architecture, data models, screen registries, interfaces, domain concepts) goes into the versioned feature spec. **HOW** (phases, sub-steps, file lists, verification checkboxes) stays in the build plan.

## Reference: reference project gold standard

Study these actual files for structure and tone:

**readme.md** (project spec): Project name + 1-line description, version/transport info, ASCII architecture diagram, tool reference tables grouped by category, critical rules, environment variables, types, full project layout tree.

**v1-design-system-assistant.md** (feature spec): Title `# v1: Feature Name`, cross-refs using `**Ref:**` format, overview paragraph, numbered sections (1. New Tools, 2. Slot System, etc.) with interface definitions in code blocks, decisions table at the end.

**implementation-plan.md** (build plan): Title + `**Ref:**` cross-refs, phases with lettered sub-steps (1a, 1b, 1c...), each pointing to exact files with code patterns, validation checkpoints after each phase with checkbox status.

## Instructions for Claude

### Step 1: Inventory

Glob `specs/` and read all `.md` files. Also read `CLAUDE.md` from the project root for architecture context. Detect what exists:

```
- v{N}-*.md file?        → already has feature spec
- readme.md?             → exists but may be thin file index vs full project spec
- implementation*.md?    → the build plan (accept any name variant)
- prompt.md?             → Ralph iteration prompt
```

Report findings to user before continuing.

**Edge case**: If no `specs/` directory exists, stop and tell the user to run `/specs:setup` first.

**Edge case**: If a `v{N}-*.md` file already exists:
- Check if it's incomplete (contains `<!-- TODO` comments, empty sections, or `{TODO}` placeholders).
- **If incomplete:** Report: "Found v{N}-{name}.md but it has unfilled TODO sections." Use `AskUserQuestion` to offer:
  - "Fill in v{N} now" — run a scope interview (same flow as next-version Step 3: ask what the version should deliver, refine through 1-2 follow-ups, then edit the existing file in place to replace TODOs with real content. Also fill in any TODO phases in the implementation plan.)
  - "Skip — just fix cross-refs" — proceed with the original behavior (fix cross-refs and readme only)
- **If complete:** Skip v1 creation. Only fix cross-refs and readme if needed.

---

### Step 2: Ask 3 Questions

Use a single `AskUserQuestion` call:

**Question 1: Feature name for v1 doc**
- Question: "What should the v1 feature spec be named? This becomes `v1-{name}.md` in specs/"
- Header: "v1 name"
- Options:
  - Suggest a name derived from the implementation plan title (e.g., "move-in-playground" if the plan is about the move-in playground)
  - "Custom name" — user provides their own

**Question 2: Readme depth**
- Question: "How should readme.md be handled?"
- Header: "Readme"
- Options:
  - "Rewrite as project spec (Recommended)" — Full project overview matching reference project pattern: architecture diagram, feature/tool reference, critical rules, project layout
  - "Keep as-is" — Leave current content, just add cross-ref links

**Question 3: v1 content source**
- Question: "Where should the v1 feature spec content come from?"
- Header: "v1 content"
- Options:
  - "Extract from build plan (Recommended)" — Move WHAT sections (architecture, data models, screen registry, interfaces) into v1, leave HOW sections (phases, steps, verification) in the build plan
  - "Skeleton only" — Create v1 with numbered section headings and TODOs, leave build plan untouched

---

### Step 3: Execute

#### 3a. Detect implementation plan filename

Find the actual filename — could be `implementation.md`, `implementation-plan.md`, or another variant. Use whatever exists. Do NOT rename.

#### 3b. Create `v1-{feature-name}.md` (feature spec)

Follow the reference project v1 doc structure exactly:

```markdown
# v1: {Feature Title}

{1-2 sentence summary of what this version delivers.}

**Ref:** [specs/readme.md](./readme.md) — project spec
**Ref:** [specs/{implementation-file}](./{implementation-file}) — build plan

---

## Overview

{1-2 paragraph description of the feature, extracted from implementation plan Context section. Include the problem statement and desired outcome.}

### Core loop (or Core workflow)

{If applicable, a short flow diagram or bullet list showing the main user/system flow}

---

## 1. {First Major Feature Area}

{Numbered sections for each major feature/requirement area. Extract from implementation plan.}

{Include interface definitions in code blocks:}

```typescript
interface ExampleType {
  field: string
  nested: { ... }
}
```

{Include tables where relevant for screen registries, data models, status mappings, etc.}

---

## 2. {Second Major Feature Area}

{Continue with numbered sections...}

---

## N. Decisions (resolved)

| Question | Decision |
|----------|----------|
| {Key architectural decisions discovered in the spec} | {What was decided} |
```

**Content extraction heuristic — what goes in v1:**
- Context / overview / problem statement
- Architecture diagrams and layout descriptions
- Data models with interface/type definitions
- Screen registries and metadata
- Annotations and domain concepts
- Status mappings and state machines
- File structure trees (for new feature directories)
- Any section describing WHAT the system does or looks like

**What stays in the build plan:**
- Phase N / Step N headers
- Lettered sub-steps (1a, 1b, 1c...)
- Verification checkboxes
- Files to create/modify lists
- Implementation phases with ordering
- Rollback plans
- Test specifications

When extracting from the build plan:
- **Copy** the WHAT content to v1
- After v1 is written, **replace** the extracted sections in the build plan with a cross-reference: `**Ref:** [v1-{name}.md](./v1-{name}.md) — {section topic}`

If "Skeleton only" was chosen, create the same numbered section structure but with `<!-- TODO -->` placeholders. Leave build plan untouched.

#### 3c. Rewrite `readme.md` (if chosen) — project spec

Follow the reference project readme structure. Pull content from CLAUDE.md and the spec files:

```markdown
# {Project Name}

{1-2 sentence project description.}

**Version:** {if applicable}
**Runtime/Transport:** {if applicable — e.g., "WebSocket (ws://localhost:3055)", "Vite dev server (port 3100)", "iOS 17+"}

---

## Architecture

```
{ASCII diagram of system architecture — pull from CLAUDE.md or implementation plan}
```

{Brief explanation of architecture components}

---

## {Feature/Tool Reference}

{Tables grouped by category — matching the project's domain. For a web app this might be "Screens" or "Features". For an MCP server this is "Tools". For a library this is "API".}

### {Category 1}

| {Item} | Description |
|--------|-------------|
| ... | ... |

### {Category 2}

| {Item} | Description |
|--------|-------------|
| ... | ... |

### v1 {scope}

All v1 {items} are defined in [v1-{name}.md](./v1-{name}.md).

---

## Critical Rules

{Key rules and constraints from CLAUDE.md — design tokens, naming conventions, patterns that must be followed}

---

## Environment

| Variable | Required | Description |
|----------|----------|-------------|
| {Environment variables, API keys, config — pull from CLAUDE.md or project config} | | |

{Omit this section if the project has no environment variables.}

---

## Types

{Key type definitions used across the project — interfaces, enums, shared data structures. Include code blocks with type/interface definitions. Omit this section if not applicable.}

---

## Project Layout

```
{Directory tree from CLAUDE.md or by scanning the actual project}
```
```

If "Keep as-is" was chosen, just ensure the file listing includes the new v1 doc.

#### 3d. Add cross-reference links to build plan

Add `**Ref:**` lines after the H1 title of the implementation plan:

```markdown
**Ref:** [specs/v1-{name}.md](./v1-{name}.md) — feature spec
**Ref:** [specs/readme.md](./readme.md) — project spec
```

#### 3e. Update `prompt.md` file references

If prompt.md exists, update file references to include the v1 doc. Add at the top:

```markdown
Read specs/readme.md and specs/v1-{name}.md to understand the project and current feature scope.
Read specs/{implementation-file} for the build plan.
```

If prompt.md doesn't exist, create a minimal one:

```markdown
Read specs/readme.md and specs/v1-{name}.md to understand the project and current feature scope.
Read specs/{implementation-file} for the build plan.

Check git history for recent work:
git log --oneline -20

Find the NEXT most impactful improvement. Check in this order:
1. Incomplete tasks in the implementation plan
2. Code quality — duplication, error handling, edge cases, type safety
3. Test coverage gaps

Do ONE focused improvement. Not everything — just the single most impactful thing.

If you made a meaningful change, commit:
git add -A && git commit -m "iteration: [concise description]"
```

---

### Step 4: Report

Show the user:

1. Final `specs/` file listing (use `ls -la specs/`)
2. Summary of what was created/modified
3. If content was extracted, show which sections moved from build plan → v1 doc
4. Remind user to review the v1 feature spec and fill in any Decisions table entries
