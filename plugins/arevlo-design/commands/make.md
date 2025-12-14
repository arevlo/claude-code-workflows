---
description: Create prompts for Figma Make projects (research → synthesis → save)
allowed-tools: Task, mcp__notion__notion-search, mcp__notion__notion-fetch, mcp__notion__notion-create-pages, mcp__figma-desktop__get_design_context, mcp__figma-desktop__get_variable_defs, mcp__figma-desktop__get_screenshot, Bash, Write, Glob, Grep, Read, AskUserQuestion
make_projects_path: ~/Desktop/repos/figma-make
---

Create optimized prompts for Figma Make through an interactive research workflow.

**This is a research/analysis workflow - you are NOT writing code. You are generating prompts that will be used by Figma Make (which uses Claude) to implement features.**

---

## Interaction Guidelines

**This workflow is interactive.** Use `AskUserQuestion` throughout:

- **Always ask** at decision points (don't assume or skip)
- **Offer clear options** with descriptions, not yes/no questions
- **Follow up** when answers are vague or incomplete
- **Confirm understanding** before generating the final prompt

Example follow-ups:
- "You mentioned styling - do you have a Figma component or screenshot to reference?"
- "I found 3 related components. Which patterns should I follow?"
- "The recent prompt modified this file. Should I build on those changes?"

---

## Configuration

- **Notion database**: `_make` (for prompts)
- **Context database**: `_clawd` (for specs/references)
- **Make projects path**: See `make_projects_path` in frontmatter (customize for your setup)

---

## Workflow

### Step 0: Check for Recent Activity

If a prompt was recently created for this project (within current session), **use AskUserQuestion** with these options:

```
Question: "I see you recently created a prompt. What would you like to do?"

Options:
1. Modify the existing prompt - Edit or add to the prompt I just created
2. Create a new prompt - Start fresh with a different feature
3. Exit - I'm done for now
```

**You MUST present this as an interactive picker, not just text.**

- If **Modify**: Open the existing prompt for editing
- If **Create new**: Continue to Step 1
- If **Exit**: End the workflow

### Step 1: Select Make Project

1. List folders matching `[Make]*` pattern in the configured `make_projects_path`
2. Present as a picker using AskUserQuestion:
   - Show discovered project names (e.g., "Unit Pricing", "Workflows x Maintenance")
   - Include "Other" option for custom project name
3. Selected project is used for Notion tags and filenames only (don't change directories)

### Step 2: Describe What to Build

Ask the user with a free-form prompt:
> "Describe what you want to build. Include the problem you're solving, any constraints, files involved, and desired outcome."

### Step 3: Figma Context

**Always ask:** "Do you want to add Figma context? You can paste a component link for styling/layout reference."

Options:
1. **Yes, paste Figma link** - I'll share a component URL
2. **Add screenshot instead** - I'll paste a screenshot path
3. **Skip** - No visual reference needed

**If Figma link:**
- User pastes a Figma component URL (e.g., `https://figma.com/design/.../node-id=123:456`)
- Extract node ID from URL
- Use `mcp__figma-desktop__get_design_context` with that nodeId
- Use `mcp__figma-desktop__get_variable_defs` for design tokens
- Extract: colors, spacing, typography, layout structure
- Include these in the generated prompt

**If screenshot:**
- Ask for screenshot path
- Use `Read` tool to view the image
- Describe visual elements and include in prompt

**Include in prompt:**
- Design tokens (colors, spacing, typography)
- Layout structure
- Link to Figma component (if provided)

### Step 4: Deep Codebase Analysis

Use the Task tool with `subagent_type: Explore` for deep codebase research:

```
Analyze the codebase for context on: {user's description}

Search for:
- Related components/patterns
- File structure and naming conventions
- Existing implementations to reference
- Files that will need modification

Return:
- File paths with line numbers for relevant code
- Current implementation details
- Design patterns used in the codebase
```

Benefits of Explore subagent:
- Uses Haiku (fast, cost-effective)
- Read-only mode (can't accidentally modify code)
- Isolated context (findings returned without bloating main context)

### Step 5: Context & State Resolution

**IMPORTANT:** The codebase may not reflect the latest state. Same-day prompts may have already been implemented in Figma Make but not yet downloaded/pushed to the repo.

#### 5a. Search for same-day prompts first

Search `_make` with date filter for today's date and the selected project:
- Use `mcp__notion__notion-search` with `filters.created_date_range.start_date` = today
- Filter by project name

If same-day prompts exist that touch the same files you're modifying:
1. **Fetch full prompt content** using `mcp__notion__notion-fetch`
2. **Parse "Desired State" sections** for the relevant files
3. **Use those as "Current State"** in the new prompt (since they're already implemented)
4. **Link to the source prompt** so Claude knows where the context came from

Example "Current State" when sourced from recent prompt:
```markdown
**Current State** (from today's prompt: [Prompt: Add Tab Pinning](notion-url)):
```tsx
// Code from that prompt's "Desired State" section
```
```

#### 5b. Search for specs and older prompts

1. **Search `_clawd`** for specs/context related to the project
2. **Search `_make`** for older prompts on the same project (for patterns/context)

**Present references with today's prompts recommended:**

```
Which related pages should I reference?

Today's prompts (recommended):
1. [x] Prompt: Feature X - (Today)
2. [x] Prompt: Feature Y - (Today)

Older prompts:
3. [ ] Prompt: Prior Feature - (Dec 10)
4. [ ] Context: Spec Doc

5. [ ] None - Don't include any references
```

- **Today's prompts go first** and should be pre-selected
- **Mark them "(Today - Recommended)"** so user knows they're current
- **Older prompts below** are available but not pre-selected

#### 5c. State resolution priority

When determining "Current State" for a file:
1. **Same-day prompts** (highest priority) - use their "Desired State"
2. **Codebase analysis** (fallback) - use actual code from repo

If using prompt-sourced state, always note this in the generated prompt so Figma Make knows the context source.

### Step 6: Choose Destination

Ask user where to save the prompt:

```
Where should I save this prompt?

1. Local /tmp folder (quick, ephemeral)
2. Notion (_make database)
3. Docs folder (./docs/prompts/)    [only if docs/ exists]
```

Only show "Docs folder" option if `docs/` directory exists in current repo.

### Step 7: Generate Prompt

Use this template structure (proven to work with Figma Make):

```markdown
## Problem Statement
**{Bold one-liner describing what to build}** - {brief context}
**Reference Component**: `{path/to/main/Component.tsx}`

---

## Changes Overview
{Numbered list of ALL changes upfront}
1. {Change 1}
2. {Change 2}
3. {Change 3}

---

## 1. {First Change Title}

**Location**: `{file path}` (lines {X-Y})

**Current State**:
```tsx
{Actual code showing what exists now}
```

**Desired State**:
{Description + ASCII diagram if UI-related}
```
┌────────────────────┐
│ Visual mockup      │
│ using box drawing  │
└────────────────────┘
```

**Implementation**:
```tsx
{Ready-to-use code snippet}
```

**Files to Modify**:
- `path/to/File1.tsx`
- `path/to/File2.tsx`

---

## Design System Tokens
```css
/* Include relevant tokens from Figma analysis or codebase */
--bg-primary: #value
--text-primary: #value
--spacing-lg: value
```

---

## Component File Reference
| Component | File Path | Line References |
|-----------|-----------|-----------------|
| {Name} | `{path}` | {relevant lines} |

---

## Related
- **Spec:** [Spec: {Name}]({notion-url}) in _clawd
- **Previous Prompt:** [Prompt: {Name}]({notion-url}) in _make
- **Figma:** [{Component}]({figma-url}) (if referenced)

---

## Success Criteria
✅ {Specific check 1}
✅ {Specific check 2}
✅ All styling uses design system tokens
✅ Changes work responsively
```

### Pattern Library (use as needed):

**ASCII UI Mockups:**
```
┌──────────────────────┐
│ Header               │
├──────────────────────┤
│ Content area         │
│   ⌘F to search       │  ← Annotations
└──────────────────────┘
```

**Before/After Comparisons:**
```
Before:
┌─────────────────────┐
│ Tab × │ Tab × │     │
└─────────────────────┘

After:
┌─────────────────────┐
│ 📌 Tab │ Tab ×  │   │
└─────────────────────┘
```

**Context Menu Mockups:**
```
┌──────────────────────┐
│ Action 1             │
│ Action 2             │
├──────────────────────┤
│ Grouped Action       │
└──────────────────────┘
```

**Theme Variants Block:**
```
Light Theme:
- Background: #f7f3ea
- Text: #2b2b2b

Dark Theme:
- Background: #141413
- Text: #faf9f5
```

**Summary Table:**
| Feature | Behavior |
|---------|----------|
| Click | Opens in preview tab |

### Step 8: Save to Destination

**If Local /tmp:**
- Create directory `/tmp/make-prompts/` if it doesn't exist
- Save as: `prompt-{YYYY-MM-DD}-{HH-mm}-{slug}.md`
- Slugify the title (lowercase, hyphens, no special chars)
- Use Write tool
- Report full path to user

**If Notion:**
- Use `mcp__notion__notion-create-pages` to create page in `_make` database
- Set properties:
  - Name: `Prompt: {title}`
  - Project: {selected project}
  - Tags: `["Prompt", "{project-type}"]`
- Add generated prompt as page content
- Report Notion URL to user

**If Docs folder:**
- Create `docs/prompts/` subdirectory if it doesn't exist
- Save as: `{YYYY-MM-DD}-{slug}.md`
- Use Write tool
- Report relative path to user

---

## Why This Structure Works

Figma Make uses Claude under the hood. This template:

1. **Problem Statement first** - Claude knows the goal immediately
2. **Changes Overview** - Full scope upfront prevents partial implementations
3. **Per-change sections** - Current → Desired → Implementation structure
4. **ASCII diagrams** - UI layout is unambiguous
5. **Line numbers** - Claude knows exactly where to look
6. **Current state code** - No guessing what exists
7. **Implementation snippets** - Ready-to-use code reduces errors
8. **Notion links** - Claude can fetch full specs via MCP
9. **Design tokens block** - No hardcoded values
10. **Success criteria** - Clear definition of "done"
11. **State resolution from prompts** - Same-day prompts take precedence over stale codebase since Figma Make implements changes before they're pushed to the repo
