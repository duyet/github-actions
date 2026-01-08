# GitHub Actions Reusable Workflows

Reusable GitHub Actions workflows powered by Claude AI for code review and interactive assistance.

## ⚡ Quick Copy-Paste

### 1. Add Secret
Go to your repo: **Settings → Secrets and variables → Actions → New repository secret**

```
Name: OPENROUTER_API_KEY
Value: sk-or-v1-...  (from https://openrouter.ai/keys)
```

Or use Anthropic: `ANTHROPIC_API_KEY` (sk-ant-...)

### 2. Copy Workflow

**For automatic code reviews**, create `.github/workflows/review.yml`:
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

**For interactive help**, create `.github/workflows/claude.yml`:
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

**For both**, create both files above.

### 3. Done!
- Code reviews run automatically on PRs
- Mention `@duyetbot` or `@claude` in comments for help

---

## 📚 Available Workflows

| Workflow | Trigger | Use Case |
|----------|---------|----------|
| `claude-code-review.yml` | Pull request opened/updated | Automatic code review |
| `claude.yml` | @mention in issues/PRs/comments | Interactive assistance |

---

## 🤖 Workflow: Claude Code Review

**What it does:**
- ✅ Automatically reviews every pull request
- ✅ Checks code quality, bugs, performance, and security
- ✅ Comments directly on the PR with feedback
- ✅ Runs on: PR opened, new commits pushed

**Installation:**
Copy and paste this prompt to Claude Code in your repository:

```
install claude code review workflow for automatic PR reviews using duyet/github-actions
```

**Or manually:**
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
```

**Then:**
1. Add `OPENROUTER_API_KEY` secret to GitHub (Settings → Secrets)
2. Create a PR to test it

---

## 💬 Workflow: Claude Interactive

**What it does:**
- ✅ Responds to `@duyetbot` or `@claude` mentions
- ✅ Works in issues, PR comments, and reviews
- ✅ Ask questions, get code analysis, design help
- ✅ On-demand assistance triggered by you

**Installation:**
Copy and paste this prompt to Claude Code in your repository:

```
install claude interactive workflow for @mention assistance using duyet/github-actions
```

**Or manually:**
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
```

**Then:**
1. Add `OPENROUTER_API_KEY` secret to GitHub (Settings → Secrets)
2. Comment on an issue/PR: `@duyetbot help with this`

---

## 🔧 Customization

### Filter by File Type
```yaml
with:
  file_patterns: 'src/**/*.ts,src/**/*.tsx'
```

### Restrict Tools (For Security)
```yaml
with:
  allowed_tools: 'Read,Grep,Glob'  # No Bash
```

### Use Anthropic Instead
```yaml
with:
  openrouter_enabled: false
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Change Bot Name
```yaml
with:
  bot_name: 'mybot'
  bot_id: '999999999'
```

## 📊 Examples

**Review TypeScript only:**
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
      file_patterns: 'src/**/*.ts,src/**/*.tsx'
      allowed_tools: 'Read,Grep,Glob'
```

**Both workflows:**
```yaml
name: Claude Workflows
on:
  pull_request:
    types: [opened, synchronize]
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  review:
    if: github.event_name == 'pull_request'
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}

  interactive:
    if: github.event_name != 'pull_request'
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

## ❓ FAQ

**Q: How much does it cost?**
- OpenRouter Claude 3.5 Sonnet: ~$0.001-0.005 per PR review
- Claude 3 Haiku: ~$0.0001-0.0005 per PR review
- Anthropic pricing: https://www.anthropic.com/pricing

**Q: Is it secure?**
- API key only stored in GitHub Secrets
- No sensitive data in logs
- Workflows run in isolated environments
- You control what tools Claude can use

**Q: What can Claude review?**
- Code quality and best practices
- Potential bugs
- Performance issues
- Security concerns
- Test coverage

**Q: How do I use it?**
- **Code review**: Automatic on PRs
- **Interactive**: Comment `@duyetbot` or `@claude` on issues/PRs

**Q: Can I use my own bot?**
Yes, set `bot_id` and `bot_name`:
```yaml
with:
  bot_id: '999999999'
  bot_name: 'mybot'
```

## 🚨 Troubleshooting

**Workflow doesn't run?**
- Check file is in `.github/workflows/`
- Verify YAML syntax is valid
- Check secret name matches in workflow

**Claude fails?**
- Verify API key is correct
- Check API key isn't expired
- Ensure secret name is right: `OPENROUTER_API_KEY` or `ANTHROPIC_API_KEY`

**Wrong tool errors?**
- Add tool to `allowed_tools`
- Example: `allowed_tools: 'Read,Grep,Glob,Bash'`

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
