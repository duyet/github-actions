# CLAUDE.md - GitHub Actions Workflows Project Guidelines

## Project Overview

This repository contains reusable GitHub Actions workflows powered by Claude AI for code review, analysis, and interactive task handling.

## Development Principles

### Code Quality
- **SOLID Principles**: Follow Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion
- **DRY**: Avoid duplication across workflows
- **KISS**: Keep workflows simple and focused
- **YAGNI**: Only implement required features, no speculative additions

### Workflow Design
- **Reusability**: All workflows should be in `.github/workflows/` using `workflow_call` trigger
- **Parameterization**: Expose configuration through `inputs` rather than hardcoding values
- **Security**: Never expose secrets in logs; use environment variables for sensitive data
- **Documentation**: Every workflow must have clear input/secret descriptions

### Security Standards
- API keys and credentials go only in GitHub Secrets
- No hardcoded sensitive values in workflow files
- Validate all external inputs using allowed tools
- Use least-privilege permissions (minimal `permissions:` block)

## Workflow Types

### 1. Claude Code Review (`claude-code-review.yml`)
**Purpose**: Automated code review on pull requests

**Triggers**: `pull_request: types: [opened, synchronize]`

**Key Features**:
- Customizable allowed tools
- Optional file pattern filtering
- OpenRouter or Anthropic API support
- Configurable model selection

### 2. Claude Code (`claude.yml`)
**Purpose**: Interactive assistance, code review, and issue planning via mentions and assignments

**Triggers**:
- `pull_request` (assignment: code review)
- `pull_request_review_comment` (@mention: interactive help)
- `pull_request_review` (@mention: interactive help)
- `issue_comment` (@mention: interactive help)
- `issues` (assignment: plan/analysis, opened with @mention: interactive help)

**Key Features**:
- **Code Review**: Auto-review when PR is assigned to @duyetbot
- **Interactive Help**: Responds to @claude or @duyetbot mentions in comments
- **Issue Planning**: Analyzes issues and comments with plan when assigned
- Multiple independent jobs for different use cases
- Configurable bot identity, model, and allowed tools

### 3. Claude Schedule (`claude-schedule.yml`)
**Purpose**: Scheduled automated tasks with custom prompts

**Triggers**: `schedule` (cron), `workflow_dispatch` (manual)

**Key Features**:
- Custom prompts for any scheduled task
- Full tool access with configurable restrictions
- Plugin and MCP server support
- Extended timeouts for long-running tasks

**Use Cases**: Nightly code reviews, hourly issue processing, weekly dependency audits, automated documentation updates

## Project Structure

```
github-actions/
├── .github/
│   ├── workflows/
│   │   ├── claude-code-review.yml      # Reusable code review workflow
│   │   ├── claude.yml                   # Reusable interactive workflow
│   │   ├── claude-schedule.yml          # Reusable scheduled task workflow
│   │   └── claude-nightly-analysis.yml  # Pre-configured nightly analysis
│   ├── actions/
│   │   └── claude-setup/
│   │       └── action.yml               # Composite action for config loading
│   ├── claude-defaults.json             # Single source of truth for config
│   └── mcp-config.json                  # MCP server configuration
├── examples/
│   └── integration-workflows/           # Example implementations
├── CLAUDE.md                            # This file (project guidelines)
└── README.md                            # User documentation
```

## Configuration Management

### Cross-Repo Reusability

This repository uses a **hybrid configuration approach** with fallback defaults:

1. **`.github/claude-defaults.json`** - Source of truth (used when available)
2. **`.github/actions/claude-setup/action.yml`** - Composite action with fallback defaults
3. **Inline fallbacks** - Built-in defaults for cross-repo usage

**Cross-repo workflows work without any setup in the caller's repository.**

```
┌─────────────────────────────────────────────────────────────────────┐
│ Cross-Repo Usage Pattern                                            │
├─────────────────────────────────────────────────────────────────────┤
│  Caller Repo (other-org/their-repo)                                 │
│  └── uses: duyet/github-actions/.github/workflows/claude-schedule.yml│
│                                                                      │
│  duyet/github-actions (this repo)                                   │
│  └── .github/actions/claude-setup/action.yml                        │
│      ├── Try: Read .github/claude-defaults.json                     │
│      ├── File not found in caller? → Use fallback defaults ✅        │
│      └── Output: All configuration values                           │
└─────────────────────────────────────────────────────────────────────┘
```

### Configuration File: `.github/claude-defaults.json`

```json
{
  "bot": { "id": "101855044", "name": "duyetbot" },
  "api": { "default_provider": "openrouter", "default_model": "@preset/claude-code-github-action" },
  "plugins": { "marketplaces": ["https://github.com/duyet/claude-plugins.git"] },
  "mcp": {
    "default_config_path": ".github/mcp-config.json",
    "default_inline_config": { "mcpServers": { ... } }
  },
  "timeouts": { "interactive": 30, "schedule": 60, "review": 30, "plan": 45 },
  "tool_profiles": {
    "review": "Read,Grep,Glob,Bash,Plan",
    "interactive": "Read,Grep,Glob,Bash,Write,Edit,Skill,..."
  }
}
```

### Input Types
| Input | Description |
|-------|-------------|
| `allowed_tools` | Restrict which Claude tools can be used |
| `file_patterns` | Filter which files to review |
| `provider` | Choose between 'openrouter', 'anthropic', or 'zai' APIs |
| `model` | Specify model to use |
| `bot_id`/`bot_name` | Customize bot identity |
| `prompt` | Custom prompt for scheduled tasks |
| `plugins` | Claude Code plugins to install |
| `plugin_marketplaces` | Plugin marketplace URLs |
| `mcp_config` | MCP server configuration |
| `timeout_minutes` | Job timeout in minutes |

### Secret Management
- **api_key**: Required - OpenRouter or Anthropic API key
- **bot_github_token**: Optional - GitHub PAT for enhanced permissions (creating issues/PRs)

## Maintenance

### MCP Configuration

The `.github/mcp-config.json` file is the canonical source for MCP server configuration.

**Reusable workflows cannot read files from this repo when called cross-repo**, so inline fallback is used in the composite action.

**Adding a new MCP server:**
1. Edit `.github/mcp-config.json`
2. Edit `.github/claude-defaults.json` → `mcp.default_inline_config`
3. Validation workflow checks sync on PRs

| Workflow | MCP Config Source |
|----------|-------------------|
| `claude.yml` | `.github/mcp-config.json` file |
| `claude-code-review.yml` | `.github/mcp-config.json` file |
| `claude-schedule.yml` | Inline fallback from composite action |

### Plugin Marketplace

Default: `https://github.com/duyet/claude-plugins.git`

To change: Edit `.github/claude-defaults.json` → `plugins.marketplaces`

### Updating Configuration

| Task | Steps |
|------|-------|
| Change bot name | Edit `claude-defaults.json` → `bot.name` |
| Add MCP server | Edit `mcp-config.json` + `claude-defaults.json` |
| Add workflow type | Add to `tool_profiles` and `timeouts` |
| Change plugin marketplace | Edit `plugins.marketplaces` |

### Commit Signing

The `issue-plan` job uses `use_commit_signing: true` for verified commits.
- Trade-off: Cannot perform complex git operations (rebase, etc.)
- Alternative: Use SSH signing key for full git operations

## Best Practices

### For Workflow Creators
1. Always provide `defaults` for optional inputs
2. Document all inputs with clear descriptions
3. Use `env:` blocks to manage complex values
4. Test workflows with example calling workflows
5. Pin versions: `uses: anthropics/claude-code-action@v1`

### For Workflow Users
1. Copy example from `examples/integration-workflows/`
2. Customize `inputs:` values for your use case
3. Provide `api_key` secret in `secrets:`
4. Test on a branch before deploying to main
5. Review Claude's suggestions before merging

### Security Checklist
- [ ] API key in GitHub Secrets, not in workflow file
- [ ] Minimal permissions required
- [ ] Input validation enabled (allowed_tools)
- [ ] No sensitive data in logs
- [ ] Review Claude tool restrictions

## Integration Guide

### Prerequisites
- GitHub repository with at least one commit
- Repository access to add GitHub Secrets
- OpenRouter or Anthropic API key

### Step 1: Get API Key

**OpenRouter (Recommended):**
1. Visit https://openrouter.ai/keys
2. Create API key (starts with `sk-or-v1-`)

**Anthropic:**
1. Visit https://console.anthropic.com/account/keys
2. Create API key (starts with `sk-ant-`)

### Step 2: Add Secret to GitHub

**Via Web UI:**
1. Repository → Settings → Secrets and variables → Actions
2. "New repository secret"
3. Name: `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
4. Value: Your API key

**Via CLI:**
```bash
gh secret set OPENROUTER_API_KEY --body "sk-or-v1-..."
```

### Step 3: Create Workflow

**Code Review Only** - `.github/workflows/review.yml`:
```yaml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

**Interactive + Automation** - `.github/workflows/claude.yml`:
```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]

jobs:
  claude:
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

### Step 4: Test

**Code Review:** Create a PR and watch Actions tab
**Interactive:** Comment `@duyetbot help` on an issue

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow not triggering | Check `if:` condition and trigger events |
| API key not found | Verify secret name matches in workflow |
| Claude tool errors | Check `allowed_tools` includes necessary tools |
| Model not found | Use `@preset/claude-code-github-action` |
| Workflow hangs/times out | Limit `file_patterns`, increase timeout |
| Invalid marketplace URL | Ensure URL ends with `.git` suffix |

**Debug failed runs:**
1. Actions tab → Click failed run → Expand step logs
2. Common issues: Invalid API key, tool not allowed, model not found

## Contributing

### Adding New Workflows
1. Create workflow in `.github/workflows/` with `workflow_call` trigger
2. Parameterize all configurable values
3. Add example to `examples/`
4. Update README.md
5. Test with example project

### Updating Existing Workflows
1. Maintain backward compatibility
2. Add new inputs with sensible defaults
3. Update documentation
4. Test with existing calling workflows

## Version Management

- Use semantic versioning for releases
- Tag releases: `v1.0.0`, `v1.1.0`, etc.
- Calling workflows should use: `@v1` or `@main`
- Maintain changelog of breaking changes

## Related Documentation

- [GitHub Actions Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Claude Code Action](https://github.com/anthropics/claude-code-action)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [MCP Specification](https://modelcontextprotocol.io/)
