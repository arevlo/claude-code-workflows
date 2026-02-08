---
description: Add a Confluence document summary to an Obsidian project file (TDD, PRD, Design, etc.)
argument-hint: [confluence-url] [optional:project-name]
allowed-tools: mcp__claude_ai_Atlassian__getConfluencePage,Read,Write,Bash,AskUserQuestion,Glob
---

Add a Confluence document summary (TDD, PRD, Design Doc, RFC, Spec) to a project file in your local projects directory. Fetches the Confluence page, generates a dense summary, and creates or appends to the project file.

## What this does

When you provide a Confluence URL and project name:
1. Fetches the Confluence page content and metadata
2. Detects the document type (TDD, PRD, Design, RFC, Spec)
3. Asks which platform section (Web/Mobile) and document status
4. Generates a one-line description, author attribution, and 3-6 sentence summary
5. Creates a new project file with the full template, or appends the document block to an existing one

## Configuration

Configuration is stored in `~/.claude/obsidian-plugin.json`. The `vault_path` field is used to locate the `projects/` directory.

## Steps

### 0. Load Configuration

Before doing anything else, read the configuration file:

1. Use the `Read` tool to read `~/.claude/obsidian-plugin.json`
2. **If the file does not exist:**
   - Inform the user: "No Obsidian plugin configuration found. Let's set it up."
   - Use `AskUserQuestion` to ask for their Obsidian vault path (absolute path, no `~`)
   - Use `Bash` to create the config file:
     ```bash
     mkdir -p ~/.claude && cat > ~/.claude/obsidian-plugin.json << 'ENDCONFIG'
     {
       "vault_path": "{user's vault path}"
     }
     ENDCONFIG
     ```
   - Continue with the values provided
3. **If the file exists:** Parse the JSON and extract `vault_path` for use in subsequent steps

The projects directory is `{vault_path}/projects/`.

### 1. Fetch the Confluence Page

Parse the user's input for a Confluence URL:

- **URL provided as argument:** Extract the page ID from the URL (the numeric segment after `/pages/`). Use `mcp__claude_ai_Atlassian__getConfluencePage` with `bodyFormat: "storage"` to get the full HTML content and metadata. Parse the HTML into readable text.
- **No URL provided:** Use `AskUserQuestion` to ask:
  - Question: "What Confluence page would you like to add?"
  - Options:
    - "I'll paste a URL"
    - "Search by title"
  - Then follow up to get the URL

Extract from the Confluence response:
- **Page title** (from the API response)
- **Page URL** (reconstruct from the Confluence URL or `_links` in response)
- **Authors** (from `version.by.displayName` or page history/metadata — look for creator and any co-authors mentioned in the content)
- **Full content** for summary generation

### 2. Resolve the Project File

Determine which project file to use:

1. **If project name was provided as argument:** Convert to kebab-case filename: `{vault_path}/projects/{project-name}.md`
2. **If not provided:** Use `Glob` to list existing files in `{vault_path}/projects/*.md`, then use `AskUserQuestion`:
   - Question: "Which project should I add this document to?"
   - Options: List up to 3 existing project files (by filename without extension), plus a "Create new project" option
   - If "Create new project": ask for the project name

3. **Check if the file exists** using `Read`:
   - **File exists with full template** (has `## Web` or `## Mobile` headings): Will append to it in Step 7
   - **File exists but minimal** (just an H1 title, like `# Unit Availability`): Will rebuild with full template, preserving the existing H1
   - **File does not exist:** Will create new file with full template in Step 7

### 3. Ask for Platform

Use `AskUserQuestion`:
- Question: "Which platform section should this document go under?"
- Options:
  - "Web"
  - "Mobile"

### 4. Detect Document Type

Auto-detect the document type from the Confluence page title by looking for these keywords (case-insensitive):
- **TDD** — title contains "TDD" or "Technical Design"
- **PRD** — title contains "PRD" or "Product Requirements"
- **Design** — title contains "Design Doc" or "Design Document" or "HLD" or "LLD"
- **RFC** — title contains "RFC" or "Request for Comments"
- **Spec** — title contains "Spec" or "Specification"

If auto-detected, confirm with the user via `AskUserQuestion`:
- Question: "I detected this as a **{type}**. Is that correct?"
- Options:
  - "{type} (Recommended)"
  - "TDD"
  - "PRD"
  - "Design"
  - "RFC"

If not auto-detected, ask the user:
- Question: "What type of document is this?"
- Options:
  - "TDD"
  - "PRD"
  - "Design"
  - "RFC"

### 5. Ask for Status

Use `AskUserQuestion`:
- Question: "What is the current status of this document?"
- Options:
  - "DRAFT"
  - "IN REVIEW"
  - "APPROVED"
  - "FINAL"

### 6. Generate Content

Using the Confluence page content, generate:

1. **One-line description** — A single sentence describing what this document covers in the context of the project. Example: "Technical design for the user authentication workflows feature."

2. **Author line** — Extract author names from the Confluence page metadata (`version.by.displayName`, creator info). If multiple authors are apparent from the document content (e.g., listed contributors), include them separated by `&`. If author information is unavailable, use `AskUserQuestion` to ask: "Who are the authors of this document?"

3. **Summary** — A dense 3-6 sentence summary that covers:
   - What the document defines/proposes
   - Key architectural or product decisions
   - Important technical details or scope
   - Timeline or milestones if mentioned
   - Any notable constraints or tradeoffs

The summary should be information-dense and reference specific details from the document (names of services, specific numbers, dates, etc.) rather than being generic.

### 7. Write Output

Compose the document block:

```markdown
### {DOC_TYPE}

{One-line description.}

[{Page Title}]({url}) — {Author Names} | Status: {STATUS}

**Summary:** {3-6 sentence dense summary.}

### Notes
-
```

Now write the file based on the project file state determined in Step 2:

#### New file (does not exist)

Create a new file at `{vault_path}/projects/{project-name}.md` with:

```markdown
# {Project Name}

{time-estimate}...
## Web

{document block here if platform is Web, otherwise leave empty}

## Mobile

{document block here if platform is Mobile, otherwise leave empty}

```

Use `Bash` to create the projects directory if it doesn't exist:
```bash
mkdir -p "{vault_path}/projects"
```

Then use `Write` to create the file.

#### Minimal existing file (just an H1, no platform headings)

Read the existing H1 title from the file. Rebuild with the full template structure, preserving the original H1:

```markdown
# {Existing H1 Title}

{time-estimate}...
## Web

{document block here if platform is Web, otherwise leave empty}

## Mobile

{document block here if platform is Mobile, otherwise leave empty}

```

Use `Write` to overwrite the file.

#### Existing file with full template

Read the file content. Find the `## {Platform}` heading (e.g., `## Web`).

**Check for duplicate doc type:** Search for `### {DOC_TYPE}` under the target platform section (between `## {Platform}` and the next `## ` heading or end of file). If found:
- Use `AskUserQuestion`:
  - Question: "A **{DOC_TYPE}** section already exists under **{Platform}**. What should I do?"
  - Options:
    - "Add anyway (keep both)"
    - "Replace existing"
    - "Cancel"
- If "Cancel": Stop and inform the user.
- If "Replace existing": Remove the existing doc type block (from `### {DOC_TYPE}` to the next `### ` heading or `## ` heading or end of file) before inserting.

**Insert the document block:**
- Find the insertion point: the line before the next `## ` heading after `## {Platform}`, or end of file if it's the last section.
- If the platform section is empty, insert directly after the `## {Platform}` line (with a blank line).
- If the platform section already has content, insert after the last content block in that section (before the next `## ` heading).

**If the platform heading doesn't exist:** Append the platform section with the document block at the end of the file:

```markdown

## {Platform}

{document block}

```

Use `Write` to save the updated file.

### 8. Confirm

Show the user a confirmation:

```
Project doc updated: projects/{project-name}.md

Section: ## {Platform} → ### {DOC_TYPE}
Status: {STATUS}
Authors: {Author Names}

Summary preview:
{First ~100 characters of the summary}...
```

## Notes

- **Direct file writes only** — This command writes directly to the filesystem using the `Write` tool. It does NOT use the obsidian-zettelkasten MCP server.
- **Projects directory** — All project files live in `{vault_path}/projects/`. The directory is created if it doesn't exist.
- **Template consistency** — New and minimal files always get the full template with both `## Web` and `## Mobile` sections and the `{time-estimate}...` placeholder.
- **Summary quality** — Summaries should be information-dense with specific details (service names, endpoint counts, dates, task types) rather than generic descriptions.
- **Author extraction** — Primary source is Confluence metadata. Fall back to asking the user only if metadata is unavailable.
- **Confluence URL format** — URLs look like `https://{domain}.atlassian.net/wiki/spaces/{SPACE}/pages/{pageId}/{Page+Title}`. The page ID is the numeric segment.
