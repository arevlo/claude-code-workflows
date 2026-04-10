---
skill: obsidian:graph:sync
type: local
title: Obsidian Graph Sync
description: Use when the user wants to link all Obsidian documents together, connect the graph, run a graph sync, or add wiki-links between notes. Triggers on "graph sync", "connect my notes", "link my documents", "connect the graph".
allowed-tools: Bash, Read, Edit, Write
---

# Obsidian Link Pass

Scan all vault `.md` files, insert `[[wiki-links]]` for keyword matches, and append `## Related` sections for semantic connections. Increases Obsidian graph density.

---

## Phase 1 -- Python Keyword Scan

Write `/tmp/obsidian_link_pass.py` and run it:

```python
#!/usr/bin/env python3
import os, re, json, pathlib, subprocess

# Get vault path from obsidian CLI
vault = pathlib.Path(subprocess.check_output(
    ["obsidian", "vault", "info=path"], text=True
).strip())

# Get all .md files from obsidian CLI (excludes .obsidian/ by default)
file_list_raw = subprocess.check_output(
    ["obsidian", "files", "ext=md"], text=True
).strip()
md_files = [vault / line.strip() for line in file_list_raw.splitlines() if line.strip()]

# Get aliases from obsidian CLI (verbose mode: "alias<TAB>filepath" per line)
alias_raw = subprocess.check_output(
    ["obsidian", "aliases", "verbose"], text=True
).strip()

# Build title index: {display_title: file_path}
title_index = {}  # title_lower -> (display_title, file_path)

for fp in md_files:
    stem = fp.stem
    display = stem.replace("-", " ").replace("_", " ")
    title_index[display.lower()] = (display, fp)
    title_index[stem.lower()] = (stem, fp)

# Parse aliases from CLI output (format: "alias\trelative_path")
for line in alias_raw.splitlines():
    if not line.strip():
        continue
    parts = line.split("\t", 1)
    if len(parts) == 2:
        alias, rel_path = parts[0].strip(), parts[1].strip()
        fp = vault / rel_path
        title_index[alias.lower()] = (alias, fp)

manifest = {}

for fp in md_files:
    rel = str(fp.relative_to(vault))
    text = fp.read_text(encoding="utf-8", errors="ignore")
    inline_hits = []
    already_linked = []

    # Find all existing [[...]] links
    existing = set(m.lower() for m in re.findall(r'\[\[([^\]|]+)(?:\|[^\]]*)?\]\]', text))

    for title_lower, (display, target_fp) in title_index.items():
        if target_fp == fp:
            continue  # skip self
        if title_lower in existing:
            already_linked.append(display)
            continue
        # Word-boundary search (case-insensitive)
        pattern = r'(?<!\[\[)\b' + re.escape(title_lower) + r'\b(?!\]\])'
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            inline_hits.append({
                "title": display,
                "target": str(target_fp.relative_to(vault)),
                "match_text": match.group(0),
                "position": match.start()
            })
            # Mark as seen to avoid double-adding from stem/display variants
            existing.add(title_lower)

    manifest[rel] = {
        "inline": inline_hits,
        "already_linked": already_linked,
        "related": []
    }

out = pathlib.Path("/tmp/obsidian_link_manifest.json")
out.write_text(json.dumps(manifest, indent=2, default=str))
print(f"Scanned {len(md_files)} files -> {out}")
total_inline = sum(len(v['inline']) for v in manifest.values())
print(f"Keyword hits: {total_inline} across {sum(1 for v in manifest.values() if v['inline'])} files")
zero_hits = [k for k,v in manifest.items() if not v['inline']]
print(f"Files with 0 keyword hits (candidates for semantic pass): {len(zero_hits)}")
```

Run it:
```bash
python3 /tmp/obsidian_link_pass.py
```

Read the manifest output from `/tmp/obsidian_link_manifest.json`.

---

## Phase 2 -- AI Semantic Pass

For files with 0 inline keyword hits:

1. Read their content in batches of ~10 files
2. Compare against the full title index (all document titles)
3. Identify conceptually related documents (shared topics, themes, project connections)
4. Add to manifest `"related"` array as `[[Title]]` strings

When reading batches, check the manifest for the `"related"` key and populate it. Example:
```json
{
  "personal/some-note.md": {
    "inline": [],
    "related": ["[[project standup]]", "[[Q1 planning]]"]
  }
}
```

Update `/tmp/obsidian_link_manifest.json` after the semantic pass.

---

## Phase 3 -- Preview

Print a grouped summary:

```
personal/project-alpha.md
  Inline:  "roadmap" -> [[roadmap]]  ·  "design system" -> [[design system]]
  Related: [[project-x]] · [[Q1 planning]]

personal/daily-note/daily-2026-01-15.md
  Related: [[standup]]

N files · X inline links · Y Related entries
```

Ask: **Apply changes? (yes / skip <file> / cancel)**

Handle skip responses: remove the named file from the manifest before applying.

---

## Phase 4 -- Apply

### 4a -- Inline links (Python script)

Write and run `/tmp/obsidian_apply_links.py`:

```python
#!/usr/bin/env python3
import json, re, pathlib, os

vault = pathlib.Path(json.loads(
    pathlib.Path(os.path.expanduser("~/.claude/obsidian-plugin.json")).read_text()
)["vault_path"])

manifest = json.loads(pathlib.Path("/tmp/obsidian_link_manifest.json").read_text())

applied = 0
for rel_path, data in manifest.items():
    if not data.get("inline"):
        continue
    fp = vault / rel_path
    text = fp.read_text(encoding="utf-8", errors="ignore")
    modified = text

    # Sort by position descending to avoid offset drift
    hits = sorted(data["inline"], key=lambda h: h["position"], reverse=True)

    for hit in hits:
        title = hit["title"]
        match_text = hit["match_text"]
        # Replace first occurrence only (case-preserving)
        pattern = r'(?<!\[\[)\b(' + re.escape(match_text) + r')\b(?!\]\])'
        # Only replace first occurrence
        modified, n = re.subn(pattern, r'[[\1]]', modified, count=1, flags=re.IGNORECASE)
        if n:
            applied += 1

    if modified != text:
        fp.write_text(modified, encoding="utf-8")
        print(f"  Updated: {rel_path}")

print(f"\nApplied {applied} inline links")
```

Run it:
```bash
python3 /tmp/obsidian_apply_links.py
```

### 4b -- Related sections (obsidian CLI)

For each file in the manifest with a non-empty `"related"` array:

1. Read the file
2. Check if it already has a `## Related` section -- if yes, skip
3. Use the `obsidian append` CLI to add the section:
   ```bash
   obsidian append path="<relative_path>" content="\n\n## Related\n[[link1]] · [[link2]] · [[link3]]"
   ```
   Use `·` (middle dot U+00B7) as separator.

---

## Key Constraints

- **Never modify** `.obsidian/` directory files
- **Never double-link**: if `[[Title]]` already exists anywhere in the file, skip that title
- **Word boundary matching**: `\b` in regex so "note" doesn't match "notebook"
- **First occurrence only**: standard Obsidian convention
- **Idempotent**: re-running produces zero changes on already-linked docs
- **Self-link prevention**: never insert a link to the file being edited

---

## Cleanup

After a successful apply (or cancel):
```bash
rm -f /tmp/obsidian_link_pass.py /tmp/obsidian_apply_links.py /tmp/obsidian_link_manifest.json
```

---

## Confirmation Message

After apply, show:
- Total files modified
- Total inline links inserted
- Total `## Related` sections added
- Remind user to open Obsidian Graph View to see the new connections
