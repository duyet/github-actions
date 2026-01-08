# GitHub Actions Reusable Workflows

🤖 Collection of reusable GitHub Actions workflows powered by Claude AI for code review, analysis, and interactive task handling.

## 🚀 Quick Start

### 1. Set Up API Key

First, add your API key to the target repository's GitHub Secrets:

#### For OpenRouter (Recommended)
```
Settings → Secrets and variables → Actions → New repository secret
Name: OPENROUTER_API_KEY
Value: sk-or-v1-...
```

#### For Anthropic
```
Settings → Secrets and variables → Actions → New repository secret
Name: ANTHROPIC_API_KEY
Value: sk-ant-...
```

### 2. Choose Your Workflow

#### Option A: Automatic Code Reviews
Copy this to `.github/workflows/claude-review.yml` in your repository:

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

#### Option B: Interactive Claude Assistance
Copy this to `.github/workflows/claude.yml` in your repository:

```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]
  issues:
    types: [opened, assigned]

jobs:
  claude:
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

#### Option C: Both Workflows
Add both configurations to your `.github/workflows/` directory.

## 📚 Available Workflows

### 1. Claude Code Review (`claude-code-review.yml`)

**Automatic code review on pull requests with customizable analysis.**

#### Triggers
- ✅ Pull request opened
- ✅ Pull request updated (new commits)

#### Configuration

```yaml
uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
secrets:
  api_key: ${{ secrets.OPENROUTER_API_KEY }}
with:
  # Optional: Comma-separated list of allowed Claude tools
  # Default: Read,Grep,Glob,Bash,Plan
  allowed_tools: 'Read,Grep,Glob,Bash,Plan'

  # Optional: File patterns to review (leave empty for all)
  # Example: 'src/**/*.ts,src/**/*.tsx,src/**/*.js'
  file_patterns: ''

  # Optional: Use OpenRouter (default: true) or Anthropic (false)
  openrouter_enabled: true

  # Optional: Model preset
  # Default: @preset/claude-code-github-action
  model_preset: '@preset/claude-code-github-action'
```

#### Review Criteria
Claude automatically reviews:
- ✓ Code quality and best practices
- ✓ Potential bugs or issues
- ✓ Performance considerations
- ✓ Security concerns
- ✓ Test coverage

#### Example: Review Only TypeScript Files

```yaml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/**/*.ts'
      - 'src/**/*.tsx'

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      allowed_tools: 'Read,Grep,Glob'
      file_patterns: 'src/**/*.ts,src/**/*.tsx'
```

### 2. Claude Code (`claude.yml`)

**Interactive Claude assistance triggered by mentions in issues and pull requests.**

#### Triggers
- 💬 Issue comment (mentions @claude or @duyetbot)
- 💬 Pull request comment (mentions @claude or @duyetbot)
- 💬 Pull request review (mentions @claude or @duyetbot)
- 📋 Issue created (mentions @claude or @duyetbot in title/body)

#### Configuration

```yaml
uses: duyet/github-actions/.github/workflows/claude.yml@main
secrets:
  api_key: ${{ secrets.OPENROUTER_API_KEY }}
with:
  # Optional: Use OpenRouter (default: true) or Anthropic (false)
  openrouter_enabled: true

  # Optional: Model preset
  # Default: @preset/claude-code-github-action
  model_preset: '@preset/claude-code-github-action'

  # Optional: Bot user ID (default: 101855044 = duyetbot)
  bot_id: '101855044'

  # Optional: Bot name (default: duyetbot)
  bot_name: 'duyetbot'
```

#### Usage Examples

**In a PR comment:**
```
@duyetbot review this function and suggest improvements
```

**In an issue:**
```
@claude help me fix this bug
```

**In a PR review:**
```
@duyetbot what's the best approach here?
```

#### Example: Custom Bot Identity

```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude:
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    with:
      openrouter_enabled: false  # Use Anthropic directly
      bot_id: '999999999'         # Your custom bot ID
      bot_name: 'mybot'           # Your custom bot name
```

## 🔧 Customization Guide

### Using with Anthropic API

Simply set `openrouter_enabled: false`:

```yaml
with:
  openrouter_enabled: false
```

And use `ANTHROPIC_API_KEY` secret:

```yaml
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Restrict Allowed Tools

Limit which tools Claude can use for security:

```yaml
with:
  allowed_tools: 'Read,Grep,Glob'  # No Bash or Plan
```

**Available tools:**
- `Read` - Read files
- `Grep` - Search files
- `Glob` - Find files by pattern
- `Bash` - Execute shell commands
- `Plan` - Create implementation plans

### Filter Files by Pattern

Review only specific file types:

```yaml
with:
  file_patterns: 'src/**/*.ts,src/**/*.tsx,test/**/*.test.ts'
```

### Custom Model Preset

Use different Claude models via OpenRouter:

```yaml
with:
  model_preset: 'openai/gpt-4'  # Use GPT-4 instead
```

## 📊 Real-World Examples

### Full Stack Project

```yaml
name: Workflows

on:
  pull_request:
    types: [opened, synchronize]
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  code-review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      file_patterns: 'src/**/*.ts,src/**/*.tsx,src/**/*.py'
      allowed_tools: 'Read,Grep,Glob,Bash'

  interactive:
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

### Backend-Only Project

```yaml
name: Backend Review

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/**'
      - 'tests/**'
      - 'requirements.txt'

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      file_patterns: 'src/**/*.py,tests/**/*.py'
      allowed_tools: 'Read,Grep,Glob,Bash,Plan'
```

### Frontend-Only Project

```yaml
name: Frontend Review

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/**'
      - 'package.json'
      - 'tailwind.config.js'

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      file_patterns: 'src/**/*.{ts,tsx,js,jsx}'
      allowed_tools: 'Read,Grep,Glob'
```

## 🔒 Security Considerations

### API Key Management
- ✅ Store API keys in GitHub Secrets
- ✅ Use repository-specific secrets for sensitive projects
- ✅ Rotate keys regularly
- ❌ Never commit API keys to the repository
- ❌ Never print API keys in logs

### Permission Scoping
Workflows request only necessary permissions:
- `contents: read` - Read repository files
- `pull-requests: write` - Comment on PRs
- `issues: write` - Comment on issues
- `id-token: write` - For API authentication
- `actions: read` - Check CI results

### Tool Restrictions
Limit Claude's available tools based on trust level:
- **Low trust (external contributors):** `Read,Grep,Glob` only
- **Medium trust (team members):** `Read,Grep,Glob,Bash`
- **High trust (core maintainers):** All tools enabled

### Audit & Monitoring
- Review Claude's comments before merging
- Monitor API usage and costs
- Use workflow logs to audit Claude's actions
- Keep workflows updated with security patches

## 🐛 Troubleshooting

### Workflow Not Triggering

**Problem:** Workflow appears in Actions tab but doesn't run

**Solutions:**
1. Verify trigger events in workflow file match GitHub events
2. Check workflow file syntax with GitHub Actions validator
3. Ensure workflow is in `.github/workflows/` directory
4. Check branch protection rules don't block workflow commits

**Example:**
```yaml
# ✅ Correct
on:
  pull_request:
    types: [opened, synchronize]

# ❌ Wrong (missing types)
on:
  pull_request
```

### API Key Not Working

**Problem:** Workflow fails with "Invalid API key"

**Solutions:**
1. Verify secret name matches in workflow: `${{ secrets.YOUR_SECRET_NAME }}`
2. Check secret value is correct (starts with `sk-or-v1-` for OpenRouter)
3. Ensure secret is in target repository, not just organization
4. Test API key in standalone environment

**Debug:**
```bash
# Verify secret exists (you won't see the value)
gh secret list -R your-org/your-repo
```

### Claude Tool Errors

**Problem:** "Tool ... not allowed" or tool execution errors

**Solutions:**
1. Check `allowed_tools` includes necessary tools
2. Verify Claude's action permissions are correct
3. Review Claude's request - some tools have preconditions
4. Check Claude's logs for specific error messages

**Example:**
```yaml
# ✅ Include Bash if you need it
with:
  allowed_tools: 'Read,Grep,Glob,Bash'

# ❌ Missing Bash
with:
  allowed_tools: 'Read,Grep,Glob'
```

### Model Not Found

**Problem:** "Model preset not found" error

**Solutions:**
1. Use official preset: `@preset/claude-code-github-action`
2. Or use valid OpenRouter model: `openai/gpt-4`, `anthropic/claude-3.5-sonnet`, etc.
3. Verify model availability on OpenRouter website

### Slow Execution

**Problem:** Workflow takes too long to complete

**Solutions:**
1. Restrict `file_patterns` to relevant files only
2. Limit `allowed_tools` to necessary ones
3. Use smaller model: `@preset/claude-code-github-action` (optimized)
4. Check if GitHub runner is available (high load times)

## 📝 Advanced Configuration

### Environment-Specific Workflows

**For development branch:**
```yaml
on:
  pull_request:
    types: [opened, synchronize]
    branches: [develop]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      allowed_tools: 'Read,Grep,Glob,Bash,Plan'
```

**For main/production branch (stricter):**
```yaml
on:
  pull_request:
    types: [opened, synchronize]
    branches: [main]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      allowed_tools: 'Read,Grep,Glob'  # No Bash on main
```

### Conditional Execution

**Skip review for specific patterns:**
```yaml
on:
  pull_request:
    types: [opened, synchronize]
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.github/**'
```

**Only review external contributions:**
```yaml
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    if: github.event.pull_request.author_association == 'FIRST_TIME_CONTRIBUTOR'
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

## 💰 Cost Estimation

Using OpenRouter with Claude models:

| Model | Cost per 1M tokens | Typical PR Review |
|-------|------------------|------------------|
| Claude 3.5 Sonnet | ~$3 input | $0.001-0.005 |
| Claude 3 Opus | ~$15 input | $0.005-0.02 |
| Claude 3 Haiku | ~$0.25 input | $0.0001-0.0005 |

**Optimization:**
- Use Haiku for simple reviews
- Use Sonnet for complex analysis
- Limit file patterns to reduce token usage
- Use `allowed_tools` to speed up analysis

## 🤝 Contributing

Found a bug or have a feature request?

1. Check [existing issues](https://github.com/duyet/github-actions/issues)
2. Create a detailed bug report or feature request
3. Submit PR with improvements
4. Include examples and test cases

## 📄 License

MIT License - See LICENSE file for details

## 📞 Support

- **GitHub Issues:** [Report issues](https://github.com/duyet/github-actions/issues)
- **Discussions:** [Ask questions](https://github.com/duyet/github-actions/discussions)
- **Documentation:** [CLAUDE.md](CLAUDE.md)

## 🔗 Related Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Claude Code Action](https://github.com/anthropics/claude-code-action)
- [OpenRouter API Docs](https://openrouter.ai/docs)
- [Anthropic API Docs](https://docs.anthropic.com)

---

**Made with ❤️ for developers by [Duyet](https://duyet.net)**
