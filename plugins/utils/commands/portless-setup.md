---
description: Use when setting up portless dev URLs for a new project — wraps dev script, creates deploy skill
argument-hint: "[workspace]"
allowed-tools: Bash, Read, Edit, Write
---

# Setup Portless for Project

Automate [portless](https://github.com/nicholasgriffintn/portless) integration for any project repo. Wraps the `dev` script in package.json and creates a project-local deploy skill.

## Arguments

- **workspace** (optional): For monorepos, specify which workspace to target.
  - Example: `/portless-setup @myorg/app`

## Steps

### 1. Detect project root and repo name

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$PROJECT_ROOT")
```

### 2. Derive namespace

Split repo name on first hyphen to create colon-separated namespace:
- `my-app` → `my:app`
- `some-docs` → `some:docs`
- `singleword` → `singleword`

Logic: replace the FIRST hyphen with a colon. If no hyphen, use the name as-is.

```bash
NAMESPACE=$(echo "$REPO_NAME" | sed 's/-/:/')
SKILL_NAME="${NAMESPACE}:deploy"
```

### 3. Check portless is installed

```bash
which portless
```

If missing, run:
```bash
npm install -g portless
```

### 4. Read package.json

Read `$PROJECT_ROOT/package.json` using the Read tool.

### 5. Handle monorepo workspaces

If `workspaces` exists in package.json AND no workspace argument was provided:
- Ask the user which workspace to target
- List the workspaces as options
- Store the selected workspace for use in the dev command

If a workspace argument was provided, use that directly.

If no `workspaces` field exists, skip this step.

### 6. Wrap the dev script in package.json

Read the current `"dev"` script value.

**If the dev script already starts with `portless`:**
- Skip the package.json edit
- Tell the user: "Dev script already uses portless — skipping package.json update."
- Jump to step 7 (deploy skill creation)

**If the dev script does NOT start with `portless`:**
- Save the original command (e.g. `next dev`, `vite`, etc.) as `DEV_COMMAND`
- For monorepos with a workspace, the wrapped command should be:
  ```
  "dev": "portless <REPO_NAME> npm run dev -w <workspace>"
  ```
- For non-monorepo projects:
  ```
  "dev": "portless <REPO_NAME> <DEV_COMMAND>"
  ```
- Also add `"dev:stop": "portless proxy stop"` if that script doesn't already exist
- Use the Edit tool to make these changes

### 7. Create the project-local deploy skill

Check if `.claude/skills/${SKILL_NAME}/SKILL.md` already exists in the project.

If it exists, ask the user whether to overwrite or skip.

If it doesn't exist (or user chose overwrite), create it.

**Determine the dev run command** for the deploy skill:
- For monorepos: `portless <resolved-name> npm run dev -w <workspace>`
- For non-monorepos: `portless <resolved-name> <DEV_COMMAND>`

Where `<resolved-name>` is a placeholder that the deploy skill resolves at runtime (defaults to `REPO_NAME`).

Create the directory and file:

```bash
mkdir -p "$PROJECT_ROOT/.claude/skills/${SKILL_NAME}"
```

Write a deploy skill template to `$PROJECT_ROOT/.claude/skills/${SKILL_NAME}/SKILL.md` that:
- Detects the project root (worktree-aware)
- Checks portless is installed
- Installs dependencies if needed
- Resolves the subdomain name (supports custom names, auto-increments on conflict)
- Starts the dev server in the background
- Confirms it's running via `portless list`
- Outputs the URL: `http://<name>.localhost:1355`
- Documents how to stop (specific route or all routes)

### 8. Summary

Print a summary of what was done:
- Whether package.json was updated (and what changed)
- The path to the created deploy skill
- The dev URL: `http://<REPO_NAME>.localhost:1355`
- Remind: run `npm run dev` to start, `npm run dev:stop` to stop
- Remind: "The deploy skill was installed but won't appear until you reset the conversation (`/clear` or restart Claude Code)."
