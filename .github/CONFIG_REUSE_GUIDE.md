# GitHub Actions Configuration Reuse Guide

## Overview

This repository uses a **hybrid configuration approach** with fallback defaults, enabling both same-repo optimization and cross-repo compatibility.

## Key Insight: Cross-Repo Compatibility

**The Challenge:** Reusable workflows cannot read files from the workflow's repository when called from other repositories.

**The Solution:** The composite action includes fallback defaults that work cross-repo without any setup.

```
┌─────────────────────────────────────────────────────────────────────┐
│ Cross-Repo Usage Pattern                                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  Caller Repo (other-org/their-repo)                                 │
│  └── uses: duyet/github-actions/.github/workflows/claude-schedule.yml │
│                                                                       │
│  duyet/github-actions (this repo)                                     │
│  └── .github/actions/claude-setup/action.yml                           │
│      ├── Try: Read .github/claude-defaults.json                       │
│      ├── File not found in caller? → Use fallback defaults ✅         │
│      └── Output: All configuration values                              │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Architecture

```
.github/
├── claude-defaults.json              # Single source of truth for configuration
├── mcp-config.json                   # MCP server configuration
├── actions/
│   └── claude-setup/
│       └── action.yml                 # Composite action for config loading
└── workflows/
    ├── claude.yml                     # Main interactive workflow
    ├── claude-schedule.yml            # Original schedule workflow
    ├── claude-schedule-v2.yml         # NEW: Using composite action
    └── ...
```

## Components

### 1. Configuration File: `.github/claude-defaults.json`

**Purpose:** Single source of truth for all Claude Code configuration

**Contains:**
- Bot configuration (id, name)
- API defaults (provider, model)
- Plugin marketplaces
- MCP config paths and fallbacks
- Timeout profiles per workflow type
- Tool profiles per workflow type
- Permission templates

**Example:**
```json
{
  "bot": { "id": "101855044", "name": "duyetbot" },
  "api": { "default_provider": "openrouter", "default_model": "@preset/claude-code-github-action" },
  "plugins": { "marketplaces": ["https://github.com/duyet/claude-plugins"] },
  "mcp": {
    "default_config_path": ".github/mcp-config.json",
    "default_inline_config": { "mcpServers": { ... } }
  },
  "timeouts": { "interactive": 30, "schedule": 60, "review": 30 },
  "tool_profiles": {
    "review": "Read,Grep,Glob,Bash,Plan",
    "interactive": "Read,Grep,Glob,Bash,Write,Edit,Skill,..."
  }
}
```

### 2. Composite Action: `.github/actions/claude-setup/action.yml`

**Purpose:** Load and validate configuration from `claude-defaults.json`

**Features:**
- ✅ Reads and parses JSON configuration
- ✅ Validates JSON syntax
- ✅ Extracts workflow-specific settings (tools, timeout)
- ✅ Handles MCP config fallback (file → inline)
- ✅ Provides structured outputs for workflows
- ✅ Displays configuration summary in logs
- ✅ Validates MCP configuration

**Outputs:**
```yaml
bot_id, bot_name, provider, provider_base_url, model,
allowed_tools, plugin_marketplaces, mcp_config, timeout
```

**Usage:**
```yaml
- name: Setup Claude Environment
  id: claude-setup
  uses: ./.github/actions/claude-setup
  with:
    workflow_type: 'schedule'  # or 'review', 'interactive', 'plan'
    mcp_config: ''             # optional override
```

### 3. MCP Configuration: `.github/mcp-config.json`

**Purpose:** MCP server configuration (can be used by direct workflows)

**Note:** Reusable workflows cannot read this file from this repo when called cross-repo, so inline fallback is used.

## Migration Guide

### From Old Workflow to New Pattern

**Before (duplication):**
```yaml
jobs:
  task:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v6
      - uses: anthropics/claude-code-action@v1
        env:
          ANTHROPIC_DEFAULT_HAIKU_MODEL: '@preset/claude-code-github-action'
          ANTHROPIC_DEFAULT_SONNET_MODEL: '@preset/claude-code-github-action'
          ...
        with:
          bot_id: '101855044'
          bot_name: 'duyetbot'
          provider: 'openrouter'
          ...
```

**After (reuse):**
```yaml
jobs:
  task:
    runs-on: ubuntu-latest
    timeout-minutes: 60  # from config
    steps:
      - uses: actions/checkout@v6
      - id: claude-setup
        uses: ./.github/actions/claude-setup
        with:
          workflow_type: 'schedule'
      - uses: anthropics/claude-code-action@v1
        env:
          ANTHROPIC_BASE_URL: ${{ steps.claude-setup.outputs.provider_base_url }}
          ANTHROPIC_DEFAULT_HAIKU_MODEL: ${{ steps.claude-setup.outputs.model }}
          ...
        with:
          bot_id: ${{ steps.claude-setup.outputs.bot_id }}
          bot_name: ${{ steps.claude-setup.outputs.bot_name }}
          ...
```

## Benefits

| Before | After |
|--------|-------|
| 8+ duplicated input definitions | 3 essential inputs |
| Hardcoded values in each workflow | Single source of truth |
| Timeout defined per workflow | Centralized timeout profiles |
| Tools listed per workflow | Tool profiles by type |
| MCP config duplicated | Configurable with fallback |

## Updating Configuration

### To change bot name:
1. Edit `.github/claude-defaults.json` → `bot.name`
2. No workflow changes needed!

### To add a new MCP server:
1. Edit `.github/mcp-config.json`
2. Edit `.github/claude-defaults.json` → `mcp.default_inline_config`
3. Validation workflow will check sync

### To add a new workflow type:
1. Edit `.github/claude-defaults.json` → add to `tool_profiles` and `timeouts`
2. Use in composite action with `workflow_type: 'new-type'`

### To change plugin marketplace:
1. Edit `.github/claude-defaults.json` → `plugins.marketplaces`
2. All workflows automatically updated!

## Decision Matrix

| Pattern | Use When | Example |
|---------|----------|---------|
| **claude-defaults.json** | Sharing configuration values | Bot ID, model, timeouts |
| **Composite Action** | Loading config + validation | `claude-setup` |
| **Reusable Workflow** | Sharing complete pipelines | `claude-schedule.yml` |
| **YAML Anchors** | Same-file duplication | Permissions in one file |
| **Repository Variables** | Environment-specific values | Dev/staging/prod differences |

## Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| **Config File + Composite** | Single source, flexible, validated | Extra step in workflow |
| **Workflow Env Vars** | No extra step | Duplication across files |
| **YAML Anchors** | Native, simple | Same-file only |
| **Repository Variables** | UI-manageable | No version control |

## Validation

The `.github/workflows/validate-mcp-config.yml` workflow automatically checks that:
- `.github/mcp-config.json` is valid JSON
- `.github/claude-defaults.json` is valid JSON
- MCP config matches between file and inline fallback

## Examples

See `.github/workflows/claude-schedule.yml` for a complete example using the new pattern.

## Related Files

- `.github/claude-defaults.json` - Configuration source of truth
- `.github/actions/claude-setup/action.yml` - Composite action for setup
- `.github/workflows/claude-schedule.yml` - Updated workflow using composite action
- `.github/workflows/validate-mcp-config.yml` - MCP config validation
- `.github/MAINTENANCE.md` - Maintenance guide

## File Changes Summary

**Created:**
- ✅ `.github/claude-defaults.json` - Configuration source of truth
- ✅ `.github/actions/claude-setup/action.yml` - Composite action with cross-repo fallback
- ✅ `.github/CONFIG_REUSE_GUIDE.md` - This documentation

**Updated:**
- ✅ `.github/workflows/claude-schedule.yml` - Uses composite action with absolute reference
- ✅ `CLAUDE.md` - Added cross-repo usage documentation

## Cross-Repo Usage Verification

The composite action has been tested to work in both scenarios:

**Scenario 1: Same-repo usage** (e.g., workflows in duyet/github-actions)
- ✅ Reads `.github/claude-defaults.json` from same repo
- ✅ Falls back to inline defaults if file missing

**Scenario 2: Cross-repo usage** (e.g., other-org/their-repo calling these workflows)
- ✅ Config file doesn't exist in caller's repo
- ✅ Uses fallback defaults from composite action inputs
- ✅ Works without any setup in caller's repository

## Summary of Benefits

| Before | After |
|--------|-------|
| Hardcoded defaults in each workflow | Single source of truth + fallbacks |
| Duplication across workflows | Composite action with built-in defaults |
| Cross-repo required file copying | Works out of the box with fallbacks |
| Updates required editing 4+ files | Update 1 JSON file + composite action |
