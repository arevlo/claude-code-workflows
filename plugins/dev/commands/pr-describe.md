---
description: Generate/update PR description based on all changes from main
allowed-tools: Bash,Read,AskUserQuestion
---

Generate or update the PR description to reflect all changes from main. Works for initial PRs and follow-up commits.

## Steps:

1. **Check PR exists:**
   - Run `gh pr view --json number,body -q '.number'`
   - If no PR exists, tell user to create one first

2. **Get all changes from main:**
   - Run `git log main..HEAD --oneline` to see all commits
   - Run `git diff main...HEAD --stat` for changed files summary
   - Run `git diff main...HEAD` for full diff (if not too large)

3. **Generate PR description** following best practices:

   ```markdown
   ## Summary
   <!-- 2-3 sentences: what changed and WHY -->

   ## Changes
   <!-- Bullet list of key changes, grouped by concept -->
   -

   ## Test Plan
   <!-- How to verify this works (if applicable) -->

   ## Related Issues
   <!-- Use "Closes #123" to auto-link/close issues -->
   ```

   Guidelines:
   - Focus on the "what" and "why", not implementation details
   - Group related changes by concept/problem being solved
   - Include screenshots section if UI changes detected (leave placeholder)
   - Keep it concise but informative
   - Use `Closes #N` or `Fixes #N` to link issues

4. **Show the description** to user and ask for confirmation before updating

5. **Update the PR:**
   - Run `gh pr edit --body "<description>"`

6. **Confirm** the PR was updated with link to view it.
