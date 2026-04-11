# Specs

Feature spec lifecycle management -- create, version, and restructure implementation specs.

## Installation

```bash
/plugin marketplace add arevlo/claude-code-workflows
/plugin install specs@claude-code-workflows
```

## What's Included

### Commands

| Command | Description |
|---------|-------------|
| `/feature` | Create a new feature spec or iterate on an existing one in `specs/` |
| `/next-version` | Create next versioned feature spec (v{N+1}) when starting a new dev cycle |
| `/refine` | Restructure existing `specs/` to match the canonical 4-file pattern |

## Spec Structure

The canonical spec layout that these commands produce and maintain:

```
specs/
  readme.md                -- Project spec (stable base)
  v1-feature-name.md       -- Feature spec (WHAT to build)
  implementation-plan.md   -- Build plan (HOW -- phases, steps, validation)
  prompt.md                -- Iteration prompt for autonomous loops
```

## Workflow

### Starting a new project

```
/refine
```

Restructures an existing `specs/` directory into the canonical 4-file pattern. Extracts WHAT (requirements, architecture, data models) into a versioned feature spec and keeps HOW (phases, steps, verification) in the build plan.

### Adding a feature

```
/feature
```

Interactive workflow that interviews you about the feature scope, then creates a new `{feature-name}.md` and appends phases to the build plan.

### Starting a new dev cycle

```
/next-version
```

Creates `v{N+1}-{name}.md` when the current version is complete. Carries forward decisions, unfinished items, or architecture as requested. Marks previous phases complete and appends new phase skeletons.

## Requirements

- A `specs/` directory in the project (run `/refine` to bootstrap one)
- Uses `AskUserQuestion` for interactive prompts
