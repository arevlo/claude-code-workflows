---
description: Check out an existing or new branch. With a name arg, creates a new branch. Without args, checks out the main branch or picks from recent branches. Triggers on "checkout", "switch branch", "new branch".
allowed-tools: Bash, AskUserQuestion
---

# Checkout Branch

Check out a branch. Creates new branches with `<username>.` prefix per convention.

**Args:** `$ARGUMENTS` (optional branch name)

## Steps

1. **Detect main branch:**
   - Run: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
   - If empty, try: `git branch -l main master develop development | head -1 | xargs`
   - Store as `$MAIN_BRANCH`

2. **Check for uncommitted changes:**
   - Run `git status --porcelain`
   - If there are changes, warn the user and ask:
     ```
     You have uncommitted changes. What would you like to do?
     1. Stash changes and proceed
     2. Cancel
     ```
   - If stash: run `git stash push -m "dev:checkout auto-stash"`

3. **If no arguments provided:**

   **3a. Already on main branch** — offer interactive picker:
   - Check current branch: `git branch --show-current`
   - If already on `$MAIN_BRANCH`, gather switch options:
     - **Recent branches:** `git branch --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' | grep -v "^$MAIN_BRANCH$" | head -5`
     - **Active worktrees:** `git worktree list` (exclude the main worktree)
   - Build an `AskUserQuestion` with up to 4 options from what's available:
     - If worktrees exist, include the first 1-2 as options (label: branch name, description: path + "worktree")
     - Fill remaining slots with recent branches (label: branch name, description: "last commit X ago")
     - Always include one option: "Create new branch" (description: "Will prompt for name")
   - Based on selection:
     - **Worktree selected:** Git won't allow checking out a branch that's already in a worktree, so you must `cd` there instead. Try `cd <worktree-path>` then verify with `pwd`. If the CWD sticks, you're good. If it resets (session pinned to a subdirectory), give the user a ready-to-paste command:
       ```
       cd <worktree-path> && claude
       ```
     - **Recent branch selected:** Run `git checkout <branch>` then `git pull --ff-only` if tracking remote
     - **Create new:** Ask for branch name, then follow step 4 Case C logic

   **3b. Not on main branch** — switch to main:
   - Run `git checkout $MAIN_BRANCH`
   - Run `git pull --ff-only`
   - Tell user they're on the main branch, up to date

4. **If a branch name is provided** (`$ARGUMENTS`):
   - Set `branch_name` to `$ARGUMENTS`
   - Get git username: `git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-'`
   - If the name does NOT already start with `<username>.`, prefix it: `<username>.$ARGUMENTS`
   - Check if branch already exists locally: `git branch --list $branch_name`
   - Check if branch exists on remote: `git ls-remote --heads origin $branch_name`

   **Case A: Branch exists locally**
   - Run `git checkout $branch_name`
   - If remote tracking exists, run `git pull --ff-only`
   - Tell user: "Switched to existing branch $branch_name"

   **Case B: Branch exists only on remote**
   - Run `git checkout -b $branch_name origin/$branch_name`
   - Tell user: "Checked out remote branch $branch_name"

   **Case C: Branch does not exist anywhere (new branch)**
   - Fetch and checkout main first: `git fetch origin $MAIN_BRANCH`
   - Create from main: `git checkout -b $branch_name origin/$MAIN_BRANCH`
   - Tell user: "Created new branch $branch_name from $MAIN_BRANCH"

5. **Summary:** Show current branch and status.
