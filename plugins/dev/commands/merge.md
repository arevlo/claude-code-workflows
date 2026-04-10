---
description: Merge the current branch's PR. Options: request review (@claude/@codex), merge now (squash/merge/rebase), or admin bypass merge. Triggers on "merge", "merge my PR", "merge this branch", "bypass review".
allowed-tools: Bash, AskUserQuestion
---

# Merge PR

Merge the current branch's PR — or request a review first.

## Steps

1. **Check PR exists:**
   - Run `gh pr view --json number,state,url,title,reviewDecision`
   - If no PR, tell user: "No PR found for the current branch. Make sure you are on the feature branch and have pushed it. Run `/push` to push and create a PR."
   - If state is "MERGED": tell user "This PR is already merged." and exit
   - If state is "CLOSED": tell user "This PR is closed." and exit

2. **Show PR status:**
   Display a brief summary:
   ```
   PR #<number>: <title>
   Review status: <reviewDecision or "none">
   URL: <url>
   ```

3. **Ask what to do** with AskUserQuestion:

   Options:
   - **Request review** — ask @claude or @codex to review the PR
   - **Merge now** — merge immediately (will ask strategy next)
   - **Admin bypass** — merge ignoring branch protection rules (will ask strategy next)

4. **If "Request review":**
   Ask which reviewer(s) with AskUserQuestion:
   - @claude
   - @codex
   - Both

   Post comment(s):
   - `gh pr comment <number> --body "@claude review this PR"`
   - `gh pr comment <number> --body "@codex review this PR"`

   Confirm: "Review requested. PR: <url>"
   Stop here — do not merge yet.

5. **If "Merge now" or "Admin bypass":**
   Ask merge strategy with AskUserQuestion:
   - Squash and merge (recommended — clean history)
   - Merge commit (preserves all commits)
   - Rebase and merge (linear history, no merge commit)

   Ask with AskUserQuestion: "Delete the remote branch after merging?"
   - Yes (recommended for feature branches): include --delete-branch
   - No (keep branch): omit --delete-branch

   Build the merge command (add --delete-branch if user said yes):
   - Squash: `gh pr merge <number> --squash`
   - Merge commit: `gh pr merge <number> --merge`
   - Rebase: `gh pr merge <number> --rebase`
   - Admin bypass: append `--admin` to whichever strategy was chosen

   Run the command.
   If the command exits with a non-zero status, show the error output and stop. Common causes:
   - "Pull request is not mergeable" → unresolved conflicts, ask user to resolve and retry
   - "Required status checks have not passed" → CI is failing, do not use --admin unless intentional
   - "Resource not accessible by integration" → insufficient permissions for --admin bypass

6. **After merge:**
   Ask with AskUserQuestion:
   ```
   Merged! Pull latest main locally?
   ```
   - Yes: `git checkout main && git pull origin main`
   - No: done

   Confirm with: "Done. Branch merged and deleted."
