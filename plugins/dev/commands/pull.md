---
description: Pull the latest changes from remote. Triggers on "pull", "pull latest", "pull from main", "sync with main", "get latest changes".
allowed-tools: Bash, AskUserQuestion
---

# Pull Latest Changes

Pull latest changes from remote into the current branch.

**Args:** `$ARGUMENTS` (optional branch name to pull from)

## Behavior

| Situation | Default action |
|-----------|---------------|
| On any branch, no arg | `git pull --ff-only` from current branch's upstream |
| On any branch, arg = `main` (or another branch) | Fetch then merge/rebase that branch into current |

## Steps

### 1. Detect context

```bash
git branch --show-current          # current branch
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```

Store current branch as `$CURRENT_BRANCH` and main branch as `$MAIN_BRANCH`.

### 2. Resolve target branch

- If `$ARGUMENTS` is provided → `$TARGET = $ARGUMENTS`
- Otherwise → `$TARGET = $CURRENT_BRANCH`

### 3. Check for uncommitted changes

```bash
git status --porcelain
```

If dirty, ask:
```
You have uncommitted changes. What would you like to do?
1. Stash changes, pull, then restore them
2. Cancel
```

If stash: `git stash push -m "dev:pull auto-stash"`

### 4. Pull

**Case A: `$TARGET == $CURRENT_BRANCH` (pulling own upstream)**

```bash
git pull --ff-only
```

If `--ff-only` fails (diverged history), report:
```
Cannot fast-forward. Your branch has diverged from origin/<branch>.
Run `/resolve` or choose: rebase, merge, or cancel.
```
Ask with AskUserQuestion (rebase / merge / cancel). Then run accordingly.

**Case B: `$TARGET != $CURRENT_BRANCH` (pulling a different branch)**

Fetch the target branch first:
```bash
git fetch origin $TARGET
```

Ask how to incorporate:
```
How do you want to incorporate changes from $TARGET into $CURRENT_BRANCH?
1. Rebase (cleaner history, rewrites commits)
2. Merge (preserves history, adds a merge commit)
```

- Rebase: `git rebase origin/$TARGET`
  - If conflicts: report conflicting files, suggest `/resolve`
- Merge: `git merge origin/$TARGET`
  - If conflicts: report conflicting files, suggest `/resolve`

### 5. Pop stash (if stashed)

```bash
git stash pop
```

If conflicts on pop, warn user to resolve manually.

### 6. Summary

Report:
- Branch pulled into
- Source branch / remote
- New commits incorporated (run `git log ORIG_HEAD..HEAD --oneline` after pull)
- Stash status if applicable

## Edge Cases

- **No upstream set:** Warn "No upstream configured for `$CURRENT_BRANCH`. Use `/push` to push and set upstream first."
- **Already up to date:** Report "Already up to date with origin/$TARGET."
- **Detached HEAD:** Warn and exit — cannot pull in detached HEAD state.
- **Force-with-lease needed after rebase:** Warn user their next push will need `--force-with-lease`.
