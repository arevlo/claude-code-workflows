# Dev Workflows

Git workflows, branch management, PR lifecycle, worktree operations, and development best practices.

## Installation

```
/plugin marketplace add arevlo/claude-code-workflows
/plugin install dev@claude-code-workflows
```

## What's Included

### Commands
- `/commit` - Full commit workflow with branch management and PR updates
- `/checkout` - Check out existing or new branches with interactive picker
- `/push` - Push to remote with first-push detection and optional PR creation
- `/pull` - Pull latest changes with stash handling and conflict resolution
- `/merge` - Merge PRs with review request, strategy selection, and admin bypass
- `/pr-describe` - Generate/update PR description from all changes
- `/pr-review` - Request AI code review via GitHub comment
- `/kill-port` - Check and kill processes using specific ports
- `/port-list` - Show all listening TCP ports with process info
- `/release` - Create a semver release with tag and GitHub release notes
- `/resolve` - Interactively resolve git merge conflicts
- `/cubic-resolve` - Fix Cubic, Codex, CodeQL, and Copilot Autofix PR findings
- `/test-and-fix` - Pre-CI gate: scaffold tests if missing, run the local check ladder (typecheck → lint → build → integration → smoke → e2e), and loop fix-and-rerun until green. Smoke uses agent-browser via `dev:test-smoke`.
- `/worktree-select` - Pick an existing worktree or create a new one
- `/worktree-commit` - Commit and push from a worktree, then continue or tear down
- `/worktree-sync` - Rebase worktree branch onto latest main
- `/worktree-clean` - Batch-remove stale worktrees with merged/closed PRs

## Requirements

- **GitHub CLI** (`gh`) installed and authenticated
- Git repository with remote configured

## Usage

### End of Work Session
```
/commit
```
Handles:
- Multi-repo detection
- Branch status checks
- Conventional commit generation
- PR description updates
- Push with confirmation

### Branch Management
```
/checkout feat-new-feature   # Create new branch
/checkout                    # Switch to main or pick from recent branches
/push                        # Push and optionally create PR
/pull                        # Pull latest, with stash handling
/pull main                   # Incorporate main into current branch
/merge                       # Merge PR with strategy selection
```

### Update PR Description
```
/pr-describe
```
- Analyzes all changes from main
- Generates structured PR description
- Updates existing PR

### Request Code Review
```
/pr-review
```
- Posts comment to trigger AI reviewer
- Supports @claude and @codex

### Fix Review Findings
```
/cubic-resolve
```
- Fetches Cubic, Codex, CodeQL, and Copilot Autofix findings
- Triages and applies fixes
- Commits and replies to resolved threads

### Worktree Workflows
```
/worktree-select             # Pick or create a worktree
/worktree-commit             # Commit from worktree, optionally tear down
/worktree-sync               # Rebase onto latest main
/worktree-clean              # Remove stale worktrees
```

## Commit Message Format

```
type: brief description (50 chars max)
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Code restructure
- `test:` - Tests
- `chore:` - Maintenance

## Customization

**Branch naming:** The `/commit` and `/checkout` commands use `<git-username>.<type>-<description>` format by default. Update the command files if your organization uses a different convention.

## Zsh Aliases (Optional)

Add to `~/.zshrc`:
```bash
alias ccc="claude --continue"
alias ccr="claude --resume"
```
