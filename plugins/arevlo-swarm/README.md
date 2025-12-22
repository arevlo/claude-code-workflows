# arevlo-swarm

Multi-agent orchestration with ACE context management for Claude Code.

## Overview

The swarm plugin enables a "hive mind" approach to code analysis and **autonomous workflows**. It combines:
- **Parallel agents** for code analysis (review, types, errors, etc.)
- **ACE principles** (Advanced Context Engineering) for context management
- **Research → Plan → Implement** workflow for complex tasks

```
┌─────────────────────────────────────────────────────────┐
│                    YOU (Claude Code)                    │
│                  Primary development                    │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────┐  ┌───────────┐  ┌───────────┐
│ Reviewer  │  │   Type    │  │  Silent   │
│   Agent   │  │ Analyzer  │  │  Hunter   │
└───────────┘  └───────────┘  └───────────┘
        │             │             │
        └──────────────┴────────────┘
                      │
              .claude/swarm/
              (shared reports)
```

## Installation

```bash
/plugin install arevlo-swarm@claude-code-workflows
```

## Commands

| Command | Description |
|---------|-------------|
| `/auto <goal>` | Autonomous workflow - research, plan, implement with checkpoints |
| `/auto --resume` | Resume from most recent checkpoint |
| `/swarm [preset]` | Start multi-agent swarm with preset or auto-detect |
| `/spawn <agent>` | Spawn a single background agent |
| `/hive` | Check status and findings from all agents |
| `/health` | Check context health metrics and alerts |
| `/sync` | Consolidate findings into prioritized action items |
| `/fix` | Interactive mode to fix issues (manual or automatic) |
| `/stop [agent]` | Stop one or all running agents |

## Quick Start

### Autonomous Mode

For complex tasks, use `/auto` to let Claude handle research, planning, and implementation:

```bash
/auto "add user authentication with OAuth"
```

**How it works:**
1. **Research** - Explores codebase in isolated context, produces structured findings
2. **Plan** - Creates phase-by-phase implementation blueprint
3. **Human Approval** - You review and approve the plan (high leverage point)
4. **Implement** - Executes plan phase-by-phase with checkpoints

**Context-Aware Features:**
- Automatic checkpoints saved after each phase
- Resume interrupted sessions with `/auto --resume`
- Context monitoring warns when approaching limits
- Emergency saves before auto-compact events

This follows ACE (Advanced Context Engineering) principles for better results on complex tasks.

### Parallel Analysis Mode

### 1. Start a Swarm

```bash
# Auto-detect project type and recommend agents
/swarm

# Or use a preset
/swarm review
```

When you run `/swarm` without arguments, it auto-detects your project type (TypeScript, Python, Go, etc.) and recommends appropriate agents.

### 2. Check Status

```bash
/hive
```

See which agents are running and their latest findings.

### 3. Review Findings

```bash
/hive
```

When all agents complete, you'll be prompted with next steps:
- Fix critical issues (recommended)
- Show full report (/sync)
- Work on something else
- Enable watch mode

### 4. Fix Issues

```bash
/fix
```

Interactive mode walks through issues one by one:
- Shows the issue and current code
- Offers to fix, skip, or view more context
- Claude implements fixes and shows diffs
- Tracks progress through issue queue

### 5. Stop When Done

```bash
/stop
```

## Presets

| Preset | Agents | Use Case |
|--------|--------|----------|
| `review` | reviewer, simplifier, comment-analyzer | General code review |
| `quality` | reviewer, type-analyzer, test-analyzer | Code quality & correctness |
| `security` | silent-hunter, reviewer | Error handling & safety |
| `cleanup` | simplifier, comment-analyzer | Tech debt reduction |
| `full` | All agents | Comprehensive analysis |
| `figma` | reviewer, type-analyzer, silent-hunter | Figma plugin development |

### Choosing a Preset

- **Greenfield projects:** Use `quality` to establish good patterns early
- **Brownfield/legacy:** Use `cleanup` or `review` to find tech debt
- **Before release:** Use `security` to catch error handling issues
- **Comprehensive audit:** Use `full` for thorough analysis

## Auto-Detection

When you run `/swarm` without a preset, it analyzes your project:

1. **Detects your stack** from config files (`tsconfig.json`, `package.json`, `go.mod`, etc.)
2. **Checks for tech debt indicators** (TODOs, missing tests, complex functions)
3. **Recommends agents** based on what it finds

Example output:
```
Detected: TypeScript project (React), no tests found

Recommended agents:
  - reviewer (code quality)
  - type-analyzer (TypeScript)
  - test-analyzer (no tests detected)

Proceed with these agents? [Y/n]
```

## Available Agents

### Analysis Agents
| Agent | Focus | Best For |
|-------|-------|----------|
| `reviewer` | Code quality, patterns, best practices | Any project |
| `simplifier` | Complexity reduction, DRY | Refactoring, brownfield |
| `type-analyzer` | TypeScript type safety | TS projects |
| `silent-hunter` | Unhandled async, silent failures | Async code, plugins |
| `comment-analyzer` | TODOs, FIXMEs, documentation | Cleanup, documentation |
| `test-analyzer` | Test coverage and quality | Testing |

### Orchestration Agents (NEW)
| Agent | Focus | Best For |
|-------|-------|----------|
| `researcher` | Deep codebase exploration | /auto research phase |
| `coordinator` | Prioritize and group issues | Multi-agent coordination |

## How It Works

### Shared Context

Agents communicate through files in `.claude/swarm/`:

```
.claude/swarm/
├── research/       # /auto Phase 1 outputs
├── plans/          # /auto Phase 2 outputs
├── progress/       # Checkpoints (auto + agent)
├── reports/        # Agent findings (timestamped)
├── issues/         # Extracted issues
├── context/        # Shared state
├── logs/           # Agent logs
├── pids/           # Process IDs
└── sync/           # Consolidated reports
```

### Context Management

The swarm approach helps manage context limits:
- Each agent has its own context window
- Agents write findings to files (not accumulating in your session)
- You load only what you need via `/sync` or `/load-context swarm`

### Context Health Tracking

The swarm plugin includes background health tracking via hooks:

**Hooks installed:**
- `SessionStart` - Initializes metrics tracking at session start
- `PostToolUse` - Tracks proxy signals after each tool use
- `PreCompact` - Emergency save at 80% threshold

**Check health anytime:**
```bash
/health
```

Shows current metrics:
- File reads (threshold: 50)
- Code edits (threshold: 30)
- Message weight (threshold: 30)
- Alert level (GOOD → WATCH → WARNING → CRITICAL)

### Context Protocol

All agents follow a context protocol for graceful operation:

| Context % | Status | Action |
|-----------|--------|--------|
| < 40% | Good | Continue normally |
| 40-60% | Watch | Save checkpoint, continue |
| 60-70% | Warning | Compact and checkpoint |
| > 70% | Critical | Complete gracefully, save state |

**Alert levels based on proxy signals:**

| Warning Signals | Level | Recommended Action |
|-----------------|-------|-------------------|
| 0-1 | GOOD | Continue normally |
| 2 | WATCH | Consider `/checkpoint` soon |
| 3 | WARNING | `/checkpoint` now, consider wrapping up |
| 4+ | CRITICAL | Save immediately, complete gracefully |

**Automatic features:**
- Health metrics tracked via `PostToolUse` hook
- Alerts written to `.claude/swarm/guardian/alerts.md`
- Checkpoints saved at phase transitions
- Emergency saves triggered before auto-compact (via PreCompact hook at 80%)
- Agents complete gracefully rather than getting cut off
- Use `/load-context` → "Swarm checkpoints" to recover

## Requirements

- Claude Code with plugin support
- `--dangerously-skip-permissions` enabled for background agents
- **Supported platforms:** macOS, Linux, Windows

### Shell Requirements

| Platform | Supported Shells |
|----------|------------------|
| macOS/Linux | bash, zsh (default) |
| Windows | PowerShell, Git Bash, WSL |

> **Note:** Windows cmd.exe is not supported. Use PowerShell (default on Windows 10+) or a Unix shell (Git Bash, WSL).

## Examples

### Example: TypeScript/React Project

```bash
cd my-react-app
/swarm quality
# Spawns: reviewer, type-analyzer, test-analyzer
```

### Example: Python Backend

```bash
cd my-api
/swarm review
# Spawns: reviewer, simplifier, comment-analyzer
```

### Example: Figma Plugin

```bash
cd my-figma-plugin
/swarm figma
# Spawns: reviewer, type-analyzer, silent-hunter
```

### Example: Legacy Codebase Cleanup

```bash
cd legacy-app
/swarm cleanup
# Spawns: simplifier, comment-analyzer
```

## Workflow

### One-Time Analysis (default)

```bash
cd my-project
/swarm                    # Start agents
# (agents analyze codebase)
/hive                     # Review findings, pick next step
/fix                      # Fix issues interactively
/stop                     # Stop when done
```

### Continuous Development (watch mode)

```bash
cd my-project
/swarm figma --watch      # Start in watch mode
# (agents analyze, then watch for changes)

# You make changes...
# Agents re-analyze automatically

/hive                     # Check findings anytime
/fix                      # Fix issues as they appear
# Loop continues...

/stop                     # Stop when done
```

### Focused Analysis

```bash
cd my-large-monorepo
/swarm review --focus packages/auth    # Only analyze auth package
```

## Watch Mode

Keep agents running continuously for real-time feedback during development.

```bash
/swarm figma --watch
```

**How it works:**
1. Agents perform initial analysis
2. Then watch for file changes
3. When you edit files, affected code is re-analyzed
4. New findings appear when you run `/hive`

**Best for:**
- Active development sessions
- Refactoring work
- When you want continuous feedback

## Focus Mode

Limit analysis to specific paths in large codebases.

```bash
/swarm --focus src/components    # Only analyze components
/swarm --focus packages/api      # Only analyze API package
```

**Best for:**
- Monorepos with many packages
- Working on specific features
- Reducing noise from unrelated code

## Tips

1. **Start lean**: Begin with 2-3 agents, add more if needed
2. **Check `/hive` periodically**: See what agents have found
3. **Use `/sync` before big changes**: Get a clean action list
4. **Agents are additive**: They accumulate findings over time

## Customization

Agent behavior can be customized by editing files in `agents/`:
- `reviewer.md` - Code review focus areas
- `silent-hunter.md` - Failure patterns to detect
- `type-analyzer.md` - Type checking rules
- etc.

### Creating Custom Presets

To create a domain-specific preset (like `figma`), add a new section to `swarm.md`:

```json
{
  "agents": ["reviewer", "your-agent", "another-agent"],
  "watch": "src/**/*.{ts,tsx}",
  "focus": "Your specific focus area"
}
```

## License

MIT
