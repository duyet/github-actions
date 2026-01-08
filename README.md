# GitHub Actions Reusable Workflows

Reusable GitHub Actions workflows powered by Claude AI for code review and interactive assistance.

## Available Workflows

| # | Workflow | Purpose |
|---|----------|---------|
| 1 | [Claude Code Review](#1-claude-code-review) | Auto-review pull requests |
| 2 | [Claude Interactive](#2-claude-interactive--automation) | Mention @duyetbot on issues/PRs |
| 3 | [Claude Schedule](#3-claude-schedule) | Scheduled tasks with custom prompts |
| 3.1 | [Claude Nightly Analysis](#31-claude-nightly-analysis) | Pre-configured codebase analysis |

---

## 1. Claude Code Review

<details>
<summary><strong>1.1. What it does</strong></summary>

- Automatically reviews every pull request
- Checks code quality, bugs, performance, and security
- Comments directly on the PR with feedback
- Runs on: PR opened, new commits pushed

</details>

<details>
<summary><strong>1.2. Installation</strong></summary>

<details>
<summary>&nbsp;&nbsp;&nbsp;&nbsp;Using Claude Code Prompt (Easy)</summary>

Copy and paste this prompt to Claude Code in your repository:

```
Read https://github.com/duyet/github-actions/blob/main/CLAUDE.md to understand this project's guidelines.

Check if we already have the Claude Code Review workflow installed:
1. Look for .github/workflows/review.yml or similar workflow files
2. If found, check the current version by examining the 'uses' field (e.g., duyet/github-actions/.github/workflows/claude-code-review.yml@main)
3. If not found, this is a fresh install

If workflow already exists:
- Review the current configuration and customizations
- Migrate to the latest version from duyet/github-actions@main
- Preserve existing customizations (file_patterns, allowed_tools, etc.)
- Update any deprecated parameters
- Test the migrated workflow on a new PR

If fresh install, create .github/workflows/review.yml with these default settings (no customization):

name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    permissions:
      contents: read
      pull-requests: write
      issues: read
      id-token: write
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}

This default workflow:
- Automatically reviews every pull request
- Uses OpenRouter API
- Uses default model: @preset/claude-code-github-action
- Allows default tools: Read, Grep, Glob, Bash, Plan
- Checks code quality, bugs, performance, and security

Then help me:
1. Create the workflow file at .github/workflows/review.yml
2. Commit and push the changes
3. Test it by opening a new pull request

Note: If the workflow already exists, show me what changed before making updates.
Don't set up the secret yet, just create or migrate the workflow file.
```

Then follow the guidance from Claude Code.

</details>

<details>
<summary>&nbsp;&nbsp;&nbsp;&nbsp;Manual Setup</summary>

Create `.github/workflows/review.yml`:

```yaml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    uses: duyet/github-actions/.github/workflows/claude-code-review.yml@main
    permissions:
      contents: read
      pull-requests: write
      issues: read
      id-token: write
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

</details>

</details>

<details>
<summary><strong>1.3. Required Secrets & Environment</strong></summary>

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

</details>

<details>
<summary><strong>1.4. Configuration Options</strong></summary>

| Input | Default | Description |
|-------|---------|-------------|
| `provider` | `openrouter` | API provider: `openrouter`, `anthropic`, or `zai` |
| `model` | `@preset/claude-code-github-action` | Model to use |
| `allowed_tools` | `Read,Grep,Glob,Bash,Plan` | Comma-separated list of allowed tools |
| `file_patterns` | (empty) | Comma-separated file patterns to review |
| `show_full_output` | `true` | Show full JSON output in logs (tokens, tools, etc.) |

</details>

<details>
<summary><strong>1.5. Customize</strong></summary>

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

# Disable verbose output
with:
  show_full_output: false
```

</details>

<details>
<summary><strong>1.6. Comment Format</strong></summary>

Review comments include a collapsible metadata footer:

```markdown
<details>
<summary>📊 Review metadata</summary>

| Property | Value |
|----------|-------|
| Model | @preset/claude-code-github-action |
| Provider | openrouter |
| Tools | Read, Grep, Glob |
| Reviewed by | [@duyetbot](https://github.com/duyetbot) |

*Token usage and detailed execution stats available in the [job log](...).*

</details>
```

Full execution details (tokens, cost, duration) are available in the GitHub Actions job summary.

</details>

---

## 2. Claude Interactive & Automation

<details>
<summary><strong>2.1. What it does</strong></summary>

- **Code Review**: Automatically reviews PRs when assigned to @duyetbot
- **Interactive Help**: Responds to `@duyetbot` or `@claude` mentions in comments
- **Issue Planning**: Comments with plan/analysis when assigned to an issue
- Works in issues, PR comments, reviews, and assignments
- Ask questions, get code analysis, design help, or get issue breakdown
- Flexible triggers: assignments, mentions, or both

</details>

<details>
<summary><strong>2.2. Installation</strong></summary>

<details>
<summary>&nbsp;&nbsp;&nbsp;&nbsp;Using Claude Code Prompt (Easy)</summary>

Copy and paste this prompt to Claude Code in your repository:

```
Read https://github.com/duyet/github-actions/blob/main/CLAUDE.md to understand this project's guidelines.

Check if we already have the Claude Interactive workflow installed:
1. Look for .github/workflows/claude.yml or similar workflow files
2. If found, check the current version by examining the 'uses' field (e.g., duyet/github-actions/.github/workflows/claude.yml@main)
3. If not found, this is a fresh install

If workflow already exists:
- Review the current configuration and customizations
- Migrate to the latest version from duyet/github-actions@main
- Preserve existing customizations (bot_id, bot_name, allowed_tools, etc.)
- Update any deprecated parameters or trigger events
- Check if new features were added (new trigger events, new customization options)
- Test the migrated workflow by mentioning @duyetbot/@claude in a comment

If fresh install, create .github/workflows/claude.yml with these default settings (no customization):

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
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}

This default workflow:
- Automatically reviews PRs when assigned to @duyetbot
- Responds to @duyetbot or @claude mentions in issues and PRs
- Comments with plan/analysis when assigned to an issue
- Uses OpenRouter API
- Uses default model: @preset/claude-code-github-action
- Default bot identity: duyetbot (ID: 101855044)
- Allows default tools: Read, Grep, Glob, Bash, Plan

Then help me:
1. Create the workflow file at .github/workflows/claude.yml
2. Commit and push the changes
3. Test it by:
   - Assigning a PR to @duyetbot for code review
   - Mentioning @duyetbot in a comment on an issue or PR
   - Assigning an issue to @duyetbot for plan analysis

Note: If the workflow already exists, show me what changed before making updates.
Don't set up the secret yet, just create or migrate the workflow file.
```

Then follow the guidance from Claude Code.

</details>

<details>
<summary>&nbsp;&nbsp;&nbsp;&nbsp;Manual Setup</summary>

Create `.github/workflows/claude.yml`:

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
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

</details>

</details>

<details>
<summary><strong>2.3. Required Secrets & Environment</strong></summary>

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

</details>

<details>
<summary><strong>2.4. Setup</strong></summary>

1. Go to your repo: **Settings → Secrets and variables → Actions**
2. Click "New repository secret"
3. Add `OPENROUTER_API_KEY` (or `ANTHROPIC_API_KEY`)
4. Comment on an issue/PR: `@duyetbot help with this`

</details>

<details>
<summary><strong>2.5. Usage Examples</strong></summary>

**Interactive Help** - Mention @duyetbot in comments:
```
@duyetbot review this function
@claude explain this error
@duyetbot fix this bug
@claude design an API for this feature
```

**Code Review** - Assign a PR to @duyetbot:
- Go to any PR → Click "Assignees" → Select @duyetbot
- Claude will automatically review the PR and comment with feedback

**Issue Planning** - Assign an issue to @duyetbot:
- Go to any issue → Click "Assignees" → Select @duyetbot
- Claude will analyze the issue and comment with a plan, approach, and effort estimate

</details>

<details>
<summary><strong>2.6. Configuration Options</strong></summary>

| Input | Default | Description |
|-------|---------|-------------|
| `provider` | `openrouter` | API provider: `openrouter`, `anthropic`, or `zai` |
| `model` | `@preset/claude-code-github-action` | Model to use |
| `allowed_tools` | `Read,Grep,Glob,Bash,Plan` | Comma-separated list of allowed tools |
| `bot_id` | `101855044` | GitHub bot user ID |
| `bot_name` | `duyetbot` | GitHub bot name |
| `file_patterns` | (empty) | Comma-separated file patterns for code review |
| `show_full_output` | `true` | Show full JSON output in logs (tokens, tools, etc.) |

</details>

<details>
<summary><strong>2.7. Customize</strong></summary>

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

# Disable verbose output
with:
  show_full_output: false
```

</details>

---

## 3. Claude Schedule

<details>
<summary><strong>3.1. What it does</strong></summary>

- Run Claude tasks on a schedule (cron) or manually (workflow_dispatch)
- Execute custom prompts for automated maintenance, reviews, or issue processing
- Configure tools, plugins, MCP servers, and settings
- Create issues, PRs, or take any automated action
- Ideal for nightly code reviews, hourly issue processing, dependency updates

</details>

<details>
<summary><strong>3.2. Installation</strong></summary>

<details>
<summary>&nbsp;&nbsp;&nbsp;&nbsp;Using Claude Code Prompt (Easy)</summary>

Copy and paste this prompt to Claude Code in your repository:

```
Read https://github.com/duyet/github-actions/blob/main/CLAUDE.md to understand this project's guidelines.

Create a scheduled workflow for Claude at .github/workflows/schedule.yml:

name: Claude Schedule

on:
  schedule:
    - cron: '0 2 * * *'  # Every day at 2 AM UTC
  workflow_dispatch:      # Allow manual trigger

jobs:
  scheduled:
    uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      prompt: |
        Perform nightly code review:
        1. Check recent commits for issues
        2. Review open PRs
        3. Create an issue with findings

Then help me:
1. Create the workflow file
2. Customize the schedule and prompt for my needs
3. Commit and push the changes
```

Then follow the guidance from Claude Code.

</details>

<details>
<summary>&nbsp;&nbsp;&nbsp;&nbsp;Manual Setup</summary>

Create `.github/workflows/schedule.yml`:

```yaml
name: Claude Schedule

on:
  schedule:
    - cron: '0 2 * * *'  # Every day at 2 AM UTC
  workflow_dispatch:

jobs:
  scheduled:
    uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      prompt: |
        Perform nightly code review and create issue with findings.
```

</details>

</details>

<details>
<summary><strong>3.3. Required Secrets & Environment</strong></summary>

| Secret | Value | Source |
|--------|-------|--------|
| `OPENROUTER_API_KEY` | Your API key | https://openrouter.ai/keys |
| `ANTHROPIC_API_KEY` | Your API key (alternative) | https://console.anthropic.com/account/keys |

</details>

<details>
<summary><strong>3.4. Configuration Options</strong></summary>

| Input | Default | Description |
|-------|---------|-------------|
| `prompt` | (required) | Custom prompt for Claude to execute |
| `provider` | `openrouter` | API provider: `openrouter`, `anthropic`, or `zai` |
| `model` | `@preset/claude-code-github-action` | Model to use |
| `allowed_tools` | `Read,Grep,Glob,Bash,Write,Edit` | Comma-separated list of allowed tools |
| `plugins` | (empty) | Newline-separated list of Claude Code plugins |
| `plugin_marketplaces` | (empty) | Newline-separated list of plugin marketplace URLs |
| `mcp_config` | (empty) | MCP server config JSON string or file path |
| `settings` | (empty) | Claude Code settings JSON string or file path |
| `claude_args` | (empty) | Additional CLI arguments for Claude |
| `max_turns` | `25` | Maximum conversation turns |
| `timeout_minutes` | `30` | Job timeout in minutes |
| `show_full_output` | `true` | Show full JSON output in logs (tokens, tools, etc.) |

</details>

<details>
<summary><strong>3.5. Example: Nightly Codebase Analysis</strong></summary>

```yaml
name: Nightly Codebase Analysis

on:
  schedule:
    - cron: '0 2 * * *'  # Every day at 2 AM UTC
  workflow_dispatch:

jobs:
  analyze:
    uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      prompt: |
        # Nightly Codebase Analysis

        ## Task
        Deep analyze the codebase to find the most impactful improvement opportunity.

        ## Discovery Areas

        ### 🐛 Bugs & Defects
        - Null/undefined reference errors
        - Race conditions, async/await issues
        - Uncaught exceptions, missing error handling
        - Logic errors, incorrect conditionals

        ### 🔒 Security Issues
        - Hardcoded secrets, API keys, passwords
        - Injection vulnerabilities (SQL, XSS, command)
        - Insecure dependencies (`npm audit`, `pip audit`)

        ### ⚡ Performance
        - N+1 queries, inefficient database access
        - Memory leaks, unbounded caches
        - Blocking operations in async code

        ### 🔧 Refactoring Opportunities
        - Functions > 50 lines or high complexity
        - Duplicated code blocks (DRY violations)
        - Deep nesting, inconsistent patterns

        ### ✨ Enhancements
        - Missing TypeScript types
        - Missing logging/error messages
        - Hardcoded configuration

        ### 📝 Documentation & Tests
        - Public APIs without documentation
        - Critical paths without test coverage
        - TODO/FIXME/HACK comments

        ### 🧹 Code Hygiene
        - Dead code, unused exports/imports
        - Deprecated API usage
        - Outdated dependencies

        ## Process
        1. Scan codebase using Glob, Grep, Read
        2. Run available linters/audits if present
        3. Rank findings by impact and effort
        4. Select the BEST opportunity (high impact, reasonable effort)

        ## Output
        Create ONE GitHub issue if actionable finding exists.

        **Title:** `[type] scope: description`
        Types: `bug`, `security`, `perf`, `refactor`, `enhance`, `docs`, `chore`

        **Body:**
        ## Type
        - [ ] 🐛 Bug / 🔒 Security / ⚡ Performance
        - [ ] 🔧 Refactor / ✨ Enhancement / 📝 Docs / 🧹 Chore

        ## Summary
        <Clear description>

        ## Location
        - **File:** `path/to/file.ext`
        - **Lines:** X-Y

        ## Current State
        <code showing the problem>

        ## Problem
        <Why this is an issue>

        ## Proposed Solution
        <Example fix>

        ## Effort
        - [ ] Small (< 1 hour) / Medium (1-4 hours) / Large (> 4 hours)

        ---
        <details>
        <summary>📊 Analysis metadata</summary>

        | Property | Value |
        |----------|-------|
        | Created by | [@duyetbot](https://github.com/duyetbot) |
        | Job | [View logs](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}) |

        </details>

        ## Rules
        - Create issue ONLY if finding is actionable
        - ONE issue per run - highest impact item
        - Include specific file paths and line numbers
        - Skip trivial formatting issues
        - If codebase is healthy, do NOT create any issue

      allowed_tools: 'Read,Grep,Glob,Bash,Write,Edit'
      timeout_minutes: 45
```

</details>

<details>
<summary><strong>3.6. Example: Hourly Issue Processor</strong></summary>

```yaml
name: Hourly Issue Processor

on:
  schedule:
    - cron: '0 * * * *'  # Every hour
  workflow_dispatch:

jobs:
  process:
    uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      prompt: |
        Process open issues:

        1. List open issues: `gh issue list --state open --limit 10`
        2. Pick ONE unassigned issue with "good first issue" or "bug" label
        3. Analyze the issue and codebase

        For simple fixes:
        - Create branch, implement fix, create PR

        For complex issues:
        - Add detailed analysis comment with approach

      allowed_tools: 'Read,Grep,Glob,Bash,Write,Edit'
      max_turns: '30'
      timeout_minutes: 20
```

</details>

<details>
<summary><strong>3.7. Example: With Plugins and MCP</strong></summary>

```yaml
name: Claude with Plugins

on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6 AM
  workflow_dispatch:

jobs:
  weekly:
    uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
    with:
      prompt: |
        Generate weekly project status report.

      # Install plugins
      plugins: |
        code-review@claude-code-plugins
        documentation@claude-code-plugins

      # Custom MCP server config
      mcp_config: '.github/mcp-config.json'

      # Additional CLI args
      claude_args: |
        --system-prompt "You are a senior engineer focused on code quality"
```

</details>

<details>
<summary><strong>3.8. Common Cron Schedules</strong></summary>

| Schedule | Cron Expression | Description |
|----------|-----------------|-------------|
| Nightly | `0 2 * * *` | Every day at 2 AM UTC |
| Hourly | `0 * * * *` | Every hour |
| Weekly | `0 6 * * 1` | Every Monday at 6 AM UTC |
| Weekdays | `0 9 * * 1-5` | Mon-Fri at 9 AM UTC |
| Twice daily | `0 9,18 * * *` | 9 AM and 6 PM UTC |

</details>

### 3.1. Claude Nightly Analysis

<details>
<summary><strong>What it does</strong></summary>

- **Automated codebase analysis** on a schedule
- Discovers bugs, security issues, performance problems, refactoring opportunities
- Creates ONE high-impact GitHub issue per run
- Pre-configured prompt - no need to write complex analysis instructions
- Built on top of `claude-schedule.yml` (nested reusable workflow)

**Discovery categories:**
| Category | What it checks |
|----------|----------------|
| 🐛 Bugs | Null refs, race conditions, uncaught exceptions |
| 🔒 Security | Hardcoded secrets, injection vulnerabilities |
| ⚡ Performance | N+1 queries, memory leaks, blocking ops |
| 🔧 Refactor | Long functions, DRY violations, deep nesting |
| ✨ Enhance | Missing types, logging, hardcoded config |
| 📝 Docs/Tests | Missing docs, test coverage, TODOs |
| 🧹 Hygiene | Dead code, deprecated APIs, outdated deps |

</details>

<details>
<summary><strong>Installation</strong></summary>

Create `.github/workflows/nightly.yml`:

```yaml
name: Nightly Analysis

on:
  schedule:
    - cron: '0 2 * * *'  # Every day at 2 AM UTC
  workflow_dispatch:

jobs:
  analyze:
    uses: duyet/github-actions/.github/workflows/claude-nightly-analysis.yml@main
    permissions:
      contents: write
      pull-requests: write
      issues: write
      id-token: write
      actions: read
    secrets:
      api_key: ${{ secrets.OPENROUTER_API_KEY }}
```

</details>

<details>
<summary><strong>Configuration Options</strong></summary>

| Input | Default | Description |
|-------|---------|-------------|
| `provider` | `openrouter` | API provider: `openrouter`, `anthropic`, or `zai` |
| `model` | `@preset/claude-code-github-action` | Model to use |
| `allowed_tools` | `Read,Grep,Glob,Bash,Write,Edit` | Comma-separated list of allowed tools |
| `timeout_minutes` | `45` | Job timeout in minutes |
| `max_turns` | `50` | Maximum conversation turns |
| `extra_instructions` | (empty) | Additional instructions to append |
| `issue_labels` | `nightly-analysis,automated` | Labels for created issues |

</details>

<details>
<summary><strong>Customize</strong></summary>

```yaml
# Add extra analysis instructions
with:
  extra_instructions: |
    Also check for:
    - React hooks violations
    - Missing accessibility attributes
    - Unused CSS classes

# Custom labels for issues
with:
  issue_labels: 'bug,needs-triage,automated'

# Use Anthropic instead of OpenRouter
with:
  provider: 'anthropic'
secrets:
  api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# Longer timeout for large codebases
with:
  timeout_minutes: 60
  max_turns: '100'
```

</details>

<details>
<summary><strong>Issue Format</strong></summary>

Created issues follow this format:

**Title:** `[type] scope: description`
- Example: `[security] auth: remove hardcoded API key in config.ts`

**Body:**
```markdown
## Type
- [x] 🔒 Security

## Summary
Hardcoded API key found in configuration file.

## Location
- **File:** `src/config.ts`
- **Lines:** 15-17

## Current State
```typescript
const API_KEY = "sk-abc123...";
```

## Problem
Hardcoded secrets can be exposed in version control.

## Proposed Solution
```typescript
const API_KEY = process.env.API_KEY;
```

## Effort Estimate
- [x] Small (< 1 hour)

---
<details>
<summary>📊 Analysis metadata</summary>

| Property | Value |
|----------|-------|
| Model | @preset/claude-code-github-action |
| Provider | openrouter |
| Created by | [@duyetbot](https://github.com/duyetbot) |

</details>
```

</details>

---

## Documentation

<details>
<summary><strong>Full Documentation</strong></summary>

- **[INTEGRATING.md](INTEGRATING.md)** - Step-by-step setup guide
- **[CLAUDE.md](CLAUDE.md)** - Project guidelines and best practices
- **[GitHub Actions Docs](https://docs.github.com/en/actions)**
- **[Claude Code Action](https://github.com/anthropics/claude-code-action)**

</details>

<details>
<summary><strong>Links</strong></summary>

- OpenRouter: https://openrouter.ai
- Anthropic: https://console.anthropic.com
- GitHub Secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets

</details>

---

**Built by duyetbot**
