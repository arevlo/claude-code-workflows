---
description: Generate an interactive architecture dashboard for the current project during brainstorming. Use when the user wants to visualize project architecture, understand the tech stack, see system layers, or explore how components relate. Triggers on "show architecture", "project overview", "visualize the project", "architecture dashboard".
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Project Architecture Dashboard

Generate a rich, interactive HTML dashboard that visualizes the current project's architecture, then serve it locally in the browser.

## What This Skill Produces

A single-file HTML dashboard (dark theme, tabbed interface) showing everything relevant about the project's architecture. The dashboard is self-contained — no external dependencies.

## Process

### 1. Analyze the Project

Explore the codebase to extract architecture signals:

- **Package ecosystem**: Read `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc. Extract dependencies, scripts, workspaces.
- **Folder structure**: Map the top 3 levels of the directory tree. Identify patterns (monorepo, framework conventions, design system).
- **Config files**: Tailwind, theme configs, tsconfig, CI/CD, MCP configs.
- **Design tokens**: CSS variables, token JSON files, theme files. Extract color palettes, typography scales, spacing systems.
- **Framework integrations**: Identify protocols (AG-UI, MCP, A2A), SDKs, API clients.
- **Component inventory**: Count components by category (atoms, molecules, organisms, etc.) if a component library exists.

### 2. Generate the Dashboard HTML

Build a single HTML file with these characteristics:

**Visual style:**
- Dark background (#0a0a0f), light text (#e4e4e7)
- Font: Inter / system-ui
- Gradient accents for section headers
- Smooth transitions and hover states
- Fully responsive

**Tab structure** (include only tabs where you found relevant data):

| Tab | Content |
|-----|---------|
| **Overview** | Protocol/layer stack, project purpose, key stats |
| **Tech Stack** | Dependencies grouped by category (framework, UI, build, test) with version badges |
| **Architecture** | System diagram showing layers from frontend to protocol to backend to integrations |
| **Design System** | Color palettes (rendered swatches), typography scale, spacing tokens |
| **Components** | Component inventory by category with counts |
| **Integrations** | External services, APIs, MCP servers, framework partnerships |
| **Folder Structure** | Interactive tree view of the project |

**Interactive elements:**
- Tabbed navigation (sticky)
- Hover states on cards and layers
- Color swatches that show hex values
- Collapsible tree nodes for folder structure

### 3. Serve It

```bash
# Write the HTML and open it
DASHBOARD_PATH="/tmp/project-architecture-dashboard.html"
open "$DASHBOARD_PATH"
```

Or serve via a simple HTTP server if the file is large:
```bash
cd /tmp && python3 -m http.server 8765 &
```

### 4. Present to the User

Tell the user:
- The URL or file path to open
- A brief text summary of what's in each tab
- Ask what they want to explore or change

## Key Principles

- **Auto-detect everything** — the skill should work on any project without configuration
- **Only show what exists** — don't create empty tabs for things the project doesn't have
- **Real data only** — extract actual colors, actual dependency versions, actual component counts
- **Single file** — the HTML must be fully self-contained (inline CSS, inline JS, no CDN links)
- **Fast** — parallelize the analysis phase, don't read every file in the project

## Example Invocations

- "Show me the project architecture"
- "I need to understand this codebase before we start"
- "Visualize the design system"
- "What does this monorepo look like?"
- `/proj-architecture`
