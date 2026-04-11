---
description: Interactively resolve git merge conflicts with AI assistance
allowed-tools: Bash,Read,Edit,AskUserQuestion,Grep
---

Intelligently resolve git merge conflicts file-by-file with context-aware assistance.

## Workflow Overview

This command guides you through resolving merge/rebase conflicts one file at a time, presenting options for each conflict and allowing intelligent merging when both sides have valid changes.

## Steps:

### 1. Check for Active Conflict State

Run `git status` to verify we're in a merge or rebase and identify all conflicted files.

If not in a conflict state, inform user:
```
Not currently in a merge or rebase.
Run this command when git reports conflicts.
```

If conflicts exist, run:
```bash
git diff --name-only --diff-filter=U
```

This returns the list of conflicted files.

### 2. Display Conflict Summary

Show user:
```
Detected X conflicting file(s):
1. path/to/file1
2. path/to/file2
...

Starting interactive resolution...
```

Store the list of files for processing.

### 3. Process Each Conflicted File

For each conflicted file:

**Step 3a: Read the file**
- Use Read tool to load the entire file
- Parse out the conflict markers and surrounding context
- Extract three sections:
  - HEAD section (lines between `<<<<<<< HEAD` and `=======`)
  - Incoming section (lines between `=======` and `>>>>>>>`)
  - Context (5 lines before and after the conflict for reference)

**Step 3b: Analyze the conflict**
- Determine file type (code, config, markdown, json, etc.)
- Identify what changed in each side
- Note if changes are compatible or contradictory

**Step 3c: Present the conflict to user**

Display format:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[File X of Y] path/to/file.ext
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Context: [Brief description of what changed]

HEAD VERSION (Your changes):
[Show 10 lines of HEAD section with line numbers]

INCOMING VERSION (Their changes):
[Show 10 lines of Incoming section with line numbers]

Surrounding context (if helpful):
[Show 2-3 lines before and after]
```

**Step 3d: Ask user for resolution choice**

Use AskUserQuestion with options:

```
What would you like to do?
```

Options:
1. **Keep HEAD** - Use your version entirely (will overwrite with git checkout --ours)
2. **Keep Incoming** - Use their version entirely (will overwrite with git checkout --theirs)
3. **Keep Both** - Merge both versions (will ask for order)
4. **Manual Merge** - Let Claude intelligently merge the two versions
5. **Skip for now** - Leave this file and move to the next one

**Step 3e: Handle resolution based on choice**

**If "Keep HEAD":**
- Confirm: "This will discard all changes from the incoming version. Continue?"
- If confirmed:
  ```bash
  git checkout --ours path/to/file
  git add path/to/file
  ```
- Message: ✅ Kept HEAD version for path/to/file

**If "Keep Incoming":**
- Confirm: "This will discard all your changes and use their version. Continue?"
- If confirmed:
  ```bash
  git checkout --theirs path/to/file
  git add path/to/file
  ```
- Message: ✅ Kept Incoming version for path/to/file

**If "Keep Both":**
- Ask: "Which version should come first? (1) HEAD first, then Incoming  OR  (2) Incoming first, then HEAD"
- Wait for choice
- Use Edit tool to:
  - Remove conflict markers
  - Combine versions in chosen order
  - Preserve all content from both sides
  - Add separator comment if needed (e.g., "# HEAD version:" / "# Incoming version:")
- Run: `git add path/to/file`
- Message: ✅ Merged both versions (HEAD first) in path/to/file

**If "Manual Merge":**
- Analyze the conflict intelligently:
  - If both sides modify the same lines in compatible ways, merge them
  - If they modify different sections, combine both
  - For config files, try to preserve both configurations
  - For code files, maintain functionality from both sides
  - Preserve formatting and style consistency
- Propose the merged result to user with explanation:
  ```
  📝 Proposed intelligent merge:

  [Show merged content]

  Reasoning: [Explain how conflicts were resolved and why]

  Accept this merge? (yes/no)
  ```
- If yes:
  - Use Edit tool to replace conflict markers with merged content
  - Run: `git add path/to/file`
  - Message: ✅ Intelligently merged path/to/file
- If no:
  - Ask: "What would you prefer?" and cycle back to options (keep HEAD, keep incoming, etc.)

**If "Skip for now":**
- Message: ⏭️ Skipped path/to/file, will resolve later
- Add to skipped files list
- Continue to next file

### 4. Track Progress

After each file resolution, display:
```
[X/Y] ✅ Resolved: path/to/file [METHOD]
```

Keep a running count and list of:
- Resolved files (with method used)
- Skipped files (for later)

### 5. After All Files Processed

**Step 5a: Check for unresolved files**

Run:
```bash
git diff --name-only --diff-filter=U
```

If any files remain unresolved:
- Display: "X file(s) still have conflicts:"
- List them
- Ask user:
  1. Continue resolving remaining files
  2. Abort and start over
  3. Leave them and continue merge/rebase (not recommended)

**Step 5b: Summary**

Display summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Conflict Resolution Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files Resolved: X
├── Kept HEAD: X
├── Kept Incoming: X
├── Merged Both: X
└── Intelligently Merged: X

Files Skipped: X
```

**Step 5c: Verify all conflicts resolved**

Run:
```bash
git status
```

Verify output shows no more "both modified" conflicts.

**Step 5d: Guide next step**

Check what type of operation:
```bash
git status | grep -q "rebase" && echo "rebase" || echo "merge"
```

If in **rebase**:
```
Next step: git rebase --continue
```

If in **merge**:
```
Next step: git commit (or let git auto-commit the merge)
```

Display the command they should run next.

### 6. Error Handling

**File doesn't exist:**
- Skip file with warning: ⚠️ File not found: path/to/file
- Continue to next file

**File is too large (>10000 lines):**
- Show first conflict section only
- Warn: ⚠️ Large file - showing conflict section only
- Proceed with resolution

**Conflict markers malformed:**
- Warning: ⚠️ Conflict markers appear malformed
- Show raw content and ask user to manually resolve
- Offer to skip

**Git command fails:**
- Display error message
- Ask if user wants to abort, skip file, or retry

## Important Notes

- **Always confirm** destructive actions (Keep HEAD, Keep Incoming)
- **Show context** so user understands the changes
- **Be intelligent** about merging - don't just concatenate
- **Track skipped files** and offer to resolve later
- **Verify** each resolution worked before moving on
- **Be safe** - stage files as they're resolved

## Example Full Interaction

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Detected 2 conflicting files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Starting interactive resolution...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[File 1 of 2] README.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Context: Documentation update for dev scripts

HEAD VERSION (Your changes):
npm run dev:api    # API server (port 3000)
npm run dev:web    # Web client (port 3001)

INCOMING VERSION (Their changes):
npm run dev        # Combined dev server (port 3000)

What would you like to do?
1. Keep HEAD - use your updated command names
2. Keep Incoming - use original combined names
3. Keep Both - include both versions
4. Manual Merge - let Claude intelligently merge
5. Skip for now

[User selects: 1]

This will discard changes from the incoming version. Continue? (yes/no)
[User confirms: yes]

✅ Kept HEAD version for README.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[File 2 of 2] package.json
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Context: Configuration conflict in dev scripts

HEAD VERSION (Your changes):
"dev:api": "npm run dev -w @myapp/api",
"dev:web": "npm run dev -w @myapp/web",

INCOMING VERSION (Their changes):
"dev": "npm run dev -w @myapp/combined",

What would you like to do?
1. Keep HEAD
2. Keep Incoming
3. Keep Both
4. Manual Merge
5. Skip for now

[User selects: 4]

📝 Proposed intelligent merge:

Both sides add new scripts. HEAD reorganizes into separate commands while incoming keeps combined.
Recommendation: Use HEAD version since it's the more recent refactoring.

Accept this merge? (yes/no)
[User confirms: yes]

✅ Intelligently merged package.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Conflict Resolution Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files Resolved: 2
├── Kept HEAD: 1
├── Kept Incoming: 0
├── Merged Both: 0
└── Intelligently Merged: 1

Files Skipped: 0

Next step: git rebase --continue
```
