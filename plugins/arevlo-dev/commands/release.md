---
description: Create a semver release with tag and GitHub release notes
argument-hint: <version> (e.g., v1.0.0, patch, minor, major)
allowed-tools: Bash,Read,Write,Glob,AskUserQuestion
---

Create a semantic version release with git tag and GitHub release.

Version argument: $ARGUMENTS

## Steps:

1. **Get latest tag:**
   ```bash
   gh release list --limit 1 --json tagName -q '.[0].tagName' 2>/dev/null || echo "none"
   ```
   Note: Use GitHub releases as source of truth (tags may exist locally but be deleted from GitHub).

2. **Determine new version:**
   - If argument is `patch`: bump patch (v1.0.0 → v1.0.1)
   - If argument is `minor`: bump minor (v1.0.0 → v1.1.0)
   - If argument is `major`: bump major (v1.0.0 → v2.0.0)
   - If argument is explicit version (e.g., `v1.2.0`): use that
   - If no argument: show latest tag and ask user what to bump

3. **Get commits since last tag:**
   ```bash
   git log <last-tag>..HEAD --oneline
   ```
   - If no commits since last tag, warn user and confirm they want to proceed

4. **Generate release notes:**
   - Summarize commits into release notes
   - Format as markdown with sections if appropriate
   - Show to user and ask for confirmation/edits

5. **Update plugin.json versions (if any exist):**
   - Find all plugin.json files:
     ```bash
     find . -path "*/.claude-plugin/plugin.json" -type f 2>/dev/null
     ```
   - For each plugin.json found:
     - Read the file using Read tool
     - Update the `"version"` field to new version (without 'v' prefix, e.g., `1.3.0`)
     - Write the updated file using Write tool
   - If any plugin.json files were updated:
     - Stage changes: `git add */.claude-plugin/plugin.json`
     - Commit: `git commit -m "chore: bump plugin versions to <version>"`
     - Push: `git push`

6. **Create annotated tag:**
   ```bash
   git tag -a <version> -m "<one-line summary>"
   ```

7. **Push tag:**
   ```bash
   git push origin <version>
   ```

8. **Create GitHub release:**
   ```bash
   gh release create <version> --title "<version>" --notes "<release-notes>"
   ```

9. **Confirm** with link to the release.

## Examples:

```bash
/release patch      # v1.0.0 → v1.0.1
/release minor      # v1.0.0 → v1.1.0
/release major      # v1.0.0 → v2.0.0
/release v2.0.0     # explicit version
/release            # interactive - asks what to bump
```
