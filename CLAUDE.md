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

**Triggers in calling workflows**:
- `pull_request: types: [opened, synchronize]`

**Key Features**:
- Customizable allowed tools
- Optional file pattern filtering
- OpenRouter or Anthropic API support
- Configurable model selection

### 2. Claude Code (`claude.yml`)
**Purpose**: Interactive assistance, code review, and issue planning via mentions and assignments

**Triggers in calling workflows**:
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

**Triggers in calling workflows**:
- `schedule` (cron-based scheduling)
- `workflow_dispatch` (manual triggering)

**Key Features**:
- **Custom Prompts**: Execute any prompt on a schedule
- **Full Tool Access**: Configure allowed tools, plugins, MCP servers
- **Flexible Scheduling**: Nightly, hourly, weekly, or custom cron
- **Plugin Support**: Install Claude Code plugins from marketplaces
- **MCP Configuration**: Custom MCP server setup via JSON
- **Extended Timeouts**: Configurable timeout for long-running tasks

**Use Cases**:
- Nightly code reviews with issue creation
- Hourly issue processing and PR creation
- Weekly dependency audits
- Automated documentation updates
- Repository maintenance tasks

## Project Structure

```
github-actions/
├── .github/workflows/
│   ├── claude-code-review.yml      # Reusable code review workflow
│   ├── claude.yml                   # Reusable interactive workflow
│   └── claude-schedule.yml          # Reusable scheduled task workflow
├── examples/
│   └── integration-workflows/       # Example implementations
│       ├── claude-code-review-example.yml
│       ├── claude-example.yml
│       ├── claude-schedule-nightly-example.yml
│       └── claude-schedule-hourly-example.yml
├── CLAUDE.md                        # This file
└── README.md                        # User documentation
```

## Configuration Management

### Cross-Repo Reusability Pattern

This repository uses a **hybrid configuration approach** to support both same-repo and cross-repo usage:

1. **`.github/claude-defaults.json`** - Source of truth for configuration (used when available)
2. **`.github/actions/claude-setup/action.yml`** - Composite action with fallback defaults
3. **Inline fallbacks** - Built-in defaults when config file doesn't exist (cross-repo)

#### Cross-Repo Usage

When other repositories use these workflows, they work **without any setup**:

```yaml
jobs:
  nightly-analysis:
    uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
    with:
      prompt: |
        # Nightly Codebase Analysis
        Analyze the codebase and create issues for bugs, security issues, or tech debt.
    secrets:
      api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

**What happens automatically:**
- ✅ Uses fallback defaults when config files don't exist in caller's repo
- ✅ Bot identity, model, provider all use sensible defaults
- ✅ Tool profiles selected based on workflow type
- ✅ MCP configuration uses inline fallback
- ✅ Plugin marketplace defaults to `duyet/claude-plugins.git`

#### Customization Options

**Option 1: Use defaults (recommended for quick start)**
```yaml
uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
```

**Option 2: Override specific values**
```yaml
uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
  with:
    prompt: 'My custom prompt'
    mcp_config: '{"mcpServers":{"my-server":{"command":"path","args":[]}}'
    timeout_minutes: '120'
```

**Option 3: Fork and customize**
1. Fork this repository
2. Edit `.github/claude-defaults.json` with your defaults
3. Update `claude-setup/action.yml` defaults if needed
4. Use your fork in workflows: `your-org/github-actions/.github/workflows/claude-schedule.yml@main`

#### Composite Action for Workflow Creators

If you're creating workflows in THIS repository, use the composite action:

```yaml
steps:
  - uses: actions/checkout@v6

  - uses: ./.github/actions/claude-setup@main
    id: claude-setup
    with:
      workflow_type: 'schedule'  # or 'review', 'interactive', 'plan'

  - uses: anthropics/claude-code-action@v1
    env:
      ANTHROPIC_BASE_URL: ${{ steps.claude-setup.outputs.provider_base_url }}
      ANTHROPIC_DEFAULT_HAIKU_MODEL: ${{ steps.claude-setup.outputs.model }}
    with:
      bot_id: ${{ steps.claude-setup.outputs.bot_id }}
      bot_name: ${{ steps.claude-setup.outputs.bot_name }}
      allowed_tools: ${{ steps.claude-setup.outputs.allowed_tools }}
      mcp_config: ${{ steps.claude-setup.outputs.mcp_config }}
      plugin_marketplaces: ${{ steps.claude-setup.outputs.plugin_marketplaces }}
```

### Input Types
- **allowed_tools**: Restrict which Claude tools can be used
- **file_patterns**: Filter which files to review
- **provider**: Choose between 'openrouter', 'anthropic', or 'zai' APIs
- **model**: Specify model to use
- **bot_id/bot_name**: Customize bot identity
- **prompt**: Custom prompt for scheduled tasks (claude-schedule.yml)
- **plugins**: Claude Code plugins to install (claude-schedule.yml)
- **plugin_marketplaces**: Plugin marketplace URLs (claude-schedule.yml)
- **mcp_config**: MCP server configuration (claude-schedule.yml)
- **settings**: Claude Code settings JSON (claude-schedule.yml)
- **claude_args**: Additional CLI arguments (claude-schedule.yml)
- **max_turns**: Maximum conversation turns (claude-schedule.yml)
- **timeout_minutes**: Job timeout in minutes (claude-schedule.yml)

### Secret Management
- **api_key**: Required secret from calling workflow
- Must be provided via `secrets:` in `uses:` statement

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

## Contributing

### Adding New Workflows
1. Create workflow in `.github/workflows/` with `workflow_call` trigger
2. Parameterize all configurable values
3. Add example calling workflow to `examples/`
4. Update README.md with usage instructions
5. Test with example project

### Updating Existing Workflows
1. Maintain backward compatibility
2. Add new inputs with sensible defaults
3. Update documentation
4. Test with existing calling workflows

## Version Management

- Use semantic versioning for releases
- Tag releases: `v1.0.0`, `v1.1.0`, etc.
- Calling workflows should use tagged releases: `@v1` or `@main`
- Maintain changelog of breaking changes

## Troubleshooting

### Common Issues
- **Workflow not triggering**: Check `if:` condition and trigger events
- **API key not found**: Verify secret name in calling workflow matches
- **Claude tool errors**: Check `allowed_tools` includes necessary tools
- **Model not found**: Verify `model` matches available models for the provider

## Related Documentation
- [GitHub Actions Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Claude Code Action](https://github.com/anthropics/claude-code-action)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
