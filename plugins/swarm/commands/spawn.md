---
description: Spawn a single background agent for specific analysis
allowed-tools: Bash,Read,Write,AskUserQuestion
---

Spawn a single specialized agent to run analysis in the background.

## Usage

```
/spawn <agent> [--watch <pattern>] [--once]
```

**Arguments:**
- `agent` - Agent type (reviewer, simplifier, type-analyzer, silent-hunter, comment-analyzer, test-analyzer)
- `--watch` - File pattern to watch (default: `src/**/*.ts`)
- `--once` - Run once and exit (no watch mode)

## Steps:

1. **Validate agent type:**
   - Check if agent is one of the supported types
   - If not, show available agents and exit

2. **Initialize if needed:**

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   mkdir -p .claude/swarm/{reports,issues,logs,pids,progress}
   ```

   **PowerShell (Windows):**
   ```powershell
   $dirs = @('reports','issues','logs','pids','progress')
   $dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path ".claude/swarm/$_" }
   ```

3. **Check for existing agent:**
   - Look for `.claude/swarm/pids/<agent>.pid`
   - If running, ask user: restart or skip?

4. **Load agent instructions:**
   - Read from `agents/<agent>.md` in plugin directory
   - These contain specialized prompts for each agent type

5. **Spawn agent:**

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   # Watch mode (default)
   nohup claude --agent <agent> \
     --system "$(cat agents/<agent>.md)" \
     --watch "<pattern>" \
     --output ".claude/swarm/reports/<agent>-$(date +%s).md" \
     --dangerously-skip-permissions \
     > .claude/swarm/logs/<agent>.log 2>&1 &
   echo $! > .claude/swarm/pids/<agent>.pid

   # One-shot mode
   claude --agent <agent> \
     --system "$(cat agents/<agent>.md)" \
     --path "src/" \
     --output ".claude/swarm/reports/<agent>-$(date +%s).md" \
     --dangerously-skip-permissions
   ```

   **PowerShell (Windows):**
   ```powershell
   # Watch mode (default)
   $timestamp = [int](Get-Date -UFormat %s)
   $agentInstructions = Get-Content "agents/<agent>.md" -Raw
   $process = Start-Process claude -ArgumentList @(
     '--agent', '<agent>',
     '--system', $agentInstructions,
     '--watch', '<pattern>',
     '--output', ".claude/swarm/reports/<agent>-$timestamp.md",
     '--dangerously-skip-permissions'
   ) -RedirectStandardOutput ".claude/swarm/logs/<agent>.log" `
     -RedirectStandardError ".claude/swarm/logs/<agent>-err.log" `
     -PassThru -NoNewWindow
   $process.Id | Out-File .claude/swarm/pids/<agent>.pid

   # One-shot mode
   $timestamp = [int](Get-Date -UFormat %s)
   claude --agent <agent> `
     --system (Get-Content "agents/<agent>.md" -Raw) `
     --path "src/" `
     --output ".claude/swarm/reports/<agent>-$timestamp.md" `
     --dangerously-skip-permissions
   ```

6. **Confirm spawn:**
   - Show PID and log location
   - Remind user to check `/hive` for status

## Agent Types

| Agent | Focus | Output |
|-------|-------|--------|
| `reviewer` | Code quality, patterns, best practices | Issues + suggestions |
| `simplifier` | Complexity reduction, DRY violations | Refactor suggestions |
| `type-analyzer` | Type safety, inference issues | Type errors + fixes |
| `silent-hunter` | Unhandled promises, silent failures | Critical async issues |
| `comment-analyzer` | TODOs, FIXMEs, outdated comments | Documentation tasks |
| `test-analyzer` | Coverage gaps, test quality | Test suggestions |

## Examples

```bash
# Spawn code reviewer watching TypeScript files
/spawn reviewer --watch "src/**/*.ts"

# Run silent failure analysis once
/spawn silent-hunter --once

# Spawn type analyzer for specific directory
/spawn type-analyzer --watch "src/plugins/**/*.tsx"
```

## Context Protocol

**Every spawned agent receives these instructions as part of their system prompt:**

```markdown
## Context Protocol

You have a finite context window. Follow these rules to work efficiently:

1. **Work efficiently** — Don't load unnecessary files. Read only what you need.

2. **Checkpoint at natural breakpoints** — If your task is complex, save progress to
   `.claude/swarm/progress/{agent-name}-{timestamp}.md` before moving to the next subtask.

3. **Complete gracefully** — If you sense you're running long or approaching limits,
   wrap up your current work and document next steps rather than getting cut off.

4. **Structured outputs** — Write findings to `.claude/swarm/reports/` in structured
   markdown format. Use tables, bullet points, and clear sections.

5. **Limit file reads** — Summarize relevant code rather than copying entire files.
   Reference file paths and line numbers instead of full content.

Checkpoint format:
```
# Agent Checkpoint: {agent-name}
Timestamp: {ISO timestamp}
Task: {what you were analyzing}

## Progress
- [x] Completed subtask 1
- [x] Completed subtask 2
- [ ] Remaining subtask 3

## Findings So Far
{Key discoveries written to reports}

## Next Steps
{What continuation should do}
```
```

**This protocol is automatically injected when spawning agents.**

## Notes

- Each agent runs independently with its own context
- Reports are timestamped and accumulated in `.claude/swarm/reports/`
- Logs are available in `.claude/swarm/logs/<agent>.log`
- Agents self-manage context through the Context Protocol
