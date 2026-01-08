# GitHub Actions Reusable Workflows

Reusable GitHub Actions workflows powered by Claude AI for code review and interactive assistance.

## 📚 Available Workflows

| # | Workflow | Purpose |
|---|----------|---------|
| 1 | [Claude Code Review](#1️⃣-claude-code-review) | Auto-review pull requests |
| 2 | [Claude Interactive](#2️⃣-claude-interactive) | @mention assistance on issues/PRs |

---

### 1️⃣ Claude Code Review

**What it does:**
- ✅ Automatically reviews every pull request
- ✅ Checks code quality, bugs, performance, and security
- ✅ Comments directly on the PR with feedback
- ✅ Runs on: PR opened, new commits pushed

**Installation:**
<details>
<summary><strong>📋 Using Claude Code Prompt (Easy)</strong></summary>

Copy and paste this prompt to Claude Code in your repository:

```
Read https://github.com/duyet/github-actions/blob/main/CLAUDE.md to understand this project's guidelines.

Then follow these instructions:
1. Review the "Claude Code Review" workflow documentation in README.md
2. Create .github/workflows/review.yml using the workflow_call template from .github/workflows/claude-code-review.yml
3. Configure OPENROUTER_API_KEY secret in GitHub repository settings
4. The workflow should trigger on: pull_request opened and synchronize events
5. Claude should review code quality, bugs, performance, and security

Make sure the workflow can be customized with:
- allowed_tools: restrict which Claude tools are available
- file_patterns: filter which files to review
- openrouter_enabled: toggle between Anthropic and OpenRouter APIs
- model_preset: specify which model to use

Don't create the secret, just guide me through the setup steps.
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

**Required Secrets & Environment:**

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

**Setup:**
1. Go to your repo: **Settings → Secrets and variables → Actions**
2. Click "New repository secret"
3. Add `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
4. Create a test PR to verify it works

**Customize:**

```yaml
# Review only specific file types
with:
  file_patterns: 'src/**/*.ts,src/**/*.tsx'

# Restrict Claude's tools for security
with:
  allowed_tools: 'Read,Grep,Glob'  # No Bash

# Use Anthropic instead of OpenRouter
with:
  openrouter_enabled: false
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# Use custom model
with:
  model_preset: 'anthropic/claude-3.5-haiku'
```

---

### 2️⃣ Claude Interactive

**What it does:**
- ✅ Responds to `@duyetbot` or `@claude` mentions
- ✅ Works in issues, PR comments, and reviews
- ✅ Ask questions, get code analysis, design help
- ✅ On-demand assistance triggered by you

**Installation:**
<details>
<summary><strong>📋 Using Claude Code Prompt (Easy)</strong></summary>

Copy and paste this prompt to Claude Code in your repository:

```
Read https://github.com/duyet/github-actions/blob/main/CLAUDE.md to understand this project's guidelines.

Then follow these instructions:
1. Review the "Claude Interactive" workflow documentation in README.md
2. Create .github/workflows/claude.yml using the workflow_call template from .github/workflows/claude.yml
3. Configure OPENROUTER_API_KEY secret in GitHub repository settings
4. The workflow should trigger on these events:
   - issue_comment: created
   - pull_request_review_comment: created
   - pull_request_review: submitted
   - issues: opened, assigned
5. It should respond to @duyetbot or @claude mentions in issues, PRs, and comments

Make sure the workflow can be customized with:
- allowed_tools: restrict which Claude tools are available
- openrouter_enabled: toggle between Anthropic and OpenRouter APIs
- model_preset: specify which model to use
- bot_id: GitHub bot user ID
- bot_name: bot display name

Don't create the secret, just guide me through the setup steps.
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

**Required Secrets & Environment:**

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

**Setup:**
1. Go to your repo: **Settings → Secrets and variables → Actions**
2. Click "New repository secret"
3. Add `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
4. Comment on an issue/PR: `@duyetbot help with this`

**Usage Examples:**
```
@duyetbot review this function
@claude explain this error
@duyetbot fix this bug
@claude design an API for this feature
```

**Customize:**

```yaml
# Restrict Claude's tools for security
with:
  allowed_tools: 'Read,Grep,Glob'  # No Bash

# Use Anthropic instead of OpenRouter
with:
  openrouter_enabled: false
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# Use custom bot name
with:
  bot_name: 'mybot'
  bot_id: '999999999'  # Your bot's GitHub user ID

# Use custom model
with:
  model_preset: 'anthropic/claude-3.5-haiku'
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

**Made with ❤️ by [Duyet](https://duyet.net)**
