# Claude Code Workflows

A curated collection of Claude Code plugins with slash commands for design-to-code workflows, context management, multi-agent orchestration, and development best practices.

## Installation

1. Run `/plugin`
2. Select **Add Marketplace**
3. Enter marketplace source: `arevlo/claude-code-workflows`
4. Select which plugins to install

Or use commands directly:
```bash
# Add marketplace
/plugin marketplace add arevlo/claude-code-workflows

# Install specific plugins
/plugin install arevlo-design@claude-code-workflows
/plugin install arevlo-context@claude-code-workflows
/plugin install arevlo-dev@claude-code-workflows
/plugin install arevlo-swarm@claude-code-workflows
/plugin install clawd-eyes@claude-code-workflows
```

## Updating

1. Run `/plugin`
2. Select **Manage Marketplaces**
3. Select `claude-code-workflows` and choose **Update**
4. Go back and select **Browse and Install Plugins** to install any new plugins

> **Note:** If you don't see a plugin after updating, go to **Browse and Install Plugins** and install it manually.

Or use commands:
```bash
/plugin marketplace update claude-code-workflows
```

## Plugins

### arevlo-design

Slash commands for Figma Make design-to-code workflows.

- `/make` - Create or update prompts/changelogs in Notion for Figma Make

> **Requires:** [Notion MCP server](#notion-mcp-setup)

### arevlo-context

Slash commands for saving/loading Claude Code session context and plans.

- `/save-context` - Save session to local, Notion, GitHub, or docs/plans folder
- `/load-context` - Search and load prior context from multiple sources
- `/plan` - Load, save, or browse Claude Code plans

> **Requires:** [Notion MCP server](#notion-mcp-setup) for Notion destinations

### arevlo-dev

Git commit workflows and development best practices.

- `/commit` - Full commit workflow with branch management
- `/pr-describe` - Generate/update PR descriptions
- `/pr-review` - Request AI code review
- `/release <version>` - Create semver release with tag and GitHub release
- `/kill-port` - Check and kill processes using specific ports
- `/resolve` - Resolve merge conflicts interactively

> **Requires:** [GitHub CLI](#github-cli-setup)

### arevlo-swarm

Multi-agent orchestration for parallel code analysis. Works with any project type.

- `/swarm [preset]` - Start swarm (auto-detects project or use preset)
- `/auto <goal>` - Autonomous workflow - research, plan, and implement with minimal interruption
- `/spawn <agent>` - Spawn a single background agent
- `/hive` - Check status and findings from all agents
- `/fix` - Interactive fix mode - address swarm findings one by one
- `/sync` - Consolidate findings into prioritized action items
- `/stop [agent]` - Stop one or all running agents

**Presets:** `review`, `quality`, `security`, `cleanup`, `full`, `figma`

**Agents:** reviewer, simplifier, type-analyzer, silent-hunter, comment-analyzer, test-analyzer

> **Requires:** `--dangerously-skip-permissions` enabled

### clawd-eyes

> **⚠️ In Development:** This plugin is still being developed. The repository is not yet publicly available.

Visual browser inspector for Claude Code. Control the clawd-eyes servers.

- `/clawd-eyes:start` - Start backend and web UI servers
- `/clawd-eyes:stop` - Stop all servers (kills processes on ports 4000, 4001, 5173, 9222)
- `/clawd-eyes:status` - Check if servers are running
- `/clawd-eyes:watch` - Watch for design requests from web UI
- `/clawd-eyes:open` - Open web UI in browser

> **Requires:** clawd-eyes project installed locally (not yet available)

## Workflows

### Design Workflow (Figma Make)

```
Claude Code               Notion                  Figma Make
    |                       |                         |
    |-- Create spec ------->|                         |
    |                       |                         |
    |-- /save-context ----->| (save as Spec)          |
    |                       |                         |
    |-- /make ------------->| (reference spec) ------>|
    |                       |                         |
    |                       |<-- iterate -------------|
    |                       |                         |
    |                       |<-- push to GitHub ------|
```

1. **Create Spec** - Give Claude Code instructions for the feature/design
2. **Save as Spec** - `/save-context` with "Spec" tag type
3. **Create Prompt** - `/make` references the saved spec
4. **Iterate** - Use Figma Make to implement and refine

> **Note:** Figma Make pushes directly to GitHub. Committing happens separately in Claude Code.

### Multi-Agent Workflow (Swarm)

```
/swarm                    Background Agents         Your Session
    |                           |                       |
    |-- auto-detect project --->|                       |
    |-- spawn agents ---------->|                       |
    |                           |                       |
    |                           |-- analyze code ------>|
    |                           |-- write reports ----->|
    |                           |                       |
    |<-- /hive (check status) --|                       |
    |<-- /sync (consolidate) ---|                       |
```

1. **Start swarm** - `/swarm` auto-detects, or `/swarm review` for a preset
2. **Work normally** - Agents analyze in background
3. **Check progress** - `/hive` to see findings
4. **Consolidate** - `/sync` for prioritized action list
5. **Stop** - `/stop` when done

### Commit Workflow

```
/commit
```

Run after making code changes:
- Stage and commit changes
- Update PR description if PR exists
- Push with confirmation

### Context Management

| Command | Purpose |
|---------|---------|
| `/save-context` | Save session context to local, Notion, GitHub, or docs/plans |
| `/load-context <query>` | Search and load prior contexts from multiple sources |

### Dev Workflows

| Command | Purpose |
|---------|---------|
| `/pr-describe` | Generate/update PR description |
| `/pr-review` | Request @claude or @codex review |
| `/release <version>` | Create semver release (patch, minor, major, or explicit) |
| `/kill-port` | Check and kill processes on specific ports |

## Requirements

- **Claude Code** with plugin support

### Notion MCP Setup

Add to your `~/.claude/.claude.json` under `mcpServers`:

```json
"notion": {
  "type": "http",
  "url": "https://mcp.notion.com/mcp"
}
```

Then authenticate via Notion when prompted.

### GitHub CLI Setup

```bash
# Install
brew install gh

# Authenticate
gh auth login
```

## Customization

Most plugins reference specific Notion database names and data source IDs. Update these in the command files to match your own setup:

1. Database names (default: `_make`, `_clawd`)
2. Data source IDs
3. Project name mappings

For swarm agents, customize behavior by editing files in `plugins/arevlo-swarm/agents/`.

## Contributing

See [docs/ADDING_PLUGINS.md](docs/ADDING_PLUGINS.md) for how to add new plugins.

## License

MIT
