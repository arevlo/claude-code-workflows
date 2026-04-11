# Claude Code Workflows

A curated collection of Claude Code plugins providing slash commands for design-to-code workflows, context management, multi-agent orchestration, development automation, and visual browser inspection.

## Installation

### Quick Start

1. Run `/plugin`
2. Select **Add Marketplace**
3. Enter marketplace source: `arevlo/claude-code-workflows`
4. Select which plugins to install

### Command Line

```bash
# Add marketplace
/plugin marketplace add arevlo/claude-code-workflows

# Install specific plugins
/plugin install context@claude-code-workflows
/plugin install design@claude-code-workflows
/plugin install dev@claude-code-workflows
/plugin install obsidian@claude-code-workflows
/plugin install swarm@claude-code-workflows
```

### Updating

```bash
# Update marketplace
/plugin marketplace update claude-code-workflows

# Then browse and install any new plugins
/plugin
# → Browse and Install Plugins
```

## Plugins

### context

**Session context and plan management with multi-source storage.**

Save and load Claude Code session context to multiple destinations including local storage, Notion, GitHub Issues, and project docs.

#### Commands

| Command | Description |
|---------|-------------|
| `/context:save-context` | Save current session to local, Notion, GitHub, or docs |
| `/context:load-context <query>` | Search and load prior context from multiple sources |
| `/context:context-status` | Check current context state and recent saves |
| `/context:checkpoint [label]` | Quick checkpoint for mid-task saves (faster than save-context) |
| `/context:plan` | Load, save, or browse Claude Code plans |

#### Context Sources

| Source | Description | Location |
|--------|-------------|----------|
| **Session Transcripts** | Prior Claude Code sessions (load only) | `~/.claude/projects/` |
| **Swarm checkpoints** | Auto checkpoints from /auto | `.claude/swarm/progress/` |
| **Claude Plans** | Saved plans | `~/.claude/plans/` |
| **Notion** | Persistent storage | `_clawd` database |
| **GitHub Issue** | Issue tracking in current repo | Creates GitHub issue |
| **Docs folder** | Project documentation | `./docs/context/` |
| **Local /tmp** | Quick, ephemeral saves | `/tmp/claude-contexts/` |

Session Transcripts are automatically saved by Claude Code for every session. Use `/load-context` to browse prior sessions with AI-generated summaries, branch info, and message counts.

#### Workflow Example

```bash
# End of session
/context:save-context
# → Select destination (local, Notion, GitHub, docs)
# → Choose tag type (Context, Summary, Spec, Reference)
# → Auto-generates comprehensive summary

# Start of session
/context:load-context "authentication implementation"
# → Choose source to search
# → Select and load previous context

# Mid-task checkpoint
/context:checkpoint "before-refactor"
# → Fast save without prompts

# Check status
/context:context-status
# → Shows recent saves and checkpoints

# Continue a plan
/context:plan
# → Browse and load recent plans
```

#### Requirements

- **Optional:** Notion MCP server for Notion destinations
- **Optional:** GitHub CLI (`gh`) for GitHub Issue destinations

---

### design

**Figma Make design-to-code workflow integration.**

Create and manage prompts/changelogs in Notion for Figma Make, enabling design-to-code workflows with proper documentation and iteration tracking.

#### Commands

| Command | Description |
|---------|-------------|
| `/design:make` | Create or update prompts/changelogs in Notion for Figma Make |

#### Workflow

```
1. Create Spec
   ↓
   /context:save-context (tag: Spec)
   ↓
2. Create Prompt
   ↓
   /design:make (references saved spec)
   ↓
3. Figma Make Implementation
   ↓
4. Iteration (repeat /make for updates)
```

#### Prompt Best Practices

When creating prompts for Figma Make:
- Specify **full file paths** (e.g., `src/components/` not `components/`)
- Note file sizes if large (>30KB)
- List ALL files that need modification together
- Provide exact code snippets to insert
- Include verification steps
- Link to related context/specs in Notion

#### Requirements

- **Notion MCP server** configured in Claude Code
- **Notion database** for storing prompts (default name: `_make`)

---

### dev

**Git workflows, PR management, and development automation.**

Streamline git operations with conventional commits, PR descriptions, code reviews, and release management.

#### Commands

| Command | Description |
|---------|-------------|
| `/dev:commit` | Full commit workflow with branch management and PR updates |
| `/dev:pr-describe` | Generate/update PR description from all changes since main |
| `/dev:pr-review` | Request AI code review via GitHub comment (@claude or @codex) |
| `/dev:release <version>` | Create semver release with tag and GitHub release notes |
| `/dev:kill-port <port>` | Check and kill processes using specific ports |
| `/dev:resolve` | Interactive merge conflict resolution with AI assistance |

#### Commit Workflow

```bash
# After making code changes
/dev:commit

# What it does:
# 1. Checks if branch PR was already merged (prevents lost commits)
# 2. Detects multi-repo scenarios
# 3. Shows what will be committed
# 4. Generates conventional commit message
# 5. Updates PR description if PR exists
# 6. Pushes with confirmation
```

#### Commit Message Format

```
type: brief description (50 chars max)
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Code restructure
- `test:` - Tests
- `chore:` - Maintenance

#### Release Workflow

```bash
# Patch version (1.6.0 → 1.6.1)
/dev:release patch

# Minor version (1.6.0 → 1.7.0)
/dev:release minor

# Major version (1.6.0 → 2.0.0)
/dev:release major

# Explicit version
/dev:release 2.1.0
```

#### Merge Conflict Resolution

```bash
/dev:resolve

# Interactive workflow:
# 1. Detects conflicts in current repo
# 2. Shows each conflict with context
# 3. Offers resolution strategies
# 4. Implements chosen resolution
# 5. Continues to next conflict
```

#### Requirements

- **GitHub CLI** (`gh`) installed and authenticated
- Git repository with remote configured

---

### obsidian

**Capture screenshots and context to Obsidian Zettelkasten vault as fragment notes.**

Quickly save screenshots with analysis and context to your Obsidian vault, supporting the Zettelkasten method of knowledge management. Also save external links to note tables.

#### Commands

| Command | Description |
|---------|-------------|
| `/obsidian:capture [folder]` | Capture screenshot with context and create fragment note |
| `/obsidian:save-link <url> [note-path]` | Save external link to note's external links table |

#### Workflow

**Capture Screenshot:**
```bash
# Share a screenshot in chat (Slack, Figma, browser, etc.)
[Paste screenshot]
https://life-in-flow.slack.com/archives/...

# Capture it
/obsidian:capture flow

# What it does:
# 1. Analyzes the screenshot content
# 2. Asks for topic/title (e.g., "property-filters-ui")
# 3. Copies screenshot to {vault}/{folder}/_attachments/{topic}.png
# 4. Creates fragment note with embedded image and analysis
# 5. Includes external links (Slack, Figma, etc.)
# 6. Returns note path
```

**Save External Links:**
```bash
# Save a link with prompts
/obsidian:save-link https://anthropic.com/research/constitutional-ai

# Or specify the note path directly
/obsidian:save-link https://example.com/article ai/outlinks

# What it does:
# 1. Prompts for link title/description
# 2. Prompts for note path (if not provided)
# 3. Optionally asks for tags and notes
# 4. Saves to external links table in the note
# 5. Creates note if it doesn't exist
# 6. Auto-adds source tag from domain (e.g., "source/anthropic")
```

#### Fragment Lifecycle

Fragments are temporary captures in the Zettelkasten method:
1. **Capture** - Quickly save ideas/screenshots (this plugin)
2. **Process** - Review and convert to atomic primitives
3. **Connect** - Link primitives to build knowledge graph

Use `mcp__obsidian-zettelkasten__process_fragment` to convert fragments to primitives later.

#### Use Cases

- **Design discussions** - Capture Figma screenshots with Slack context
- **Code reviews** - Save code snippets with PR comments
- **Meeting notes** - Capture whiteboard photos with decisions
- **Bug reports** - Screenshot error states with context

#### Requirements

- **Obsidian MCP server** configured and running
- **Obsidian vault** accessible at configured path
- Screenshots pasted in Claude Code (auto-cached)

---

### swarm

**Multi-agent orchestration with autonomous workflows and ACE context management.**

Enable parallel code analysis with specialized AI agents and autonomous research-plan-implement workflows for complex tasks.

#### Commands

| Command | Description |
|---------|-------------|
| `/swarm:auto <goal>` | Autonomous workflow - research, plan, implement with checkpoints |
| `/swarm:auto --resume` | Resume from most recent checkpoint |
| `/swarm:swarm [preset]` | Start multi-agent swarm with preset or auto-detect |
| `/swarm:spawn <agent>` | Spawn a single background agent for specific analysis |
| `/swarm:hive` | Check status and findings from all running agents |
| `/swarm:health` | Check context health metrics and alerts |
| `/swarm:sync` | Consolidate findings into prioritized action items |
| `/swarm:fix` | Interactive mode to address swarm findings one by one |
| `/swarm:stop [agent]` | Stop one or all running agents |
| `/swarm:checkpoint [label]` | Create checkpoint during /auto sessions |
| `/swarm:handoff` | Prepare handoff when approaching context limits |
| `/swarm:resume` | Resume from a prior checkpoint or auto phase |
| `/swarm:compact` | Export session then compact working memory |

#### Autonomous Workflow

For complex tasks requiring research, planning, and implementation:

```bash
/swarm:auto "add user authentication with OAuth"

# Phase 1: Research
# - Explores codebase in isolated context
# - Produces structured findings
# - Saves checkpoint

# Phase 2: Plan
# - Creates phase-by-phase implementation blueprint
# - Waits for human approval (high leverage point)
# - Saves plan checkpoint

# Phase 3: Implement
# - Executes plan phase by phase
# - Auto-saves checkpoints after each phase
# - Monitors context usage

# Resume interrupted session
/swarm:auto --resume
```

#### Parallel Analysis Workflow

For code review and quality analysis:

```bash
# Auto-detect project and recommend agents
/swarm:swarm

# Or use a preset
/swarm:swarm review

# Check agent status and findings
/swarm:hive

# Consolidate all findings
/swarm:sync

# Fix issues interactively
/swarm:fix

# Stop when done
/swarm:stop
```

#### Available Presets

| Preset | Agents | Use Case |
|--------|--------|----------|
| `review` | reviewer, simplifier, comment-analyzer | General code review |
| `quality` | reviewer, type-analyzer, test-analyzer | Code quality & correctness |
| `security` | silent-hunter, reviewer | Error handling & safety |
| `cleanup` | simplifier, comment-analyzer | Tech debt reduction |
| `full` | All agents | Comprehensive analysis |
| `figma` | reviewer, type-analyzer, silent-hunter | Figma plugin development |

#### Available Agents

**Analysis Agents:**
| Agent | Focus | Best For |
|-------|-------|----------|
| `reviewer` | Code quality, patterns, best practices | Any project |
| `simplifier` | Complexity reduction, DRY violations | Refactoring, brownfield |
| `type-analyzer` | TypeScript type safety | TypeScript projects |
| `silent-hunter` | Unhandled async, silent failures | Async code, error handling |
| `comment-analyzer` | TODOs, FIXMEs, documentation debt | Cleanup, documentation |
| `test-analyzer` | Test coverage and quality | Testing improvements |

**Orchestration Agents:**
| Agent | Focus | Best For |
|-------|-------|----------|
| `researcher` | Deep codebase exploration | /auto research phase |
| `coordinator` | Prioritize and group issues | Multi-agent coordination |

#### Context Health Monitoring

```bash
/swarm:health

# Shows metrics:
# - File reads (threshold: 50)
# - Code edits (threshold: 30)
# - Message weight (threshold: 30)
# - Alert level (GOOD → WATCH → WARNING → CRITICAL)
```

**Automatic Features:**
- Health metrics tracked via hooks
- Checkpoints saved at 40%, 60%, 70% thresholds
- Emergency saves before auto-compact (80%)
- Graceful completion when nearing limits

#### Shared State Directory

Agents communicate through `.claude/swarm/`:

```
.claude/swarm/
├── research/       # /auto Phase 1 outputs
├── plans/          # /auto Phase 2 outputs
├── progress/       # Checkpoints (auto + agents)
├── reports/        # Agent findings (timestamped)
├── issues/         # Extracted issues
├── context/        # Shared state
├── logs/           # Agent logs
├── pids/           # Process IDs
└── sync/           # Consolidated reports
```

#### Interactive Fix Mode

```bash
/swarm:fix

# Workflow:
# 1. Shows issue and current code
# 2. Offers: Fix, Skip, or View more context
# 3. Implements fix and shows diff
# 4. Continues to next issue
# 5. Tracks progress through queue
```

#### Requirements

- **Claude Code** with plugin support
- `--dangerously-skip-permissions` enabled for background agents
- **Platforms:** macOS, Linux, Windows (PowerShell, Git Bash, or WSL)

---

## Complete Workflow Examples

### End-to-End Design Implementation

```bash
# 1. Create and save spec
# (Work with Claude Code to create detailed spec)
/context:save-context
# → Select: Notion
# → Tag: Spec
# → Title: "User authentication flow"

# 2. Create Figma Make prompt
/design:make
# → References saved spec
# → Creates implementation prompt

# 3. (Figma Make implements the design)

# 4. Review with swarm
/swarm:swarm review

# 5. Check findings
/swarm:hive

# 6. Fix issues
/swarm:fix

# 7. Commit changes
/dev:commit

# 8. Create release
/dev:release minor
```

### Autonomous Complex Feature

```bash
# Start autonomous workflow
/swarm:auto "implement OAuth authentication with Google and GitHub"

# → Research phase (explores codebase)
# → Plan phase (creates blueprint, waits for approval)
# → Implement phase (executes with checkpoints)

# If interrupted, resume
/swarm:auto --resume

# Check context health anytime
/swarm:health

# Final commit
/dev:commit
```

### Code Quality Audit

```bash
# 1. Start comprehensive analysis
/swarm:swarm full

# 2. Monitor progress
/swarm:hive

# 3. Consolidate findings
/swarm:sync

# 4. Address issues interactively
/swarm:fix

# 5. Save findings for later
/context:save-context
# → Tag: Summary
# → Title: "Q4 2024 code audit"

# 6. Stop agents
/swarm:stop
```

### Context Management Pattern

```bash
# During work - checkpoint frequently
/context:checkpoint "before-database-refactor"

# Mid-session - check context health
/swarm:health

# When warned - save and compact
/swarm:compact

# End of session - comprehensive save
/context:save-context

# Next session - resume
/context:load-context "database refactor"
```

## Setup Requirements

### Core Requirements

- **Claude Code** with plugin support

### Optional MCP Servers

#### Notion MCP Server

Required for: `context` (Notion destinations), `design`

Add to `~/.claude/.claude.json` under `mcpServers`:

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

Authenticate via Notion when prompted.

**Notion Database Setup:**

For `context`, create database named `_clawd` with:
- **Name** (title) - Context title
- **Project** (select) - Project name
- **Tags** (multi-select) - Context, Summary, Spec, Reference

For `design`, create database named `_make` with:
- **Name** (title) - Prompt title
- **Type** (select) - Prompt, Changelog
- **Project** (select) - Project name

#### GitHub CLI

Required for: `dev`

```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Windows
winget install GitHub.cli

# Authenticate
gh auth login
```

### Platform-Specific Notes

#### swarm Requirements

- **macOS/Linux:** bash or zsh (default)
- **Windows:** PowerShell (default on Windows 10+), Git Bash, or WSL
  - Note: cmd.exe is not supported
- **Permissions:** `--dangerously-skip-permissions` enabled

## Customization

### Database Names

Update database names and data source IDs in command files:

**context:**
- Default database: `_clawd`
- Update in: `commands/save-context.md`

**design:**
- Default database: `_make`
- Update in: `commands/make.md`

### Agent Behavior

Customize agent focus by editing files in:
- `plugins/swarm/agents/reviewer.md`
- `plugins/swarm/agents/silent-hunter.md`
- `plugins/swarm/agents/type-analyzer.md`
- etc.

### Custom Swarm Presets

Add custom presets to `plugins/swarm/commands/swarm.md`:

```json
{
  "agents": ["reviewer", "custom-agent"],
  "watch": "src/**/*.{ts,tsx}",
  "focus": "Your specific focus area"
}
```

## Plugin Development

See [docs/ADDING_PLUGINS.md](docs/ADDING_PLUGINS.md) for how to contribute new plugins to this marketplace.

## Plugin Updates

Plugins follow semantic versioning. Check the marketplace for updates:

```bash
/plugin marketplace update claude-code-workflows
```

Current versions:
- **context:** 1.8.1
- **design:** 1.8.1
- **dev:** 1.8.1
- **obsidian:** 1.2.0
- **swarm:** 1.8.1

## Contributing

Contributions welcome! Please:
1. Follow existing plugin structure
2. Include comprehensive README in plugin directory
3. Add examples and workflow documentation
4. Test thoroughly before submitting PR

## License

MIT
