---
description: Run, scaffold, or audit tests for any project. Routes to the right mode based on the argument: `unit` runs unit/integration tests, `smoke` runs visual smoke tests, `e2e` runs Playwright end-to-end tests, `setup` analyzes the repo and scaffolds missing test infrastructure. With no argument, auto-detects what tests exist and runs them. Use when the user says "run tests", "run unit tests", "set up tests", "add tests", "check test coverage", "smoke test", "e2e tests", "test the app", or any variant of testing, verifying, or quality-checking the codebase.
allowed-tools: Bash,Read,Glob,Grep,AskUserQuestion,Agent
---

# dev:test

Unified test runner and scaffolding skill. Handles unit, smoke, and e2e testing — and analyzes the repo to set up test infrastructure when none exists.

## Mode selection

The user invokes this as `/dev:test`, `/dev:test:unit`, `/dev:test:smoke`, or `/dev:test:e2e`. Read the argument after the colon (if any) to pick the mode. When no argument is given, **auto-detect** the right mode.

```
/dev:test           → auto-detect
/dev:test:unit      → unit mode
/dev:test:smoke     → smoke mode  
/dev:test:e2e       → e2e mode
/dev:test:setup     → setup mode (always analyze + scaffold)
```

---

## Step 1 — Detect test infrastructure

Run this before deciding anything. Takes ~5 seconds and answers all routing questions.

```bash
# Test runners
HAS_VITEST=$([ -f vitest.config.ts ] || [ -f vitest.config.js ] && echo yes || echo no)
HAS_JEST=$(grep -q '"jest"' package.json 2>/dev/null && echo yes || echo no)
HAS_PLAYWRIGHT=$([ -f playwright.config.ts ] || [ -f playwright.config.js ] && echo yes || echo no)

# Existing test files
TEST_COUNT=$(find . -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" | grep -v node_modules | wc -l | tr -d ' ')

# Test scripts in package.json
grep -E '"test|e2e|playwright|vitest|jest"' package.json 2>/dev/null | head -10

echo "vitest=$HAS_VITEST jest=$HAS_JEST playwright=$HAS_PLAYWRIGHT test_files=$TEST_COUNT"
```

Use this to decide:
- **No test runner + 0 test files** → offer to run `setup` mode first
- **Runner exists + test files** → `unit` mode can run right away
- **Playwright config exists** → `e2e` mode is available

---

## Auto-detect (no argument)

Check what exists, then:

1. If unit tests exist → run them (unit mode)
2. If playwright exists → run e2e after unit
3. If a dev server is running → offer a smoke test
4. If nothing exists → ask the user which mode they want, with "setup" as the recommendation

---

## Unit mode

Run the project's unit/integration tests and report results.

### 1. Find and run tests

```bash
# Detect the right command
if grep -q '"test"' package.json; then
  pnpm test 2>&1          # or npm test / yarn test
elif [ -f vitest.config.ts ]; then
  pnpm vitest run 2>&1
elif [ -f jest.config.ts ] || [ -f jest.config.js ]; then
  pnpm jest 2>&1
fi
```

### 2. Parse results

Look for:
- Total tests, passed, failed, skipped
- Which files failed
- Error messages for failed tests

### 3. Report

```
## Unit test results

| Suite | Tests | Status |
|-------|-------|--------|
| lib/utils    | 8/8   | ✅ |
| lib/validation | 12/12 | ✅ |

**Total: 42 passed · 0 failed · 210ms**
```

If any tests fail, show the error output and offer to investigate.

---

## Smoke mode

Delegates to the full `dev:test-smoke` skill for visual page-by-page verification. Invoke it:

```
Use the dev:test-smoke skill to run a visual smoke test.
```

---

## E2E mode

Run Playwright end-to-end tests.

### 1. Check Playwright is installed

```bash
npx playwright --version 2>/dev/null || echo "not installed"
```

If not installed, ask the user before running `pnpm add -D @playwright/test && npx playwright install`.

### 2. Run tests

```bash
pnpm exec playwright test 2>&1
# or: npx playwright test --reporter=list
```

### 3. On failure

If tests fail, check `playwright-report/` for the HTML report:

```bash
ls playwright-report/ 2>/dev/null && open playwright-report/index.html
```

Report which tests failed, the error, and the test file + line number.

---

## Setup mode

This is the "first time" path — analyze the repo, identify gaps, scaffold what's needed. This is the most important mode to do well.

### Phase 1: Audit the repo

Run these checks in parallel and build a picture of what's testable and what's missing.

```bash
# 1. What test infrastructure exists?
ls vitest.config* jest.config* playwright.config* 2>/dev/null
grep -E '"test|vitest|jest|playwright"' package.json | head -10

# 2. What test files already exist?
find . -name "*.test.*" -o -name "*.spec.*" | grep -v node_modules | sort

# 3. What pure functions / utilities exist?
find lib/ utils/ -name "*.ts" | grep -v node_modules | grep -v "__tests__" | sort 2>/dev/null

# 4. What components exist?
find components/ -name "*.tsx" | grep -v node_modules | sort 2>/dev/null

# 5. What Zod schemas / validation exists?
grep -rl "z\." lib/ --include="*.ts" 2>/dev/null

# 6. What API routes exist?
find app/api -name "route.ts" 2>/dev/null | sort

# 7. What does the tech stack look like?
grep -E '"react|"next|"vue|"nuxt|"svelte|"express|"fastify|"hono"' package.json | head -10
```

### Phase 2: Identify what's testable

After auditing, classify what you found into:

**High value, easy to test (start here):**
- Pure functions (no external deps) — `lib/utils/`, schema validators, URL helpers, date formatters, error decoders
- Zod schemas — parse valid/invalid inputs, edge cases
- Business logic — pricing rules, state machines, permission checks

**Medium value (needs mocking or DOM):**
- React components with props — render, interact, assert on output
- Custom hooks — `renderHook` from testing-library
- Server actions — mock the DB layer

**Blocked until infrastructure exists:**
- Database queries
- External API calls
- Auth flows

### Phase 3: Recommend a test stack

Based on the project's tech stack, recommend the right tools. For a Next.js / React project:

```
Unit + component tests:   vitest + @testing-library/react
E2E:                      Playwright (when routes stabilize)
Visual regression:        dev:test-smoke (already available)
```

For other stacks, adapt:
- Plain Node / Express → vitest or jest alone (no jsdom needed)
- Vue → vitest + @testing-library/vue
- Python → pytest

### Phase 4: Scaffold

Ask the user which pieces to install and create:

```
Based on the audit, here's what I recommend:

✅ Already have: [list]
📦 Install:     vitest @vitejs/plugin-react (or equivalent)
📁 Create:      vitest.config.ts, add "test" script to package.json
🧪 Write tests for: [top 3 highest-value modules]

Shall I scaffold all of this? (yes/just config/just first tests)
```

Then:

1. **Install deps** — `pnpm add -D vitest ...`
2. **Create config** — minimal `vitest.config.ts` with path aliases from tsconfig
3. **Add test script** to `package.json`
4. **Write the first tests** — start with the highest-value pure functions
5. **Run them** — verify everything passes before declaring done

### Phase 5: First run

After scaffolding, always run the tests to confirm they pass:

```bash
pnpm test
```

Report the results. If anything fails, diagnose and fix before finishing.

---

## Reporting

End every mode with a summary:

```
## Test summary

Mode: unit
Runner: vitest 4.x
Files: 7
Tests: 121 passed · 0 failed
Duration: 184ms

Next: add component tests for Button, Header
```

For setup mode, also include a "what was created" list and what to tackle next.

---

## Tips

- **Don't re-run if tests are already green** — check if the user just wants a status, not a rerun.
- **Failing tests are findings, not blockers** — report them clearly and offer to investigate, but don't spiral into debugging unless asked.
- **Setup mode is not a one-shot** — scaffold the foundation, write the first batch of tests, then stop. Don't try to achieve full coverage in one pass.
- **Watch mode** — if the user says "keep running" or "watch mode", run `vitest` (without `run`) and monitor with the Monitor tool.
