---
description: Full commit workflow - detects changes, generates conventional commits, updates PRs
allowed-tools: Bash,Read,AskUserQuestion
---

Commit staged/unstaged changes following commit best practices. Checks branch status and updates PR description if applicable.

## Steps:

1. **Detect changes across repositories:**
   - For each modified/new file being committed, check its git root: `git -C <file-dir> rev-parse --show-toplevel`
   - Group files by their git root directory
   - If multiple repos detected, inform user:
     ```
     Changes detected in multiple repositories:
     - /path/to/repo1: file1.md, file2.tsx
     - /path/to/repo2: file3.md
     These will be committed separately.
     ```
   - Process each repo independently through remaining steps

2. **Check branch status (per repo):**
   - Run `git branch --show-current` to get current branch
   - If on `main`, ask user to create a feature branch first
   - Get git username: `git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-'`
   - **Branch naming format:** `<username>.<type>-<description>`
     - Examples: `johndoe.docs-update-readme`, `janedoe.feat-new-feature`

3. **Check if branch PR was already merged:**
   - Run `gh pr view --json mergedAt -q '.mergedAt'`
   - If returns a timestamp (not empty), the PR was MERGED
   - **CRITICAL:** If merged, DO NOT commit to this branch - commits won't reach main!
   - Warn user and MUST create new branch from main

4. **If branch was merged, handle it:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b <username>.<type>-<description>
   ```
   - Ask user for new branch name using the `<username>.<type>-<description>` format

5. **Check for changes:**
   - Run `git status` to see staged and unstaged changes
   - Run `git diff --stat` to summarize changes
   - If no changes, tell user and exit

6. **Stage changes** (if needed):
   - Show unstaged files and ask which to include
   - Run `git add <files>` for selected files

7. **Generate commit message:**
   - Follow conventional commits: `type: brief description`
   - Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`
   - Maximum 50 characters
   - NO emoji, NO AI attribution, NO co-authorship

8. **Show commit preview and get confirmation:**
   - Show what will be committed
   - Show proposed commit message
   - **WAIT for explicit "yes" before executing**

9. **Commit:**
   ```bash
   git commit -m "<message>"
   ```

10. **Check if PR exists and update description:**
    - Run `gh pr view --json number -q '.number'`
    - If PR exists, run `/pr-describe` to update it with new changes
    - If no PR, ask if user wants to push and create one

11. **Push** (only if user confirms):
    - Run `git push origin <branch>`

12. **Repeat for next repo** (if multiple repos detected in step 1)

## Commit Message Format

```
type: brief description (50 chars max)
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Code restructure
- `test:` - Tests
- `chore:` - Maintenance

## Examples

- `feat: add now page to portfolio`
- `fix: resolve file path issue`
- `docs: update installation guide`
- `chore: update dependencies`
