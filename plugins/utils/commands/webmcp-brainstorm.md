---
description: Brainstorm WebMCP tools for any project — reads project context, specs, mock data, and existing tools to generate categorized tool ideas. Design-only output (no code stubs).
allowed-tools: Bash, Read, Glob, Grep
---

# Brainstorm WebMCP Tools

## Overview

Reads project context (CLAUDE.md, specs/, mock data, existing tools) and generates categorized WebMCP tool ideas. Specialized for WebMCP tool design — helps teams decide what tools to register before writing any code.

**Announce at start:** "Using webmcp-brainstorm to explore tool ideas."

## Workflow

```
Gather context -> Scan existing tools -> Categorize opportunities -> Present tool ideas -> User selects priorities -> Output detailed specs
```

## Steps

### 1. Gather Project Context (parallel)

Read the following sources to understand the project:

| Source | What to extract |
|--------|----------------|
| **CLAUDE.md** | Architecture, features, key patterns, routing, state management |
| **specs/** | `readme.md` + feature specs — planned work drives Feature-specific tools |
| **Mock data** | Models, entities, relationships — scan `MockData.swift`, `MockData.kt`, `mock-data.ts`, `types.ts`, `Models.swift`, `Models.kt` |
| **Existing WebMCP tools** | Grep for `registerTool` calls and `useWebMCP` hooks to list already-registered tools |

If a source doesn't exist (e.g., no `specs/`), skip it gracefully — note "No specs found, skipping feature-specific category" and continue.

### 2. List Existing Tools

Before generating ideas, present what's already registered:

```
Already registered:
- get_current_page — Returns current route
- navigate_to_page — Navigate to a specific page
- get_app_info — Returns app metadata
```

This prevents duplicates and shows the starting point.

### 3. Categorize Tool Opportunities

Organize ideas into 5 buckets:

| Category | Description | Example |
|----------|-------------|---------|
| **Navigation** | Route/view switching, tab control, modal open/close | `navigate_to_page`, `open_detail_panel` |
| **Data access** | Read state, lists, entity details, search/filter | `get_units`, `get_work_order_details` |
| **Actions** | Create, update, delete, trigger workflows | `create_work_order`, `approve_application` |
| **Context** | App info, user state, configuration, permissions | `get_app_info`, `get_current_user` |
| **Feature-specific** | Tools tied to upcoming specs or planned features | Derived from specs/ |

### 4. Present Tool Ideas

Output one table per category:

```markdown
### Navigation

| Name | Description | Scope | Rationale |
|------|-------------|-------|-----------|
| open_unit_detail | Open the detail panel for a specific unit | component | Lets AI drill into unit data without full page nav |
| toggle_sidebar | Expand or collapse the sidebar navigation | global | Controls layout for screenshot/demo workflows |
```

Repeat for each category. Skip empty categories.

### 5. Ask User to Select

Ask which categories to detail further. Let the user pick one or more.

### 6. Output Detailed Specs

For each tool in selected categories, output:

```markdown
#### get_units

- **Description:** Returns a list of all units with their status, tenant, and rent details
- **Input schema:** `{ type: 'object', properties: { status: { type: 'string', enum: ['occupied', 'vacant', 'maintenance'], description: 'Filter by unit status' } } }`
- **Scope:** global (register-tools.ts)
- **Rationale:** Core data access — AI agents need unit lists for most property management tasks
```

**No code stubs.** Design-only output that feeds into implementation.

## Key Principles

Embed these in every tool suggestion:

1. **Expose business logic, not UI logic** — `get_units` yes, `click_button` no
2. **One tool per action** — `get_unit` + `update_unit` over `manage_unit`
3. **Descriptions are critical** — LLMs rely on them for tool selection; be specific
4. **Global for app-level, component-scoped for page-specific** — global tools go in `register-tools.ts`, page tools use `useEffect` with `registerTool`/`unregisterTool`
5. **Max ~50 tools per page** — keep focused; too many tools degrades LLM selection
6. **Match mock data entities** — every model in MockData should have at least a `get_` tool
7. **Scan existing tools first** — always deduplicate against what's already registered

## Common Mistakes

- **Generating code stubs** — this skill produces design specs only; implementation is a separate step
- **Skipping existing tool scan** — always grep for `registerTool` first to avoid duplicates
- **UI-level tools** — "click the submit button" is not a good tool; "submit_application" is
- **Monolith tools** — `manage_everything` with 10 params; split into focused single-action tools
- **Missing descriptions** — every tool needs a clear description; LLMs can't use tools they don't understand
- **Ignoring mock data** — mock data files define the entities available; tools should mirror them
