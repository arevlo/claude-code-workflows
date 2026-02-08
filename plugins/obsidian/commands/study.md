---
description: Interactively break down and study complex documents (TDDs, specs, architecture docs) with Q&A, saving session notes to Obsidian vault
allowed-tools: mcp__claude_ai_Atlassian__getConfluencePage,mcp__claude_ai_Atlassian__search,Read,Write,Bash,AskUserQuestion
---

Interactively break down and study a complex document (TDD, spec, architecture doc) section-by-section with Q&A, then save the study session as a fragment note in your Obsidian vault.

## What this does

When you provide a Confluence URL or local file path:
1. Fetches the document content
2. Parses it into logical sections and presents an outline
3. Walks through each section interactively with summaries and Q&A
4. Tracks all questions and answers from the session
5. Generates a study session note with summaries, key points, Q&A, and takeaways
6. Saves the note to your Obsidian vault

## Configuration

Configuration is stored in `~/.claude/obsidian-plugin.json`. The `vault_path` field is used for saving study notes.

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

### 1. Identify the Source Document

Parse the user's input for a source document:

- **Confluence URL:** If the user provided a Confluence URL (contains `atlassian.net/wiki`), use `mcp__claude_ai_Atlassian__getConfluencePage` to fetch the full page content. Extract the page ID from the URL. Use `bodyFormat: "storage"` to get the full HTML content, then parse it into readable text.
- **Local file path:** If the user provided a file path, use `Read` to read the file content.
- **Neither provided:** Use `AskUserQuestion` to ask:
  - Question: "What document would you like to study?"
  - Options:
    - "Confluence page (I'll paste a URL)"
    - "Local file (I'll provide a path)"
  - Then follow up to get the specific URL or path

Once the document content is loaded, extract:
- **Document title** (from Confluence page title or filename)
- **Source reference** (URL or file path)
- **Full content** for section parsing

### 2. Analyze and Present Outline

Parse the document into logical sections based on headings and major topics:

1. Identify all top-level and second-level sections (H1, H2, or equivalent structural boundaries)
2. For each section, generate a brief 1-line description of what it covers
3. Present the outline to the user:

```
Study Session: {Document Title}
Source: {URL or file path}

Sections:
1. {Section 1 title} — {1-line description}
2. {Section 2 title} — {1-line description}
3. {Section 3 title} — {1-line description}
...

I'll walk through each section with summaries and Q&A. Ask questions anytime.
```

4. Use `AskUserQuestion` to ask where to start:
   - Question: "Where would you like to start?"
   - Options:
     - "Start from the beginning"
     - "Jump to a specific section"
   - If "Jump to a specific section": ask which section number to start from

### 3. Interactive Section-by-Section Walkthrough

**Initialize tracking:**
- Create an internal list to track all Q&A pairs per section
- Track which sections have been covered
- Track the current section index

**For each section**, repeat this loop:

#### 3a. Present Section Summary

Present a clear summary (200-300 words) that explains:
- **What this section covers** — the main topic and purpose
- **Key decisions or tradeoffs** — any architectural choices, design decisions, or tradeoffs discussed
- **Connection to previous sections** — how this builds on or relates to what came before
- **Important technical details** — simplified explanation of any complex technical content

Format the summary clearly with the section number and title as a header.

#### 3b. Ask for Questions

Use `AskUserQuestion`:
- Question: "Questions about **{Section Title}**?"
- Options:
  - "No questions, next section"
  - "I have a question"
  - "Go deeper on this section"
  - "Skip to a specific section"

#### 3c. Handle Response

- **"No questions, next section"**: Move to the next section. If this was the last section, proceed to Step 4.
- **"I have a question"**: The user will type their question. Answer it thoroughly, then record the Q&A pair. After answering, ask again (repeat 3b) to check for more questions.
- **"Go deeper on this section"**: Provide a more detailed breakdown covering implementation details, edge cases, implications, and any nuances. Then ask again (repeat 3b).
- **"Skip to a specific section"**: Ask which section number, then jump to that section.

**Important:** The user may also type free-form questions or comments instead of selecting an option. Always treat free-form text as a question and answer it, then loop back to ask if they have more questions.

#### 3d. Record Q&A

For every question asked (whether via option selection or free-form), record:
- The question text
- Your answer text
- Which section it belongs to

These will be included in the final output note.

### 4. Generate Session Summary

After completing all sections (or when the user indicates they're done):

1. **Compile takeaways** — Identify the 3-5 most important points from the entire document. These should be actionable or conceptually significant insights.

2. **List open questions** — Any questions that came up during the session that couldn't be fully answered, or areas that need further investigation.

3. **Note action items** — Any follow-ups, tasks, or next steps identified during the discussion.

Present the summary to the user before saving:

```
Session Summary

Sections covered: {n}/{total}
Questions answered: {count}

Key Takeaways:
1. {Takeaway 1}
2. {Takeaway 2}
3. {Takeaway 3}

Open Questions:
- {Question 1}
- {Question 2}

Action Items:
- {Action 1}
- {Action 2}
```

### 5. Save to Obsidian

Ask the user for save details using `AskUserQuestion`:
- Question: "What category folder should this be saved to? (Type the folder name, e.g., 'ai', 'work', 'projects')"
- Let the user type their category folder name directly

Then ask for the topic slug:
- Question: "What topic slug should I use for the filename?"
- Suggest a default based on the document title (e.g., `api-architecture-spec`, `auth-service-tdd`)
- Options:
  - "{suggested-slug} (Recommended)"
  - "Let me type a custom slug"

**Create the output directory if needed:**

```bash
VAULT_PATH="{vault_path from config}"
CATEGORY="{selected category}"
mkdir -p "$VAULT_PATH/$CATEGORY/fragments"
```

**Write the study note** using the `Write` tool to save to `{vault_path}/{category}/fragments/{topic}.md`:

```markdown
---
date: YYYY-MM-DD
type: study-session
source: "{URL or file path}"
---

# Study: {Document Title}

> Source: [{title}]({url or path})
> Date: {Mon DD, YYYY}
> Sections covered: {n}/{total}

## Overview
{2-3 sentence summary of the entire document — what it is, what it defines, and its scope}

## {Section 1 Title}

### Summary
{The summary presented during the walkthrough for this section}

### Key Points
- {Key point 1}
- {Key point 2}
- {Key point 3}

### Q&A
**Q: {User's question}**
A: {Your answer}

**Q: {Another question}**
A: {Answer}

## {Section 2 Title}

### Summary
{Summary}

### Key Points
- {Points}

### Q&A
{Q&A pairs, or omit this subsection if no questions were asked for this section}

...

## Takeaways
- {Key takeaway 1}
- {Key takeaway 2}
- {Key takeaway 3}
- {Key takeaway 4}
- {Key takeaway 5}

## Open Questions
- {Any unresolved questions from the session}

## Action Items
- {Any follow-ups identified during the session}
```

**Rules for the output note:**
- Only include the Q&A subsection for sections where questions were actually asked
- Only include "Open Questions" and "Action Items" sections if there are items to list
- Use the actual date of the session
- For Confluence sources, make the source a clickable link
- Keep section summaries concise (the note is a reference, not a reproduction of the walkthrough)

### 6. Confirm

Show the user a final confirmation:

```
Study session saved: {category}/fragments/{topic}.md

Sections covered: {n}/{total}
Questions answered: {count}
Takeaways captured: {count}
```

## Notes

- **Session flexibility:** Users can stop at any point and the note will be generated with whatever sections were covered. Track "Sections covered: X/Y" to reflect this.
- **Long documents:** For very long documents (20+ sections), suggest grouping related sections or focusing on specific areas rather than walking through everything.
- **Confluence formatting:** Confluence pages may have complex HTML (tables, macros, panels). Parse these into readable plain text/markdown for the summaries.
- **Fragment lifecycle:** Like other fragment notes, study sessions are captures meant to be referenced later or processed into atomic knowledge.
- **Re-studying:** Users may want to re-study a document. Each session creates a new fragment, so previous sessions are preserved.
