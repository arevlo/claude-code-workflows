---
description: Pre-CI gate. Audits the repo, scaffolds integration tests if none exist, runs the full local check ladder (typecheck → lint → build → integration → smoke → e2e), and loops fix-and-rerun until everything is green. Smoke tests use agent-browser against a real dev server, not JSDOM. Use before pushing or opening a PR — when the user says "make sure CI passes", "set up tests for this repo", "test and fix", "verify before push", "get this green", or just `/test-and-fix`. Different from `/dev:test` (a runner) and `/dev:ci-fix` (post-CI). This is the gate between "I'm done coding" and "I push".
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, AskUserQuestion, Agent
---

# test-and-fix

Pre-CI verification gate. Catches the failures CI would have caught — but locally, before push, with the fix-and-rerun loop wired in.

The job has three phases that always run in this order:

1. **Audit** the repo to learn what tests exist and what doesn't.
2. **Scaffold** integration tests + a smoke harness if the repo has none.
3. **Run-and-fix** the full local check ladder. Loop until every step is green or the user stops you.

This skill is intentionally generic — it should work on a fresh repo or a mature one. Don't assume React/Next/Node. Detect the stack and adapt.

### Two kinds of tests, two different layers

This skill draws a hard line between smoke and integration. Don't blur it.

| Layer | Tool | What it asserts |
|-------|------|-----------------|
| **Smoke** | `agent-browser` against the running dev server (via the existing `dev:test-smoke` skill) | Pages render, no console errors, no HTTP errors, dark+light look right. **Does not import any source.** |
| **Integration** | Project test runner (vitest / jest / pytest / go test) | One critical flow crosses a real boundary — DB, HTTP, auth, multi-component handler. |

Unit tests for pure utility functions are **out of scope**. This skill is about CI confidence, not coverage.

---

## Phase 1 — Audit

Run these in parallel; do not ask anything yet.

```bash
# Stack signals
test -f package.json && cat package.json | head -50
test -f pnpm-lock.yaml && echo PKG=pnpm
test -f yarn.lock && echo PKG=yarn
test -f package-lock.json && echo PKG=npm
test -f pyproject.toml && echo PY=poetry-or-uv
test -f requirements.txt && echo PY=pip
test -f Cargo.toml && echo RUST=yes
test -f go.mod && echo GO=yes

# Test infrastructure
ls vitest.config* jest.config* playwright.config* cypress.config* 2>/dev/null
ls pytest.ini conftest.py tox.ini 2>/dev/null
grep -E '"(test|vitest|jest|playwright|cypress|pytest)"' package.json 2>/dev/null

# Existing test files
find . \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" -o -name "*_test.go" \) \
  -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/dist/*" -not -path "*/build/*" \
  | head -50

# Dev server signals (does smoke have something to talk to?)
grep -E '"(dev|start|serve)"' package.json 2>/dev/null
ls vite.config* next.config* astro.config* nuxt.config* svelte.config* 2>/dev/null

# CI configuration
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null

# Build / lint scripts available
grep -E '"(build|lint|typecheck|type-check|tsc|format)"' package.json 2>/dev/null

# Is agent-browser installed for smoke?
which agent-browser 2>/dev/null && agent-browser --version 2>/dev/null
```

Then **classify** what you found into one of three states. The classification drives Phase 2.

| State | Meaning |
|-------|---------|
| **green-field** | No test runner installed AND no test files. Scaffold from scratch. |
| **partial** | Runner installed but few/no tests, OR tests exist but typecheck/lint scripts missing from package.json, OR no `dev` script (smoke is impossible). |
| **mature** | Runner + tests + lint + typecheck + build + dev script all present. Skip scaffolding. |

Tell the user what you found in 3-5 lines. Lead with the verdict:

```
Audit:
- Stack: Next.js 14 + TypeScript (pnpm)
- Tests: 0 files, no runner installed
- Dev server: `pnpm dev` on :3000
- agent-browser: installed
- Verdict: green-field — recommend integration scaffold + agent-browser smoke harness
```

---

## Phase 2 — Decide

Branch on the classification.

### green-field

**Scaffold the minimum that gives CI value, not full coverage.** The bar is "would catch the bugs that block a deploy" — not "100% of code paths."

The minimum:

- A test runner config (vitest > jest for new JS/TS projects; pytest for Python; cargo test built-in for Rust; go test built-in for Go)
- One **integration test** for the critical flow — the one whose breakage would be a P0 incident. If you cannot identify that flow without guessing, **ask the user**. A wrong-but-plausible integration test is worse than none.
- A `test` script in `package.json` (or equivalent) so CI can call it
- A `smoke` script that runs `dev:test-smoke` against the running dev server (see "Smoke harness" below)

Propose the scaffold via AskUserQuestion before writing anything. Show:
- What deps you'd install
- What configs you'd create
- The integration test you intend to write (one-line description)
- Whether agent-browser is already installed (it should be, for smoke)

Wait for approval. Then go to Phase 3.

### partial

Identify the gap and offer to fill it. The common partial cases:

- **Runner exists, no tests** → write 1 integration test for the critical flow (ask if unclear).
- **Runner + tests, no smoke harness** → wire up `dev:test-smoke` as a `pnpm smoke` script.
- **Tests exist, no typecheck/lint/build script** → add the missing scripts to `package.json` so CI has something to call.

Don't ask if the gap is obvious; just do it and report.

### mature

Skip Phase 3. Go straight to Phase 4.

---

## Phase 3 — Scaffold (only if Phase 2 said so)

### 3a. Integration test runner

For a JS/TS project, install vitest:

```bash
pnpm add -D vitest
# Add jsdom only if any integration test renders React; most don't need it.
```

Minimal config — borrow path aliases from `tsconfig.json` if present:

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
export default defineConfig({
  test: { environment: 'node', globals: true },
  resolve: { alias: { '@': '/src' } },
});
```

For Python:

```bash
pip install -U pytest pytest-asyncio   # or: uv add --dev pytest pytest-asyncio
```

Adapt for other stacks. Don't install anything heavier than the runner unless a specific test needs it.

### 3b. The first integration test

Pick one critical flow. Examples by stack:

```ts
// API route — hits the handler, asserts status + shape
import { GET } from '@/app/api/health/route';
test('GET /api/health returns ok', async () => {
  const res = await GET();
  expect(res.status).toBe(200);
  expect(await res.json()).toMatchObject({ ok: true });
});
```

```ts
// Server action — calls it with valid input, mocks DB
import { createTodo } from '@/app/actions/todos';
import { vi } from 'vitest';
vi.mock('@/lib/db', () => ({ db: { todos: { create: vi.fn().mockResolvedValue({ id: '1' }) } } }));
test('createTodo persists and returns the new row', async () => {
  const result = await createTodo({ title: 'test' });
  expect(result.id).toBe('1');
});
```

```py
# pytest — call the FastAPI route via its TestClient
from fastapi.testclient import TestClient
from app.main import app
def test_health_returns_200():
    res = TestClient(app).get("/health")
    assert res.status_code == 200
    assert res.json() == {"ok": True}
```

**Do not write more than one integration test in this pass.** The point of the scaffold is to give CI something graded — not to ship coverage.

### 3c. Smoke harness — delegate to dev:test-smoke

Don't reimplement smoke. The `dev:test-smoke` skill already drives `agent-browser` against a running app, checks console + HTTP errors, captures dark/light renders, and reports issues.

Wire it up so CI / the user can invoke it with one command. Add to `package.json`:

```json
"scripts": {
  "smoke": "echo 'Run /dev:test-smoke after starting the dev server with: pnpm dev'"
}
```

(The smoke step in Phase 4 invokes the skill directly — the script just exists as documentation.)

If `agent-browser` is missing on the system, surface that to the user and stop the scaffold step until it's installed:

```bash
agent-browser --version 2>/dev/null \
  || echo "agent-browser not on PATH — install it before running smoke."
```

### 3d. Test scripts

Add to `package.json` (preserving anything that already exists):

```json
"scripts": {
  "test": "vitest run",
  "test:watch": "vitest",
  "typecheck": "tsc --noEmit"
}
```

If lint/eslint isn't already configured, **don't add a lint script** — adding `eslint` is its own discussion and dragging it in here will surprise the user.

### 3e. Don't go further

No coverage chasing. No utility tests. No "while we're here, let me also …" — the scaffold is a starter so CI has something to grade. The user adds breadth later.

---

## Phase 4 — Run the local check ladder

Run these in order. **Stop at the first failure** and go to Phase 5; don't continue running later steps with earlier ones broken.

```bash
# 1. Type safety
pnpm typecheck 2>&1 || npm run typecheck 2>&1 || pnpm exec tsc --noEmit 2>&1

# 2. Lint (skip silently if no script configured)
pnpm lint 2>&1 || npm run lint 2>&1

# 3. Build
pnpm build 2>&1 || npm run build 2>&1

# 4. Integration tests
pnpm test 2>&1 || npm run test 2>&1

# 5. Smoke — invoke dev:test-smoke, NOT a JSDOM render
#    Start the dev server in the background, wait for ready, then:
#      "Use the dev:test-smoke skill to smoke-test the running app at <URL>."
#    (Do not paste agent-browser commands inline; the skill handles browsing,
#     screenshotting, and reporting.)

# 6. E2E (only if playwright config exists)
[ -f playwright.config.ts ] && pnpm exec playwright test 2>&1
```

Notes on the smoke step:
- Start the dev server with `pnpm dev` (or detected equivalent) using `run_in_background: true`. Use the Monitor tool to wait for the "ready on http://localhost:NNNN" line.
- Then invoke `dev:test-smoke` with the detected URL.
- When the smoke pass finishes, kill the dev server.

If a step is missing from the project (e.g. no `lint` script), skip it and note it in the final report — don't fail just because a script doesn't exist.

After all steps pass, go to Phase 6.

---

## Phase 5 — Fix loop

The heart of the skill. For each failure:

1. **Read the error.** Don't guess — read the actual output and the file/line it points at.
2. **Decide: is the test wrong or the implementation wrong?** A failing test is not automatically a bug to fix in the code; it might encode stale expectations from a recent refactor.
3. **Apply the fix.** Smallest change that addresses the root cause. No drive-by refactors.
4. **Re-run only the failing step**, not the whole ladder. Re-run the full ladder when the original failing step is green.
5. **Loop** until that step passes, or stop and ask the user if you've tried twice without progress.

Different layers fail for different reasons — fix in this order:

| Order | Category | Where it usually points | Typical fix |
|-------|----------|-------------------------|-------------|
| 1 | Type/interface mismatch | `tsc` output | Update the type, then chase fallout in mocks/test harnesses |
| 2 | Build error | bundler output | Fix syntax/import/path issues |
| 3 | Lint | eslint/ruff output | Fix the code; do not disable the rule |
| 4 | Integration assertion | vitest/pytest output | Decide stale-test vs. real regression — fix accordingly |
| 5 | **Smoke (agent-browser)** | screenshots + console | Whitespace/contrast → CSS; runtime errors → JS; network errors → API/route handler |
| 6 | E2E timeout / missing element | playwright trace | Update fixture or selector to match new render conditions |
| 7 | Formatting | prettier output | Run the project's formatter |

### Smoke failures specifically

When `dev:test-smoke` reports issues, they fall into 3 buckets:
- **HTTP error** (page returned 4xx/5xx) → check the route handler / page file the URL maps to. If it's a server error, read the logs. If it's a 404, the page file may have been renamed and a link not updated.
- **Console error** in the browser → open the screenshot, find the offending render, search the codebase for the error string.
- **Visual / contrast issue** (dark mode regression, white-on-white) → CSS, almost always a missing data-theme override or a hardcoded color.

**Don't "fix" smoke failures by deleting the page from the smoke list.** That is hiding a real regression. Fix the page or escalate to the user.

### When to stop and ask

Report each fix as you go in one line:

```
fix: src/lib/foo.ts — replaced removed import; typecheck step retrying...
```

If you find yourself patching tests rather than code more than twice in a row, **pause and ask the user**: "Tests look like they encode stale expectations from a recent refactor — keep updating tests, or is this a regression I should reverse in the code?"

If you've tried two different fixes for the same failure and neither worked, **stop and ask** — don't try a third blind.

---

## Phase 6 — Final report

When the full ladder is green:

```
## Pre-CI gate: PASS

Stack:      Next.js 14 + TypeScript (pnpm)
Scaffolded: vitest + 1 integration test, smoke harness via dev:test-smoke
Ladder:
  ✓ typecheck       2.1s
  ✓ lint            1.4s
  ✓ build           18.7s
  ✓ test            5/5 passed (212ms)
  ✓ smoke           7 pages, 0 console errors, 0 HTTP errors
  ✓ e2e             skipped (no playwright config)

Fixes applied (3):
  - src/lib/router.ts                 — removed unused import
  - tsconfig.json                     — added missing path alias
  - src/components/Header.tsx         — fixed dark-mode contrast on /pricing

You're safe to push.
Next pass to consider: integration tests for `auth/sign-in` and `checkout/submit`.
```

If you stopped early, be honest about what's still red and what the user should look at.

---

## Operating rules

- **Don't run formatter or `lint --fix` without showing diffs first.** Auto-formatting can hide bigger issues.
- **Don't `npm install` without telling the user.** Always show what you're adding before it lands in package.json.
- **Don't invent test scenarios.** If you don't know what the critical flow is, ask. A wrong-but-plausible integration test is worse than no test.
- **Smoke is agent-browser, not JSDOM.** Render-in-JSDOM tests are shallow component tests, not smoke. Don't scaffold them in this skill.
- **Stop at twice-failed-the-same-way.** Two failed attempts at the same root cause means you're missing context — ask the user instead of trying again.
- **Never suppress test output.** Show it. The user often spots something you missed.
- **The scaffold is a starter, not a finish line.** End the report with a one-line nudge toward what to add next, but don't add it in this run unless asked.
