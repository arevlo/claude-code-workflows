---
description: Use when the user wants to fix PR review findings on the current PR. Fetches open Cubic and Codex (chatgpt-codex-connector) comments, GitHub code scanning alerts (CodeQL), and Copilot Autofix suggestions, triages them, applies fixes, and commits.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

# Resolve Cubic & Codex PR Review Comments

Fetch open Cubic and Codex findings from the current PR, triage and fix them, then commit.

## Instructions

### Step 1 — Get current PR number

```bash
gh pr view --json number,url -q '{number,url}'
```

If no PR exists, inform the user and stop.

### Step 2 — Fetch all review bot comments

Fetch PR review comments from Cubic, Codex, Copilot Autofix, and GitHub Advanced Security:

```bash
# All review comments — filter to known bots
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | select(.user.login | test("cubic|chatgpt-codex-connector|copilot|github-advanced-security"; "i")) | {id, path, line, body, source: .user.login}'
```

Also fetch open code scanning alerts for the PR's head commit:

```bash
# Get PR head SHA
HEAD_SHA=$(gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha')

# Fetch open code scanning alerts on that commit
gh api "repos/{owner}/{repo}/code-scanning/alerts?state=open&ref=$HEAD_SHA" \
  --jq '.[] | {number: .number, rule: .rule.id, severity: .rule.severity, description: .rule.description, path: .most_recent_instance.location.path, line: .most_recent_instance.location.start_line, message: .most_recent_instance.message.text, tool: .tool.name}'
```

Merge both into a unified findings list, tagging each with its source (`cubic`, `copilot`, `codeql`, or other tool name).

### Step 3 — Filter to unresolved findings

**Review comments:**
- Skip any comment whose body contains `✅ Addressed`
- Skip any comment whose body starts with `<!-- resolved -->`
- Skip any finding comment if the PR author has already replied in that thread. To detect this, fetch all comments and group by `in_reply_to_id`: if a finding comment's id appears as a `in_reply_to_id` with a non-bot reply, the thread is handled.

```bash
# Find all finding comment IDs that already have a non-bot reply from the PR author
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | select(.in_reply_to_id != null) | select(.user.login | test("cubic|chatgpt-codex-connector|copilot|github-advanced-security"; "i") | not) | .in_reply_to_id'
```

Any finding whose id appears in this list should be skipped — it has already been addressed in a previous run.

**Code scanning alerts:**
- Skip any alert with state `dismissed` or `fixed`
- Note: replying to a `github-advanced-security[bot]` inline comment has no effect on the alert — the alert auto-closes when CodeQL re-scans and no longer detects the issue. Only dismiss an alert if it's a confirmed false positive you want to permanently suppress.

Group remaining findings by file path.

### Step 4 — Triage findings

For each unresolved finding:

**Cubic comments:**
1. Extract the issue description (before the `<details>` block)
2. Extract the confidence score from `<!-- metadata:{"confidence":N} -->`
3. Extract the priority (P0/P1/P2/P3) from the body

**Copilot Autofix comments:**
1. Extract the vulnerability description from the comment body
2. Note the suggested fix approach (Copilot explains it in prose)

**Code scanning (CodeQL/other):**
1. Use `rule.id` and `message.text` as the issue description
2. Use `rule.severity` as priority proxy (error=P0, warning=P1, note=P2)
3. Check if a Copilot Autofix comment exists for the same file/line — if so, link them

Read the affected file and surrounding context for each finding.

Present a unified summary table to the user:

```
| # | Source  | Pri | File | Line | Issue |
|---|---------|-----|------|------|-------|
| 1 | cubic   | P0  | src/foo.ts | 42 | Description... |
| 2 | codex   | P2  | src/bar.ts | 15 | Auto-selection overwritten after fetch |
| 3 | codeql  | P0  | src/baz.ts | 25 | Incomplete multi-character sanitization |
| 4 | copilot | P1  | src/baz.ts | 25 | Autofix: strip tags in loop + escape < > |
```

Ask: "Fix all, or select specific items? (all / 1,3,5 / skip)"

### Step 5 — Apply fixes

For each accepted finding:
1. Read the file to understand full context
2. Validate that the issue is real (bots can have false positives)
3. If the issue is valid, apply the fix using Edit
4. If the issue is a false positive, note it and skip
5. If Cubic provided a `suggestion` block, use it as a starting point but verify correctness
6. If a Copilot Autofix comment describes a fix, use that approach but implement it correctly (don't blindly copy — verify the suggestion is safe and complete)

Report any false positives: "Skipped #N — false positive: [reason]"

### Step 6 — Commit and push

Stage all changed files and commit:

```
fix: address Cubic/Codex review findings
```

Ask: "Push now? (yes / no)"

If yes, push to the current branch.

### Step 7 — Reply to resolved threads

After pushing, reply to every resolved finding's comment thread so future runs skip them. This is critical for findings where the fix was in a different file than the comment — Cubic auto-resolves comments on changed files, but comments on unchanged files stay open.

For each resolved finding comment, post a reply:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  -X POST \
  -f body="Fixed in <commit_sha> — <brief explanation of what was fixed and where>" \
  -F in_reply_to=<comment_id>
```

Skip this for findings that Cubic already marked `✅ Addressed` (those are handled automatically).

### Step 8 — Summary

Print what was done:

```
Resolved: #1 (P0 sandbox security), #3 (P2 font format)
Skipped:  #2 (false positive — file is actually .ttf)
Remaining: none
```
