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

## Project Structure

```
github-actions/
├── .github/workflows/
│   ├── claude-code-review.yml      # Reusable code review workflow
│   └── claude.yml                   # Reusable interactive workflow
├── examples/
│   └── integration-workflows/       # Example implementations
│       ├── claude-code-review-example.yml
│       └── claude-example.yml
├── CLAUDE.md                        # This file
└── README.md                        # User documentation
```

## Configuration Management

### Input Types
- **allowed_tools**: Restrict which Claude tools can be used
- **file_patterns**: Filter which files to review
- **provider**: Choose between 'openrouter' or 'anthropic' APIs
- **model**: Specify model to use
- **bot_id/bot_name**: Customize bot identity

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
