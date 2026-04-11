---
description: Use for 'fix CI failures', 'fix failing checks', 'fix CI', 'resolve GitHub Actions failures', 'CI is red', 'build is broken', 'tests are failing in CI'. Fetches failing CI check logs from the current PR, identifies errors, fixes them locally, verifies with local builds/tests, and pushes. Loops until all checks pass.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

# Fix CI Failures

Fetch failing CI logs from the current PR, diagnose errors, fix locally, verify, push, and loop until green.

## Step 1 — Get PR and failing checks

```bash
gh pr view --json number,url,headRefName -q '{number,url,headRefName}'
```

If no PR exists, inform the user and stop.

Then fetch all check statuses:

```bash
gh pr checks <number> --json name,state,workflow,link
```

Filter to checks where `state` is `FAILURE`. If none are failing, tell the user "All checks passing" and stop.

Present the failing checks to the user.

## Step 2 — Fetch failed logs

For each failing check, extract the run ID from its `link` field (the number after `/runs/`). Multiple jobs can share a run ID — deduplicate before fetching.

```bash
gh run view <run_id> --log-failed 2>&1
```

The output is tab-separated: `<job>\t<step>\t<log line>`. Focus on:
- Lines containing `Error`, `error`, `FAIL`, `Failed`, `##[error]`
- The 5-10 lines before each error for context
- Compiler/linter output with file paths and line numbers
- Type errors with "is not assignable to type" or "Property X is missing in type"

If logs are very long (>500 lines), extract just the error-relevant sections.

## Step 3 — Diagnose and categorize

Group errors by type. Common categories:

| Type | Examples |
|------|----------|
| **Build / Type** | TypeScript errors, missing properties in types/interfaces |
| **Lint** | ESLint violations, unused variables, unknown CSS vars |
| **Test (unit)** | Assertion failures, wrong expected values |
| **Test (component/e2e)** | Timeout clicking elements, missing UI elements |
| **Test (mock/harness)** | Type mismatches in test mocks or harnesses |
| **Prettier** | Formatting violations |

For each error, identify:
1. The file and line number
2. The error message
3. The root cause (read the file to understand context)

**Critical: trace the full impact of your changes.** When you changed a type, interface, or behavior:
- Search for test harnesses and mocks that implement the changed interface
- Search for component/integration tests that rely on the changed behavior
- Check `.testharness.tsx`, `.test.tsx`, `.spec.tsx`, and `__mocks__/` files

Present a summary to the user before fixing.

## Step 4 — Fix errors

Apply fixes in dependency order: types/interfaces first, then build errors, then test mocks/harnesses, then test assertions, then formatting.

### Type and interface errors
- If a type was expanded (new required field), update all mocks and test harnesses that implement it
- Search the codebase: `grep -r "InterfaceName" --include="*.test.*" --include="*.testharness.*" --include="*.spec.*"`

### Test assertion failures
- Read the test to understand what it asserts
- Determine if the test expectation is wrong (due to intentional behavior change) or the code is wrong
- If behavior changed intentionally, update the test expectation and add a comment explaining why
- If the code is wrong, fix the code

### Component/E2E test timeouts
These usually mean a UI element the test expects is no longer rendered. Common causes:
- A component was conditionally rendered based on new logic (e.g., gated behind a prop)
- The test fixture doesn't provide the right props for the new conditional
- Fix by updating the test fixture to match the new rendering conditions

### Lint errors
- Unused variables: remove the variable declaration
- Unknown CSS vars: search for the correct variable in the design system's variables.css
- ESLint rule violations: fix the code to comply, don't disable the rule

### Prettier
- Run the workspace's prettier fix command (e.g., `yarn prettier:fix`)

After applying each fix, report what you changed and why.

## Step 5 — Verify locally

Run the same checks locally that failed in CI. Discover the correct commands from `package.json` scripts in each workspace.

Common patterns:
```bash
# Build
yarn build              # or yarn workspace <name> build

# Lint / Type check
yarn lint               # ESLint
yarn lint:tsc           # TypeScript type checking
yarn type-check         # Alternative name

# Tests
yarn test <file>        # Specific test file
yarn test:vitest        # Vitest runner
yarn test:component     # Playwright component tests

# Formatting
yarn prettier:fix       # Fix prettier violations
```

If local verification fails, go back to Step 4 and iterate. Don't push until local checks pass.

**Note:** Some projects may have environment-specific issues (missing dependencies, storybook config) that prevent local runs. If local verification isn't possible, ensure your fixes are correct by reading the code carefully, then push and let CI verify.

## Step 6 — Commit and push

Stage only the files you changed:

```bash
git add <files>
git commit -m "fix: <concise description of CI fixes>"
git push origin <branch>
```

## Step 7 — Monitor and loop

After pushing, check if new CI runs have started:

```bash
gh pr checks <number> --json name,state,workflow
```

Report what was fixed and what's still running. Ask: "Want me to wait and check results, or are we done for now?"

If the user wants to wait, poll periodically:

```bash
gh pr checks <number> --json name,state --jq '.[] | select(.state == "FAILURE" or .state == "IN_PROGRESS") | {name, state}'
```

**If new failures appear, go back to Step 2 and repeat the full cycle.** Each iteration should fix all failures — don't leave known issues for the next round.

## Step 8 — Summary

When all checks pass (or the user decides to stop):

```
CI Status: All checks passing
Fixes applied:
- file.tsx: description of fix
- file.test.tsx: updated test expectation
Commits: abc1234, def5678
```
