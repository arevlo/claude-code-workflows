---
description: Create prompts for Figma Make projects (research → synthesis → save)
allowed-tools: Task, mcp__notion__notion-search, mcp__notion__notion-fetch, mcp__notion__notion-create-pages, mcp__figma-desktop__get_design_context, mcp__figma-desktop__get_variable_defs, mcp__figma-desktop__get_screenshot, Bash, Write, Glob, Grep, Read, AskUserQuestion
make_projects_path: ~/Desktop/repos/figma-make
---

Create optimized prompts for Figma Make through an interactive research workflow.

**This is a research/analysis workflow - you are NOT writing code. You are generating prompts that will be used by Figma Make (which uses Claude) to implement features.**

---

## Configuration

- **Notion database**: `_make` (for prompts)
- **Context database**: `_clawd` (for specs/references)
- **Make projects path**: See `make_projects_path` in frontmatter (customize for your setup)

---

## Workflow

### Step 1: Select Make Project

1. List folders matching `[Make]*` pattern in the configured `make_projects_path`
2. Present as a picker using AskUserQuestion:
   - Show discovered project names (e.g., "Unit Pricing", "Workflows x Maintenance")
   - Include "Other" option for custom project name
3. Selected project is used for Notion tags and filenames only (don't change directories)

### Step 2: Describe What to Build

Ask the user with a free-form prompt:
> "Describe what you want to build. Include the problem you're solving, any constraints, files involved, and desired outcome."

### Step 3: Figma Reference (Optional)

Ask: "Do you want to reference a Figma component for design context?"

If yes:
- Ask for Figma URL or use currently selected component
- Use `mcp__figma-desktop__get_design_context` to analyze the component
- Use `mcp__figma-desktop__get_variable_defs` to get design tokens
- Optionally use `mcp__figma-desktop__get_screenshot` for visual reference
- Extract: colors, spacing, typography, layout structure
- Include these design specs in the generated prompt

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

### Step 5: Notion Context Search

Search both databases for relevant context:

1. **Search `_clawd`** for specs/context related to the project
2. **Search `_make`** for previous prompts on the same project

Present top matches and let user confirm which to include as references.

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
