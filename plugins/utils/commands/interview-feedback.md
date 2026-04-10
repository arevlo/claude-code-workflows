---
description: Use when reviewing a hiring interview transcript to generate structured candidate feedback. Triggers on "interview feedback", "evaluate candidate", "review interview", "hiring scorecard", "candidate assessment".
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Hiring Interview Feedback

Generate structured candidate feedback from interview transcripts. The output is designed to be copy-pasted into an ATS scorecard (Greenhouse-style: trait + rating + comment).

## Workflow

### 1. Determine Interview Type

Ask which type of interview this is. The traits differ significantly between them:

- **Portfolio Presentation** - Candidate presents their past work
- **Design Critique** - Candidate reviews a product/website and discusses its design
- **Cross-Functional** - Panel interview with Engineer, PM, Program Manager

Note: Design Critique and Cross-Functional are two rounds of the same interview loop. They may have separate transcripts or be in the same file.

### 2. Select Transcript

Scan the current project for markdown files that look like interview transcripts. Present the list and let the user pick. Extract the candidate name from the file. Check frontmatter `participants` field first, then fall back to the filename or title.

If no transcripts exist, tell the user and ask them to provide a path.

### 3. Analyze Transcript

Read the full transcript. For each trait (see below), find **specific moments** (direct quotes, described behaviors, or notable exchanges) that serve as evidence. Look for both positive and negative signals. If a trait has no clear evidence, note that explicitly rather than inventing something.

### 4. Generate Pre-filled Feedback

#### Portfolio Presentation Traits

| Trait | What to look for |
|-------|-----------------|
| **User Empathy** | Does the candidate obsess over users before and during design? Do they mention user research, testing, interviews, persona development? Do they reference real user pain points or just abstract "user needs"? |
| **Communication & Collaboration** | Does the candidate tailor communication style to the audience? Do they explain trade-offs clearly? Evidence of working across functions (eng, PM, stakeholders)? |
| **Efficient Processes & Research** | Systematic approach to design work. Structured research, clear methodology, time-boxed exploration? Or scattered, ad-hoc? |
| **Product Sense & Commercial Acuity** | Can they balance delight with viability? Do they consider business metrics, conversion, retention? Do they understand the commercial context of their designs? |

#### Design Critique Traits

The candidate walks through a website or application (not their own work) and discusses its design.

**What good looks like:** A strong candidate does not just describe what they see -- they explain why something works or does not, connect it to the user, and bring a point of view.

| Trait | What to look for |
|-------|-----------------|
| **Product Thinking** | What problem does the product solve and how does design play a role? What are competitive products and how do they compare? |
| **Interaction Design** | How does visual design relate to the job-to-be-done? Does it follow traditional patterns? Are there micro-experiences? |
| **Systems Thinking** | Do they notice consistency -- grid, affordances, hierarchy? Do they mention a design system? |
| **Intentionality & Excellence** | Would they do anything differently, and why? How do they define design excellence? |
| **Collaboration** | Do they have a perspective on the complexity and its cross-functional impact? |

#### Cross-Functional Traits

Get a sense of how this person builds with others. Great designers do not just make things look right -- they help teams move, stay aligned, and ship work that matters.

**What good looks like:** Someone with a genuine perspective on how design and product work together -- from real experience navigating the messy middle.

| Trait | What to look for |
|-------|-----------------|
| **Product Thinking** | Have they helped define a roadmap or what success looks like? What do they see as design's role in the product? |
| **Proactiveness** | Have they identified a problem, proposed a solution, and brought cross-functional partners along? |
| **Design Excellence** | How do they evaluate excellence -- what does done well look like? How do they use data and research? |
| **Self-Awareness** | How have they handled conflicting incentives with cross-functional partners? What do they feel their role as a designer should be? |

#### Rating Scale

For each trait, suggest one of:
- **Strong Yes** (clear, compelling evidence of excellence)
- **Yes** (solid evidence, meets the bar)
- **No** (insufficient evidence or concerning signals)
- **Strong No** (clear evidence of a gap or red flag)

#### Debrief Signal Guide

Use these signals to calibrate your assessment. Map evidence to Strong/Developing/Missing, then translate to the rating scale above.

| Signal | Strong | Developing | Missing |
|--------|--------|-----------|---------|
| Product thinking | Connects design to user and business outcomes directly | Describes the product but relies on surface observations | Cannot articulate what problem the product solves |
| Systems awareness | Notices consistency, hierarchy, affordances -- and explains their impact | Identifies isolated elements without connecting them | Focuses only on aesthetics with no structural lens |
| Intentionality | Has a clear point of view and defends it thoughtfully | Shares opinions but without clear reasoning | Avoids committing to any perspective |
| XFN collaboration | Gives specific examples of navigating friction and building alignment | Describes collaborative work without naming tradeoffs | Cannot speak to cross-functional dynamics beyond their own role |
| Self-awareness | Owns mistakes, names growth areas, reflects honestly on their role | Acknowledges challenges but frames them externally | No evidence of reflection on their own contribution |

#### Overall Rating

After evaluating all traits, suggest an overall candidate rating using the same scale (Strong Yes / Yes / No / Strong No). Weight it based on the trait breakdown, but keep in mind that a "No" on a trait due to insufficient evidence (e.g. project context didn't allow it) is different from a "No" based on concerning signals. Call that distinction out.

#### Output Format for Review

Present all traits at once in this format:

```
## [Candidate Name], [Interview Type] Feedback

**Overall Rating:** [Strong Yes / Yes / No / Strong No]
[1 sentence justification]

### [Trait Name]
**Suggested Rating:** [Strong Yes / Yes / No / Strong No]

[2-4 sentence comment with specific evidence from the transcript. Include direct quotes where possible. This should read as a complete scorecard comment, ready to paste into the ATS.]

---
(repeat for each trait)
```

After presenting, ask: "Do you want to adjust any ratings or comments before I write the file?"

### 5. General Notes

After presenting the trait assessments, also generate a brief general note (2-3 sentences) summarizing the candidate's overall impression: standout strengths, key concerns, and whether they'd be a good fit for the team.

Then ask: "Any additional general notes about the candidate you'd like to add?"

### 6. Write Output File

Write to a `feedback/` directory relative to the transcript location (create the directory if needed).

**Filename:** `YYYY-MM-DD-candidate-name-{portfolio|critique|xfn}-feedback.md`
- Use today's date
- Lowercase, hyphenated candidate name
- `portfolio`, `critique`, or `xfn` based on interview type

**File structure:**

```markdown
---
candidate: [Full Name]
date: [YYYY-MM-DD]
interview_type: [Portfolio Presentation | Design Critique | Cross-Functional]
overall_rating: [Strong Yes / Yes / No / Strong No]
---

# [Candidate Name], [Interview Type] Feedback

**Overall Rating:** [Strong Yes / Yes / No / Strong No]

## Trait Assessments

### [Trait Name]
**Rating:** [Strong Yes / Yes / No / Strong No]

[Comment with evidence]

---

(repeat for each trait)

## General Notes

[Generated overall summary: 2-3 sentences on standout strengths, concerns, and fit]

[User's additional notes, if any]
```

Confirm the file path to the user when done so they can find it easily.
