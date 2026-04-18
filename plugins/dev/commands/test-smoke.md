---
description: Visual smoke-test every page of a running web app using agent-browser. Checks dark/light mode rendering, console errors, HTTP errors, and contrast failures. Use when you want to "smoke test", "check all pages", "verify dark mode", "spot visual regressions", or QA the whole site quickly before a PR or deploy.
allowed-tools: Bash,Read,AskUserQuestion
---

# Smoke Test

Visually verify every page of a running web app. Catches white-pages-in-dark-mode, console errors, HTTP failures, and contrast bugs in one sweep.

## Overview

```
1. Detect URL        → find the dev server (or accept one)
2. Discover pages    → crawl nav links or use a provided list
3. Dark-mode pass    → screenshot + contrast + error check each page
4. Light-mode pass   → regression check that light mode still looks right
5. Report            → markdown table + inline issue list
```

---

## 1. Detect the base URL

Check if a dev server is already running on a common port:

```bash
for port in 3000 3001 4000 5173 8080 8000; do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/ --max-time 1 2>/dev/null)
  echo "$port: $code"
done
```

Also check `package.json` and `.env*` for a PORT override:

```bash
grep -hE "PORT|:3[0-9]{3}|:4[0-9]{3}|:5[0-9]{3}|:8[0-9]{3}" package.json .env.local .env 2>/dev/null | head -10
```

Pick the first port that returns 200. If none found, ask the user for the URL.

---

## 2. Discover pages

### Auto-discovery (default)

Navigate to the root and extract all unique internal paths from `<a>` tags:

```bash
agent-browser close --all 2>/dev/null
agent-browser open {BASE_URL}
agent-browser wait 1500
agent-browser eval "(() => { const seen = new Set(['/']); document.querySelectorAll('a[href]').forEach(a => { try { const u = new URL(a.href); if (u.origin === location.origin && u.pathname) seen.add(u.pathname.replace(/\/$/, '') || '/'); } catch {} }); return [...seen].sort(); })()"
```

Keep the list to **at most 20 paths**. If the crawl returns more, prioritise:
- `/` (home)
- Top-level nav links (depth 1)
- Any routes the user highlighted in their request

### User-provided list

If the user specified pages (e.g., "check /, /about, /sell"), use those exactly.

---

## 3. Setup

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUT=/tmp/smoke-$TIMESTAMP
mkdir -p $OUT/dark $OUT/light
echo "# Smoke test — $(date)" > $OUT/report.md
echo "Base URL: {BASE_URL}" >> $OUT/report.md
echo "" >> $OUT/report.md
```

---

## 4. Dark-mode pass

```bash
agent-browser close --all 2>/dev/null
agent-browser open {BASE_URL}
agent-browser set media dark
```

For **each page path** run the following block. Replace `{PATH}` and `{SLUG}` (path with `/` → `home`, `/about` → `about`):

### 4a. Navigate and screenshot

```bash
agent-browser open {BASE_URL}{PATH}
agent-browser wait 1500
agent-browser screenshot $OUT/dark/{SLUG}.png
```

### 4b. Console errors

```bash
agent-browser errors --clear 2>/dev/null
```

Note any errors — a non-empty result is a finding.

### 4c. Contrast check

Run this JS to detect near-white surfaces in dark mode (the most common dark-mode bug):

```bash
agent-browser eval "(() => {
  const candidates = [
    document.body,
    document.querySelector('main'),
    document.querySelector('[role=main]'),
    document.querySelector('#__next > div'),
    document.querySelector('#app > div'),
    document.querySelector('.page-wrapper'),
  ].filter(Boolean);
  return candidates.map(el => {
    const bg = getComputedStyle(el).backgroundColor;
    const m = bg.match(/[\d.]+/g);
    if (!m || m.length < 3) return null;
    const [r,g,b] = m.map(Number);
    const lum = (0.299*r + 0.587*g + 0.114*b) / 255;
    return { el: el.tagName + (el.id ? '#'+el.id : '') + (el.className ? '.'+[...el.classList].slice(0,2).join('.') : ''), bg, lum: +lum.toFixed(2) };
  }).filter(x => x && x.lum > 0.5);
})()"
```

**Interpretation:** Any result with `lum > 0.5` (50% brightness) is a surface that is staying light in dark mode — flag it as a contrast bug.

Also check for invisible text (very low contrast in dark mode):

```bash
agent-browser eval "(() => {
  const body = document.body;
  const bg = getComputedStyle(body).backgroundColor;
  const fg = getComputedStyle(body).color;
  const parse = c => { const m = c.match(/[\d.]+/g); return m ? m.map(Number) : null; };
  const lum = ([r,g,b]) => (0.299*r + 0.587*g + 0.114*b) / 255;
  const bgParsed = parse(bg), fgParsed = parse(fg);
  if (!bgParsed || !fgParsed) return 'could not parse';
  const contrast = Math.abs(lum(bgParsed) - lum(fgParsed));
  return { bg, fg, contrastDelta: +contrast.toFixed(2), ok: contrast > 0.3 };
})()"
```

**Interpretation:** `contrastDelta < 0.3` means the body text and background are too close — flag it.

### 4d. HTTP status

```bash
curl -s -o /dev/null -w "%{http_code}" {BASE_URL}{PATH} --max-time 5
```

Non-200 is a finding.

---

## 5. Light-mode pass

```bash
agent-browser set media light
```

Repeat steps 4a–4d for each page, saving to `$OUT/light/{SLUG}.png`.

For the light-mode contrast check, flip the logic: flag surfaces with `lum < 0.05` (near-black background in light mode) or `contrastDelta < 0.3`.

---

## 6. Report

Append to `$OUT/report.md` as you go (don't batch at the end — write findings immediately as you find them).

### Result table

```markdown
## Results

| Page | Dark BG | Dark Text | Dark Errors | Light BG | Light Text | Light Errors | HTTP |
|------|---------|-----------|-------------|----------|------------|--------------|------|
| /    | ✅      | ✅        | ✅          | ✅       | ✅         | ✅           | 200  |
| /sell| ⚠️ white card | ✅   | ✅          | ✅       | ✅         | ✅           | 200  |
```

Legend: ✅ pass · ⚠️ warning · ❌ fail

### Issues section

For each finding, append:

```markdown
## Issue N: <short title>

**Page:** /path
**Mode:** dark / light / both
**Type:** contrast · js-error · http-error · layout
**Severity:** critical / high / medium / low

**What's wrong:** one sentence.

**Evidence:** ![screenshot](dark/slug.png)

**Suggested fix:** one sentence if obvious, otherwise omit.
```

---

## 7. Wrap up

```bash
agent-browser close 2>/dev/null
echo "" >> $OUT/report.md
echo "---" >> $OUT/report.md
echo "Report saved to: $OUT/report.md" >> $OUT/report.md
```

Tell the user:
- How many pages were tested
- How many issues found (and severities)
- The output directory path
- Show the results table inline in the conversation

---

## Severity guide

| Level    | Example |
|----------|---------|
| Critical | Page is blank / white in dark mode, HTTP 404/500, body text invisible |
| High     | A content card is white in dark mode, nav links invisible |
| Medium   | Sub-text color too dim, icon fill doesn't adapt |
| Low      | Minor contrast difference, decorative element wrong shade |

---

## Tips

- **Always `agent-browser close --all` before starting** — stale sessions have cached media settings.
- **`agent-browser set media dark` must be set once per session** — it resets if you close and reopen.
- **Reload after setting media** — some frameworks apply color scheme on load, not dynamically: `agent-browser reload`.
- **`lum > 0.5` in dark mode is the #1 catch** — this is what "white page in dark mode" looks like programmatically.
- **Don't read the source code of the app under test** — all findings must come from what you observe in the browser.
- **Prioritise critical issues** — if a page is completely broken, note it and move on rather than spending time diagnosing it mid-sweep.
- **Run in under 5 minutes for a 10-page site** — keep screenshots quick, eval lightweight, don't deep-dive individual bugs.
