---
description: Request AI code review on the PR via GitHub comment
allowed-tools: Bash,AskUserQuestion
---

Post a comment on the current PR to trigger AI code review.

## Steps:

1. **Get current PR number:**
   - Run `gh pr view --json number -q .number`
   - If no PR exists, tell user to create one first

2. **Ask user** which reviewer(s) they want:
   - Claude (@claude)
   - Codex (@codex)
   - Both

3. **Post review request comment(s):**
   - If Claude: `gh pr comment <number> --body "@claude review this PR"`
   - If Codex: `gh pr comment <number> --body "@codex review this PR"`
   - If Both: post both comments

4. **Confirm** which reviewer(s) were requested.

## Notes

- Requires GitHub CLI (`gh`) to be installed and authenticated
- Requires the AI reviewer apps to be installed on the repository
