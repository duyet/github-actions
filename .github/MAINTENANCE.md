# GitHub Actions Workflows - Maintenance Guide

## MCP Configuration Management

### Source of Truth

The `.github/mcp-config.json` file is the **canonical source** for default MCP server configuration across all reusable workflows in this repository.

### How It Works

Reusable workflows (like `claude-schedule.yml`) cannot read files from this repository when called from other repos. To solve this:

1. **File-based config** (`.github/mcp-config.json`):
   - Used for direct workflows in the same repo
   - Serves as documentation
   - Easy to edit and validate

2. **Workflow env var** (`env.DEFAULT_MCP_CONFIG`):
   - Embedded in reusable workflows
   - Works cross-repo
   - Must stay in sync with file

3. **Validation workflow** (`validate-mcp-config.yml`):
   - Automatically checks sync on PRs
   - Comments if configs diverge

### Adding/Updating MCP Servers

When adding a new MCP server:

1. **Update the file:**
   ```bash
   # Edit .github/mcp-config.json
   cat > .github/mcp-config.json << 'EOF'
   {
     "mcpServers": {
       "sequential-thinking": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
       },
       "new-server": {
         "command": "path/to/command",
         "args": ["arg1", "arg2"]
       }
     }
   }
   EOF
   ```

2. **Update the workflow env var:**
   ```yaml
   # In .github/workflows/claude-schedule.yml
   env:
     DEFAULT_MCP_CONFIG: '{"mcpServers":{"sequential-thinking":{"command":"npx","args":["-y","@modelcontextprotocol/server-sequential-thinking"]},"new-server":{"command":"path/to/command","args":["arg1","arg2"]}}}'
   ```

3. **Verify sync:**
   ```bash
   # Run validation workflow
   gh workflow run validate-mcp-config.yml
   ```

### Workflow Reference

| Workflow | Type | MCP Config Source |
|----------|------|-------------------|
| `claude.yml` | Direct | `.github/mcp-config.json` file |
| `claude-code-review.yml` | Direct | `.github/mcp-config.json` file |
| `claude-schedule.yml` | Reusable | `env.DEFAULT_MCP_CONFIG` |
| `claude-nightly-analysis.yml` | Reusable | Passes through to `claude-schedule.yml` |

### Testing Changes

After updating MCP config:

1. **Validate locally:**
   ```bash
   # Ensure JSON is valid
   cat .github/mcp-config.json | jq .
   ```

2. **Create PR:**
   - Validation workflow auto-runs
   - Fixes any sync issues

3. **Test in caller repo:**
   ```yaml
   # Test with inline override
   - uses: duyet/github-actions/.github/workflows/claude-schedule.yml@main
     with:
       mcp_config: '{"mcpServers":{...}}'  # Test new config
   ```

### Troubleshooting

**Validation failing:**
- Check that both file and workflow env have identical JSON (whitespace ignored)
- Ensure JSON is valid (use `jq .` to validate)

**Cross-repo callers not getting new config:**
- They need to update their `@main` ref to get latest workflow
- Or they can override with `mcp_config` input

**MCP server not starting:**
- Verify command exists in runner environment
- Check args are properly formatted as JSON array
- Test locally: `npx -y @modelcontextprotocol/server-sequential-thinking`

## Plugin Marketplace Management

The default plugin marketplace is `https://github.com/duyet/claude-plugins`.

To change it:

1. Update `env.DEFAULT_PLUGIN_MARKETPLACE` in affected workflows
2. Document in this guide
3. Update validation workflow if needed

## Commit Signing

The `issue-plan` job uses `use_commit_signing: true` for verified commits.

- Trade-off: Cannot perform complex git operations (rebase, etc.)
- Benefits: Verified commits show in GitHub UI
- Alternative: Use SSH signing key for full git operations

## Related Documentation

- [Claude Code Action Docs](https://github.com/anthropics/claude-code-action)
- [GitHub Actions Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [MCP Specification](https://modelcontextprotocol.io/)
