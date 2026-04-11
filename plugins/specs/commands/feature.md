---
description: Create or iterate on a feature spec in the current project's specs/ directory
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash, Glob, Grep
model: opus
type: plugin
---

# Specs Feature Skill

Creates a new feature spec or iterates on an existing one. Multiple feature specs coexist in `specs/` — there is no version numbering. New phases get appended to the existing build plan.

```
specs/
  readme.md
  move-in-playground.md    ← feature spec (coexists)
  ios-screen-capture.md    ← feature spec (coexists)
  implementation-plan.md   ← phases appended per feature
  prompt.md                ← refs updated
```

## Instructions for Claude

### Step 1: Inventory Existing Specs

Glob for `specs/*.md` files. Exclude infrastructure files (`readme.md`, `implementation-plan.md`, `implementation.md`, `prompt.md`). The remaining `.md` files are feature specs.

Read each feature spec to understand what's already been built. Also read the implementation plan (detect actual filename — `implementation.md`, `implementation-plan.md`, etc.) to understand current phases and status. Read `readme.md` for project context.

If no `specs/` directory exists, stop and tell the user:
> No specs/ directory found. Run `/specs:setup` first to create the spec structure.

---

### Step 2: Ask — Create New or Iterate

Use `AskUserQuestion`:

**Question: "What do you want to do?"**
- Header: "Action"
- Options:
  - "Create new feature spec" — Start a new `{feature-name}.md`
  - "Iterate on existing spec" — Fill in TODOs or refine an existing feature spec

If "Iterate on existing" is chosen and there are multiple feature specs, ask which one. If only one exists, select it automatically.

**Check if the selected spec is incomplete.** A spec is incomplete if it contains `<!-- TODO` comments, has empty sections (heading followed immediately by another heading or `---`), or has placeholder text like `{TODO}`. Grep for these patterns.

- **If incomplete:** Report: "Found {name}.md with unfilled sections. Will fill these in." Set `mode = fill-existing`.
- **If complete:** Report: "Found {name}.md — it's already filled in. Will refine based on your input." Set `mode = refine-existing`.

If "Create new feature spec" is chosen, set `mode = create-new`. Continue to Step 3.

---

### Step 3: Scope Interview

Before writing anything, interview the user to understand what the feature should deliver.

**3a. Ask the user what they want:**

Use `AskUserQuestion` with a single free-form question. Adapt wording based on mode:

**If `mode = create-new`:**
- Question: "What should this feature deliver? Describe what you want in free form — new features, improvements, problems to solve, anything. I'll refine it into a proper spec."
- Header: "Feature scope"
- Options:
  - "Let me describe it" — user provides free-form description
  - "Not sure yet — just scaffold" — create with TODOs, skip the interview

**If `mode = fill-existing`:**
- Question: "{name}.md has unfilled TODO sections. What should this feature deliver? Describe the scope and I'll fill in the spec."
- Header: "Feature scope"
- Options:
  - "Let me describe it" — user provides free-form description
  - "Leave TODOs for now" — keep the spec as-is, abort

**If `mode = refine-existing`:**
- Question: "What changes or additions should be made to {name}.md?"
- Header: "Refinement"
- Options:
  - "Let me describe it" — user provides free-form description
  - "No changes needed" — abort

If user picks a skip/abort option, handle accordingly (scaffold with TODOs for create-new, abort for others).

**3b. Refine through follow-up questions:**

After the user provides their free-form description, analyze it against the existing codebase and specs. Ask 1-2 clarifying follow-up questions ONLY if genuinely ambiguous. Don't over-interview.

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
- Numbered requirement sections (grouped by concept)
- Any interface definitions, screen registries, or data models mentioned
- Decisions table entries (for choices made during the interview)

---

### Step 4: Execute

**Branch based on mode:**

---

#### Fill-existing / Refine-existing mode

Edit the existing `{name}.md` in place. Do NOT create a new file.

**4-edit-a. Fill in TODO sections or apply refinements from the interview:**

- Replace `<!-- TODO -->` placeholders with content derived from the scope interview (Step 3c)
- Fill in empty Overview, requirement sections, and decisions table
- Preserve the existing document structure — don't reorder sections or change headings unless the interview revealed a better grouping

**4-edit-b. Update implementation plan TODO phases:**

Read the implementation plan. Find any phases that reference this feature and still have `{TODO}` placeholders or empty sub-steps. Fill them in with concrete steps derived from the interview. Leave already-completed phases untouched.

**4-edit-c. Skip cross-ref/readme/prompt updates if they already reference this spec.**

Jump to Step 5.

---

#### Create-new mode

#### 4a. Ask for the feature name

Use `AskUserQuestion`:
- Question: "What should the feature spec be named? This becomes `specs/{name}.md`"
- Header: "Filename"
- Options:
  - Suggest a name if the user has given context about the feature
  - "Custom name" — user provides their own

#### 4b. Detect implementation plan filename

Find the actual filename. Use whatever exists. Do NOT rename.

#### 4c. Create `{feature-name}.md` (feature spec)

Follow the same structure as existing feature spec files in the project. Match the pattern used by sibling specs.

**If the scope interview happened (Step 3)**, fill in all sections from the interview — no TODOs except for genuinely unknown details. The spec should read as a complete feature description.

**If the user chose "just scaffold"**, use TODO placeholders.

Template:

```markdown
# {Feature Title}

{1-2 sentence summary of what this feature delivers.}

**Ref:** [specs/readme.md](./readme.md) — project spec
**Ref:** [specs/{implementation-file}](./{implementation-file}) — build plan
**Ref:** [specs/{related-feature}.md](./{related-feature}.md) — related feature (if applicable)

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

#### 4d. Update implementation plan — append new phases

Read the current build plan. Find the last phase number.

Append after the last phase with a feature header:

```markdown

---

# {Feature Title}

**Ref:** [specs/{feature-name}.md](./{feature-name}.md) — feature spec

## Phase {last+1}: {Phase title}

### {last+1}a. {Sub-step}

- {Steps with file paths}

### Validation — After Phase {last+1}

- [ ] {Validation checkpoints}
```

Update the `**Ref:**` lines at the top of the implementation plan to include the new feature:

```markdown
**Ref:** [specs/{feature-name}.md](./{feature-name}.md) — feature spec
```

#### 4e. Update `readme.md`

Update the spec files listing to include the new feature doc.

#### 4f. Update `prompt.md`

Update file references to include the new feature spec:

```markdown
Read specs/readme.md and specs/{feature-name}.md to understand the project and current feature scope.
Read specs/{implementation-file} for the build plan.
```

---

### Step 5: Report

Show the user:

**If `mode = fill-existing` or `mode = refine-existing`:**

1. Final `specs/` file listing (use `ls -la specs/`)
2. Summary: "Updated {name}.md — TODO sections replaced with scope from interview." (or "Refined {name}.md with changes.")
3. List which sections were filled in or changed
4. If implementation plan phases were also updated, note that

**If `mode = create-new`:**

1. Final `specs/` file listing (use `ls -la specs/`)
2. Summary: "Created {feature-name}.md."
3. List of related specs referenced
4. How the build plan was updated (new phases appended)
5. If the scope interview happened: summarize what was captured in the spec
6. If scaffolding only: remind user to fill in the TODO sections and define new phases
