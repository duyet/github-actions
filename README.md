# GitHub Actions Reusable Workflows

Reusable GitHub Actions workflows powered by Claude AI for code review and interactive assistance.

## 📚 Available Workflows

| # | Workflow | Purpose |
|---|----------|---------|
| 1 | [Claude Code Review](#1-claude-code-review) | Auto-review pull requests |
| 2 | [Claude Interactive](#2-claude-interactive) | Mention @duyetbot on issues/PRs |

---

## 1. Claude Code Review

### 1.1. What it does

- ✅ Automatically reviews every pull request
- ✅ Checks code quality, bugs, performance, and security
- ✅ Comments directly on the PR with feedback
- ✅ Runs on: PR opened, new commits pushed

### 1.2. Installation

<details>
<summary><strong>📋 Using Claude Code Prompt (Easy)</strong></summary>

Copy and paste this prompt to Claude Code in your repository:

```
Create a Claude Code Review workflow in .github/workflows/review.yml with these default settings:

name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}

This workflow:
- Automatically reviews every pull request
- Uses OpenRouter API by default
- Uses default model: @preset/claude-code-github-action
- Checks code quality, bugs, performance, and security

Then help me:
1. Create the workflow file at .github/workflows/review.yml
2. Test it by opening a new pull request

Don't set up the secret yet, just create the workflow file.
```

Then follow the guidance from Claude Code.
</details>

<details>
<summary><strong>🛠️ Manual Setup (Bash)</strong></summary>

```bash
mkdir -p .github/workflows
cat > .github/workflows/review.yml << 'EOF'
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
EOF

git add .github/workflows/review.yml
git commit -m "feat: add claude code review workflow"
git push
```
</details>

### 1.3. Required Secrets & Environment

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

### 1.4. Setup

1. Go to your repo: **Settings → Secrets and variables → Actions**
2. Click "New repository secret"
3. Add `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
4. Create a test PR to verify it works

### 1.5. Customize

```yaml
# Review only specific file types
with:
  file_patterns: 'src/**/*.ts,src/**/*.tsx'

# Restrict Claude's tools for security
with:
  allowed_tools: 'Read,Grep,Glob'  # No Bash

# Use Anthropic instead of OpenRouter
with:
  provider: 'anthropic'
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# Use custom model
with:
  model: 'anthropic/claude-3.5-haiku'
```

---

## 2. Claude Interactive

### 2.1. What it does

- ✅ Responds to `@duyetbot` or `@claude` mentions
- ✅ Works in issues, PR comments, and reviews
- ✅ Ask questions, get code analysis, design help
- ✅ On-demand assistance triggered by you

### 2.2. Installation

<details>
<summary><strong>📋 Using Claude Code Prompt (Easy)</strong></summary>

Copy and paste this prompt to Claude Code in your repository:

```
Create a Claude Interactive workflow in .github/workflows/claude.yml with these default settings:

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

This workflow:
- Responds to @duyetbot or @claude mentions in issues and PRs
- Uses OpenRouter API by default
- Uses default model: @preset/claude-code-github-action
- Default bot identity: duyetbot (ID: 101855044)

Then help me:
1. Create the workflow file at .github/workflows/claude.yml
2. Test it by mentioning @duyetbot in a comment on an issue or PR

Don't set up the secret yet, just create the workflow file.
```

Then follow the guidance from Claude Code.
</details>

<details>
<summary><strong>🛠️ Manual Setup (Bash)</strong></summary>

```bash
mkdir -p .github/workflows
cat > .github/workflows/claude.yml << 'EOF'
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
EOF

git add .github/workflows/claude.yml
git commit -m "feat: add claude interactive workflow"
git push
```
</details>

### 2.3. Required Secrets & Environment

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

### 2.4. Setup

1. Go to your repo: **Settings → Secrets and variables → Actions**
2. Click "New repository secret"
3. Add `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
4. Comment on an issue/PR: `@duyetbot help with this`

### 2.5. Usage Examples

```
@duyetbot review this function
@claude explain this error
@duyetbot fix this bug
@claude design an API for this feature
```

### 2.6. Customize

```yaml
# Restrict Claude's tools for security
with:
  allowed_tools: 'Read,Grep,Glob'  # No Bash

# Use Anthropic instead of OpenRouter
with:
  provider: 'anthropic'
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# Use custom bot name
with:
  bot_name: 'mybot'
  bot_id: '999999999'  # Your bot's GitHub user ID

# Use custom model
with:
  model: 'anthropic/claude-3.5-haiku'
```

---

## 📖 Full Documentation

- **[INTEGRATING.md](INTEGRATING.md)** - Step-by-step setup guide
- **[CLAUDE.md](CLAUDE.md)** - Project guidelines and best practices
- **[GitHub Actions Docs](https://docs.github.com/en/actions)**
- **[Claude Code Action](https://github.com/anthropics/claude-code-action)**

## 🔗 Links

- OpenRouter: https://openrouter.ai
- Anthropic: https://console.anthropic.com
- GitHub Secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets

---

**Built by duyetbot**
