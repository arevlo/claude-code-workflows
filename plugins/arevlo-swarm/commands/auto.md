---
description: Autonomous workflow - research, plan, and implement with minimal interruption
argument-hint: <goal>
allowed-tools: Bash,Read,Write,Edit,Glob,Grep,Task,AskUserQuestion,TodoWrite
---

Autonomous mode for complex tasks. Follows ACE (Advanced Context Engineering) principles:
- **Research → Plan → Implement** phases (don't skip)
- **Subagents for context isolation** (fresh context windows)
- **Human leverage at planning** (approve before implementation)
- **Compacted outputs** (structured summaries, not verbose logs)

## Usage

```
/auto <goal>
```

**Examples:**
```
/auto "add user authentication with OAuth"
/auto "refactor the API layer to use repository pattern"
/auto "fix the memory leak in the data processor"
```

## Steps

### Phase 1: Research (Context Isolated)

1. **Initialize workspace:**

   **bash/zsh:**
   ```bash
   mkdir -p .claude/swarm/{research,plans,progress}
   ```

   **PowerShell:**
   ```powershell
   @('research','plans','progress') | ForEach-Object {
     New-Item -ItemType Directory -Force -Path ".claude/swarm/$_"
   }
   ```

2. **Launch research subagent:**

   Use the Task tool with `subagent_type: "Explore"` to investigate:
   - Codebase architecture and structure
   - Relevant files for the goal
   - Existing patterns and conventions
   - Dependencies and relationships
   - Potential approaches

   **Prompt template for research agent:**
   ```
   Research the codebase to understand how to: <goal>

   Investigate:
   1. Overall architecture - what's the project structure?
   2. Relevant files - which files relate to this goal?
   3. Existing patterns - how are similar things implemented?
   4. Dependencies - what does this code depend on?
   5. Entry points - where would changes be made?

   Output a COMPACTED research summary (not verbose logs):
   - Codebase overview (stack, structure)
   - Relevant files table (file, purpose, notes)
   - Information flow (how data/control flows)
   - Potential approaches with pros/cons
   - Open questions needing human input
   ```

3. **Save research findings:**

   Write compacted research to `.claude/swarm/research/<timestamp>.md`:

   ```markdown
   ## Research: <goal>
   **Generated:** <timestamp>

   ### Codebase Overview
   - **Stack:** [detected technologies]
   - **Structure:** [project organization]
   - **Entry points:** [key files]

   ### Relevant Files
   | File | Purpose | Lines | Notes |
   |------|---------|-------|-------|
   | path/file.ts | [what it does] | ~XXX | [relevant notes] |

   ### Information Flow
   [How data/control flows through the relevant code paths]

   ### Potential Approaches
   1. **[Approach A]** - [description]
      - Pros: [list]
      - Cons: [list]
   2. **[Approach B]** - [description]
      - Pros: [list]
      - Cons: [list]

   ### Open Questions
   - [Questions that need human input before proceeding]

   ### Recommended Approach
   [Which approach and why]
   ```

4. **Display research summary to user:**

   Show the compacted findings and ask if research is sufficient or needs expansion.

---

### Phase 2: Planning

5. **Create implementation plan:**

   Based on research, create a detailed phase-by-phase plan:

   ```markdown
   ## Implementation Plan: <goal>
   **Based on research:** <research-file>
   **Generated:** <timestamp>

   ### Approach
   [Selected approach from research]

   ### Prerequisites
   - [ ] Research reviewed
   - [ ] Approach approved by human

   ### Phase 1: [Name]
   **Objective:** [What this phase accomplishes]

   **Files to modify:**
   - `path/file.ts` - [specific changes needed]
   - `path/other.ts` - [specific changes needed]

   **Steps:**
   1. [Specific action with details]
   2. [Specific action with details]
   3. [Specific action with details]

   **Verification:**
   - [ ] [How to verify this phase worked]
   - [ ] [Test or check to run]

   ### Phase 2: [Name]
   ...

   ### Phase 3: [Name]
   ...

   ### Rollback Strategy
   [How to undo changes if needed - git commands, etc.]

   ### Estimated Complexity
   **[Low/Medium/High]** - [reasoning]

   ### Risk Assessment
   - [Potential risks and mitigations]
   ```

6. **Save plan:**

   Write to `.claude/swarm/plans/<timestamp>.md`

7. **HUMAN APPROVAL GATE:**

   Use AskUserQuestion to get explicit approval:

   ```json
   {
     "questions": [{
       "question": "Review the implementation plan. Ready to proceed?",
       "header": "Plan Review",
       "options": [
         {"label": "Approve & Execute", "description": "Plan looks good, proceed with implementation"},
         {"label": "Modify Plan", "description": "I want to adjust the plan before proceeding"},
         {"label": "More Research", "description": "Need more investigation before planning"},
         {"label": "Cancel", "description": "Stop here, I'll handle this differently"}
       ],
       "multiSelect": false
     }]
   }
   ```

   **This is the HIGH LEVERAGE point** - human review here prevents cascading errors.

   - If "Modify Plan": Ask what changes, update plan, re-confirm
   - If "More Research": Go back to Phase 1 with specific questions
   - If "Cancel": Exit gracefully with summary of work done

---

### Phase 3: Implementation

8. **Execute plan phase-by-phase:**

   For each phase in the plan:

   a. **Announce phase start:**
      ```
      ┌─────────────────────────────────────────────────────────┐
      │  PHASE 1/3: [Phase Name]                                │
      │                                                         │
      │  Objective: [What this phase accomplishes]              │
      └─────────────────────────────────────────────────────────┘
      ```

   b. **Use TodoWrite** to track phase steps

   c. **Execute each step:**
      - Read relevant files
      - Make edits using Edit tool
      - Show diffs as you go

   d. **Run verification:**
      - Execute tests/checks defined in plan
      - Confirm step worked

   e. **Checkpoint progress:**

      Write to `.claude/swarm/progress/<timestamp>.md`:
      ```markdown
      ## Progress: <goal>
      **Updated:** <timestamp>

      ### Completed
      - [x] Phase 1: [Name] - [brief outcome]
      - [x] Phase 2: [Name] - [brief outcome]

      ### Current
      - [ ] Phase 3: [Name] - [status]

      ### Remaining
      - [ ] Phase 4: [Name]

      ### Blockers
      - [Any issues encountered]

      ### Files Modified
      - `path/file.ts` - [changes made]
      ```

   f. **Handle failures:**
      - If a step fails, pause and report
      - Ask user: Retry / Skip / Abort
      - Log failure in progress file

9. **Continue until complete or blocked:**

   - Complete all phases
   - Or stop at blocking issue and report status

---

### Phase 4: Completion

10. **Generate final summary:**

    ```
    ┌─────────────────────────────────────────────────────────┐
    │  AUTO MODE COMPLETE                                     │
    │                                                         │
    │  Goal: <goal>                                           │
    │                                                         │
    │  Phases completed: 3/3                                  │
    │  Files modified: 5                                      │
    │  Tests passing: Yes                                     │
    │                                                         │
    │  Files changed:                                         │
    │  - src/auth/handler.ts (new)                            │
    │  - src/api/routes.ts (modified)                         │
    │  - src/config/auth.ts (new)                             │
    │  - src/types/auth.ts (new)                              │
    │  - tests/auth.test.ts (new)                             │
    │                                                         │
    │  Research: .claude/swarm/research/<timestamp>.md        │
    │  Plan: .claude/swarm/plans/<timestamp>.md               │
    │  Progress: .claude/swarm/progress/<timestamp>.md        │
    │                                                         │
    │  Next steps:                                            │
    │  - Review changes: git diff                             │
    │  - Run full test suite                                  │
    │  - Commit when ready: /commit                           │
    └─────────────────────────────────────────────────────────┘
    ```

---

## Context Management

### Subagent Usage
- Use Task tool with `subagent_type: "Explore"` for research (isolated context)
- Use Task tool with `subagent_type: "Plan"` for complex planning if needed
- Main agent executes implementation to maintain continuity

### Compaction Rules
- Research output: Max 200 lines, structured tables
- Plan output: Max 150 lines, clear phases
- Progress checkpoints: Max 50 lines, status focus
- Avoid raw file contents in outputs - summarize instead

### Context Budget
- Target 40-60% context utilization
- If approaching limits, checkpoint and compact
- Progress files allow resumption if context exhausted

---

## Interruption Handling

### When to Ask Human
- Plan approval (always)
- Ambiguous implementation choices
- Test failures or unexpected errors
- Missing dependencies or access
- Scope creep detection

### When NOT to Ask
- Routine file edits matching plan
- Standard verification passing
- Normal progress between phases

---

## Error Recovery

### If Implementation Fails
1. Stop at failure point
2. Log error in progress file
3. Show error context to user
4. Offer: Retry / Skip / Abort / Get Help

### If Context Exhausted
1. Save progress checkpoint
2. Inform user of status
3. Suggest: `/resume` to continue (future command)

---

## Notes

- `/auto` is designed for complex, multi-file tasks
- For simple single-file edits, direct editing is faster
- Research phase prevents wasted implementation effort
- Plan approval is the highest-leverage human review point
- Progress files enable session resumption
