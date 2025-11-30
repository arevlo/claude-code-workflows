# Dev Workflows

Git commit workflows, PR management, and development best practices.

## Installation

```
/plugin marketplace add arevlo/claude-code-workflows
/plugin install dev-workflows@claude-code-workflows
```

## What's Included

### Commands
- `/commit` - Full commit workflow with branch management and PR updates
- `/pr-describe` - Generate/update PR description from all changes
- `/pr-review` - Request AI code review via GitHub comment

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

## Zsh Aliases (Optional)

Add to `~/.zshrc`:
```bash
alias ccc="claude --continue"
alias ccr="claude --resume"
```
