---
description: Interactive fix mode - address swarm findings one by one
allowed-tools: Bash,Read,Write,Edit,AskUserQuestion,Glob,Grep
---

Fix issues found by swarm agents. Choose between manual mode (one at a time) or automatic mode (fix all).

## Usage

```
/fix [--critical] [--file <path>] [--agent <name>] [--auto]
```

**Arguments:**
- `--critical` - Only show P0/HIGH priority issues (default)
- `--file <path>` - Only show issues in specific file
- `--agent <name>` - Only show issues from specific agent
- `--auto` - Skip mode selection and run automatic mode directly

## Steps:

1. **Load swarm findings:**
   - Read all reports from `.claude/swarm/reports/`
   - Parse issues and sort by priority (P0/HIGH first)
   - Filter based on arguments if provided

2. **Build issue queue:**
   ```
   Issue queue (6 total):
   1. [P0] main.ts:56-57 - Unhandled async message handler
   2. [P0] collector.ts:225 - Page load failures in global mode
   3. [P0] index.ts:6-19 - DOM elements without null checks
   4. [HIGH] main.ts:44-46 - Unsafe SceneNode assertion
   5. [HIGH] collector.ts:147 - Untyped boundVariables cast
   6. [HIGH] index.ts:206 - No runtime validation for messages
   ```

3. **Ask for fix mode (unless --auto flag provided):**

   Use AskUserQuestion tool:
   ```json
   {
     "questions": [{
       "question": "How would you like to fix these 6 issues?",
       "header": "Fix Mode",
       "options": [
         {"label": "Manual (Recommended)", "description": "Review and fix issues one at a time with options to skip"},
         {"label": "Automatic", "description": "Fix all issues automatically, show summary at end"}
       ],
       "multiSelect": false
     }]
   }
   ```

   **If "Manual":** Continue to step 4 (interactive mode)
   **If "Automatic":** Jump to step 8 (automatic mode)

4. **[MANUAL MODE] Present first issue:**
   ```
   ┌─────────────────────────────────────────────────────────┐
   │  ISSUE 1/6 [P0]                                         │
   │                                                         │
   │  Unhandled async message handler                        │
   │  File: main.ts:56-57                                    │
   │  Agent: silent-hunter                                   │
   │                                                         │
   │  Problem:                                               │
   │  Async handler lacks try/catch. Errors will silently   │
   │  fail and break message flow.                          │
   │                                                         │
   │  Current code:                                          │
   │  ```typescript                                          │
   │  onmessage = async (msg) => {                          │
   │    await processMessage(msg);                          │
   │  }                                                      │
   │  ```                                                    │
   └─────────────────────────────────────────────────────────┘
   ```

5. **[MANUAL MODE] Ask user how to proceed:**

   Use AskUserQuestion tool:
   ```json
   {
     "questions": [{
       "question": "How would you like to handle this issue?",
       "header": "Action",
       "options": [
         {"label": "Fix it (Recommended)", "description": "Claude will implement the fix and show you the diff"},
         {"label": "Skip", "description": "Move to next issue without fixing"},
         {"label": "View file", "description": "Open and read the file for more context"},
         {"label": "Exit fix mode", "description": "Stop fixing, return to normal mode"}
       ],
       "multiSelect": false
     }]
   }
   ```

6. **[MANUAL MODE] Based on response:**

   **If "Fix it":**
   - Read the file at the specified location
   - Analyze the issue in context
   - Implement the fix using Edit tool
   - Show the diff:
     ```
     Fixed: main.ts:56-57

     - onmessage = async (msg) => {
     -   await processMessage(msg);
     - }
     + onmessage = async (msg) => {
     +   try {
     +     await processMessage(msg);
     +   } catch (error) {
     +     console.error('Message handler error:', error);
     +     figma.notify('Error processing message', { error: true });
     +   }
     + }

     [1/6 complete] Next issue? [Y/n]
     ```
   - Move to next issue

   **If "Skip":**
   - Move to next issue without changes
   - Track skipped issues for summary

   **If "View file":**
   - Read and display the file around the issue location
   - Re-ask the action question

   **If "Exit fix mode":**
   - Show summary of completed/skipped issues
   - Exit command

7. **[MANUAL MODE] Continue until queue empty or user exits**

---

## Automatic Mode

8. **[AUTOMATIC MODE] Process all issues:**

   When automatic mode is selected (or `--auto` flag used):

   ```
   ┌─────────────────────────────────────────────────────────┐
   │  AUTOMATIC FIX MODE                                     │
   │                                                         │
   │  Processing 6 issues...                                 │
   └─────────────────────────────────────────────────────────┘
   ```

   For each issue in the queue:
   - Display brief progress: `[1/6] Fixing: main.ts:56-57 - Unhandled async...`
   - Read the file at the specified location
   - Analyze the issue in context
   - Implement the fix using Edit tool
   - Track success/failure for each issue
   - Continue to next issue immediately (no user prompts)

   During processing, show progress updates:
   ```
   [1/6] ✓ Fixed: main.ts:56-57 - Unhandled async message handler
   [2/6] ✓ Fixed: collector.ts:225 - Page load failures in global mode
   [3/6] ✗ Failed: index.ts:6-19 - Could not determine safe fix
   [4/6] ✓ Fixed: main.ts:44-46 - Unsafe SceneNode assertion
   [5/6] ✓ Fixed: collector.ts:147 - Untyped boundVariables cast
   [6/6] ✓ Fixed: index.ts:206 - No runtime validation for messages
   ```

   **Handling failures:**
   - If a fix cannot be safely applied, mark as failed and continue
   - Track failed issues separately for manual review
   - Don't stop on errors - complete the entire queue

---

## Completion Summary

9. **Show completion summary:**

   **Manual mode summary:**
   ```
   ┌─────────────────────────────────────────────────────────┐
   │  FIX MODE COMPLETE (Manual)                             │
   │                                                         │
   │  Fixed: 4 issues                                        │
   │  Skipped: 2 issues                                      │
   │                                                         │
   │  Files modified:                                        │
   │  - main.ts (2 fixes)                                    │
   │  - collector.ts (1 fix)                                 │
   │  - index.ts (1 fix)                                     │
   │                                                         │
   │  Skipped issues saved to:                               │
   │  .claude/swarm/skipped.md                               │
   │                                                         │
   │  Run tests to verify fixes: npm test                    │
   └─────────────────────────────────────────────────────────┘
   ```

   **Automatic mode summary:**
   ```
   ┌─────────────────────────────────────────────────────────┐
   │  FIX MODE COMPLETE (Automatic)                          │
   │                                                         │
   │  ✓ Fixed: 5 issues                                      │
   │  ✗ Failed: 1 issue                                      │
   │                                                         │
   │  Files modified:                                        │
   │  - main.ts (2 fixes)                                    │
   │  - collector.ts (2 fixes)                               │
   │  - index.ts (1 fix)                                     │
   │                                                         │
   │  Failed issues (require manual review):                 │
   │  - index.ts:6-19 - DOM elements without null checks     │
   │    Reason: Multiple DOM operations, unclear scope       │
   │                                                         │
   │  Failed issues saved to:                                │
   │  .claude/swarm/failed.md                                │
   │                                                         │
   │  Run tests to verify fixes: npm test                    │
   └─────────────────────────────────────────────────────────┘
   ```

## Fix Strategies by Issue Type

### Unhandled async (silent-hunter)
- Wrap in try/catch
- Add appropriate error handling (log, notify, rethrow)
- Consider error boundaries for React components

### Type issues (type-analyzer)
- Add explicit type annotations
- Replace `any` with proper types
- Add null checks where needed
- Use type guards for runtime validation

### Complexity (reviewer)
- Extract helper functions
- Simplify conditionals
- Break down large functions

### Missing null checks (silent-hunter)
- Add optional chaining (`?.`)
- Add nullish coalescing (`??`)
- Add explicit null checks with early returns

## When to Use Each Mode

**Manual mode** (recommended for most cases):
- First time running fix on a codebase
- When you want to understand each fix
- For complex issues that need careful review
- When learning what types of issues exist

**Automatic mode:**
- When you trust the agent findings and want to fix everything
- For well-understood codebases with standard patterns
- When time is limited and you'll review diffs in git later
- Run with `--auto` flag to skip the mode selection prompt

## Notes

- Fix mode reads issues from swarm reports
- All fixes are made using the Edit tool (shows diffs)
- Skipped issues (manual) saved to `.claude/swarm/skipped.md`
- Failed issues (auto) saved to `.claude/swarm/failed.md`
- After fixing, agents will re-analyze if in watch mode
- Run tests after completing fix mode to verify changes
