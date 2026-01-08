# Integrating Claude Workflows

Complete step-by-step guide to integrate reusable Claude workflows into your GitHub project.

## Prerequisites

- ✅ GitHub repository with at least one commit
- ✅ Repository access to add GitHub Secrets
- ✅ OpenRouter or Anthropic API key
- ✅ `.github/workflows/` directory (GitHub will create if needed)

## Step 1: Prepare Your API Key

### Option A: OpenRouter (Recommended)

1. Visit [OpenRouter](https://openrouter.ai)
2. Sign up or log in
3. Go to [API keys](https://openrouter.ai/keys)
4. Create a new API key
5. Copy the key (starts with `sk-or-v1-`)

### Option B: Anthropic

1. Visit [Anthropic Console](https://console.anthropic.com)
2. Sign up or log in
3. Go to [API keys](https://console.anthropic.com/account/keys)
4. Create a new API key
5. Copy the key (starts with `sk-ant-`)

## Step 2: Add Secret to GitHub

### Via GitHub Web UI

1. Go to your repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. **Name:** `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
5. **Value:** Paste your API key
6. Click "Add secret"

### Via GitHub CLI

```bash
# OpenRouter
gh secret set OPENROUTER_API_KEY --body "sk-or-v1-..."

# Anthropic
gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."
```

✅ **Verify:** Go to Settings → Secrets and confirm your secret appears

## Step 3: Create Workflow File

### Option A: Code Review Only

Create `.github/workflows/claude-review.yml`:

```bash
mkdir -p .github/workflows
touch .github/workflows/claude-review.yml
```

Add content:
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

### Option B: Interactive Only

Create `.github/workflows/claude.yml`:

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

### Option C: Both

Create both files above in `.github/workflows/`

## Step 4: Test the Integration

### For Code Review Workflow

1. Create a test branch:
   ```bash
   git checkout -b test-claude-review
   ```

2. Make a small code change:
   ```bash
   echo "# Test" >> README.md
   ```

3. Commit and push:
   ```bash
   git add .
   git commit -m "test: test claude review"
   git push -u origin test-claude-review
   ```

4. Create a pull request
5. Go to **Actions** tab and watch the workflow run
6. Check PR comments for Claude's review

### For Interactive Workflow

1. Create an issue or PR comment with:
   ```
   @duyetbot help with this
   ```

2. Go to **Actions** tab and watch the workflow run
3. Check the response in the issue/PR

## Step 5: Customize (Optional)

### Example: Review Only TypeScript Files

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
```

### Example: Restrict Tools for Security

```yaml
jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      allowed_tools: 'Read,Grep,Glob'  # No Bash
```

### Example: Use Anthropic Instead

```yaml
jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    with:
      provider: 'anthropic'
```

## Step 6: Verify It's Working

### Check Workflow Runs

1. Go to **Actions** tab in your repository
2. You should see your workflow runs listed
3. Click on a run to see detailed logs
4. Check that Claude's action completed successfully

### Look for Claude's Comments

- **For Code Review**: Check PR comments for Claude's review feedback
- **For Interactive**: Check issue/PR comments for Claude's responses

### Debug Failed Runs

1. Click on the failed workflow run
2. Click on the job name (e.g., "review")
3. Expand step "Run Claude Code Review"
4. Look for error messages
5. Common issues:
   - ❌ Invalid API key → Check secret name and value
   - ❌ Tool not allowed → Add to `allowed_tools`
   - ❌ Model not found → Use `@preset/claude-code-github-action`

## Common Integration Patterns

### Pattern 1: Review on Pull Request (Recommended for Open Source)

```yaml
name: Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

**When to use:**
- Open source projects
- Public repositories
- Want automatic review on all PRs
- Cost-conscious (Haiku model is cheap)

### Pattern 2: Interactive & Automated Help (Good for Team Collaboration)

```yaml
name: Claude Code

on:
  # Code review: PR assignment or @duyetbot mentions
  pull_request:
    types: [opened, assigned, synchronize]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]

  # Interactive help: mentions in comments
  issue_comment:
    types: [created]

  # Issue planning: issue assignment
  issues:
    types: [opened, assigned]

jobs:
  claude:
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

**When to use:**
- Internal team projects
- Want on-demand assistance + automation
- Need code review, interactive help, and issue planning
- Have a specific question or want to assign tasks to Claude

### Pattern 3: Complete Coverage (Code Review + Interactive + Automation)

```yaml
name: Complete Claude

on:
  # Automatic PR code review
  pull_request:
    types: [opened, synchronize]

  # Interactive help and automation
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]
  issues:
    types: [opened, assigned]

jobs:
  # Automatic review on every PR
  auto-review:
    if: github.event_name == 'pull_request'
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}

  # Interactive help + PR assignment review + issue planning
  interactive:
    if: github.event_name != 'pull_request' || github.event.action == 'assigned'
    uses: duyet/github-actions/.github/workflows/claude.yml@main
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

**When to use:**
- Want comprehensive coverage: auto-review + interactive + automation
- Dedicated code review on every PR
- Plus manual assignments for deeper analysis
- Have budget for multiple API calls

## Troubleshooting Integration

### Issue: Workflow doesn't show up in Actions tab

**Solution:**
1. Workflow file must be in `.github/workflows/`
2. File must be in main/master branch
3. Filename must end with `.yml` or `.yaml`
4. YAML syntax must be valid

**Check:**
```bash
# Verify file location
ls -la .github/workflows/

# Verify valid YAML
cat .github/workflows/claude-review.yml
```

### Issue: Workflow runs but fails immediately

**Solution:**
1. Check secret name is correct
2. Check secret value is not empty
3. Run workflow manually to see logs

**Check:**
```bash
# List secrets (values hidden)
gh secret list
```

### Issue: Claude action hangs or times out

**Solution:**
1. Limit `file_patterns` to reduce scope
2. Increase GitHub runner timeout (max 360 minutes)
3. Check if OpenRouter/Anthropic is down

**Verify API status:**
```bash
# Test OpenRouter
curl https://openrouter.ai/api/v1/models

# Test Anthropic
curl https://api.anthropic.com/v1/models
```

### Issue: Claude makes mistakes or inappropriate comments

**Solution:**
1. Review Claude's guidelines in CLAUDE.md
2. Restrict `allowed_tools` for safety
3. Use smaller models for specific domains
4. Add context through `file_patterns`

**Example - restrictive setup:**
```yaml
with:
  allowed_tools: 'Read,Grep,Glob'  # No bash
  model: 'anthropic/claude-3.5-haiku'
  file_patterns: 'src/**/*.ts'
```

## Next Steps

After integration:

1. ✅ Test with real pull requests
2. ✅ Monitor first few reviews
3. ✅ Adjust `file_patterns` if needed
4. ✅ Customize `allowed_tools` for your use case
5. ✅ Share with your team
6. ✅ Monitor API costs
7. ✅ Update workflows as needed

## Getting Help

- 📖 Read [README.md](README.md) for full documentation
- 🔧 Check [CLAUDE.md](CLAUDE.md) for project guidelines
- 🐛 Search [GitHub Issues](https://github.com/duyet/github-actions/issues)
- 💬 Start a [Discussion](https://github.com/duyet/github-actions/discussions)

## Quick Reference

| Task | File |
|------|------|
| Code review on PRs | `claude-review.yml` |
| Interactive help | `claude.yml` |
| Both workflows | Both files |

| API | Secret Name | File Path |
|-----|------------|-----------|
| OpenRouter | `OPENROUTER_API_KEY` | Set `provider: 'openrouter'` |
| Anthropic | `ANTHROPIC_API_KEY` | Set `provider: 'anthropic'` |

---

**Happy coding with Claude! 🚀**
