---
description: Push the current branch to remote. Detects first push, checks PR status, and creates a PR if requested. Triggers on "push", "push my changes", "push to remote".
allowed-tools: Bash, AskUserQuestion
---

# Push Branch

Push the current branch to remote and optionally create a PR.

## Steps

1. **Check branch:**
   - Run `git branch --show-current`
   - If output is empty, warn: "You are in a detached HEAD state. Cannot push." and exit
   - If on `main`, warn and stop — direct pushes to main are not allowed

2. **Check for unpushed commits:**
   - Run `git rev-parse --abbrev-ref @{u} 2>/dev/null` to check if an upstream exists
   - If upstream exists: run `git log @{u}..HEAD --oneline` — if empty, tell user "Nothing to push" and exit
   - If no upstream: branch has never been pushed — always proceed (first push)

3. **Check PR status:**
   Run: `gh pr view --json number,state,mergedAt,url 2>/dev/null`

   **Case A: PR exists, state="OPEN"**
   - Push: `git push origin <branch>`
   - Invoke `/pr-describe` to update PR description
   - Show PR link

   **Case B: PR exists, state="CLOSED" or mergedAt is set**
   - BLOCK — do not push
   - Warn: "This branch's PR is closed/merged. Commits won't reach main."
   - Suggest creating a new branch from main

   **Case C: No PR exists**
   Ask with AskUserQuestion:
   ```
   No PR exists yet. What would you like to do?
   1. Just push (no PR yet)
   2. Push and create PR
   ```

   - If "Just push":
     - Detect first push: `git rev-parse --abbrev-ref @{u} 2>/dev/null`
     - If no upstream: `git push -u origin <branch>`
     - Otherwise: `git push origin <branch>`

   - If "Push and create PR":
     1. `git push -u origin <branch>`
     2. `gh pr create --title "<type>: <description>" --body ""`
        Note: PR is created with empty body — /pr-describe fills it in immediately after.
     3. Invoke `/pr-describe` to generate and set the PR description
     4. Show PR link

4. **Confirm** with a summary of what was pushed and PR status.
