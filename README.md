# ESPN Sports CLI

**Status:** Generated/maintained CLI spec for agent use  
**Audience:** Developers and AI agents that need scriptable access to ESPN scoreboard and game-summary data.  
**Design goal:** Provide a read-only, non-interactive CLI with predictable JSON output, dry-run support, and agent-safe defaults.

A multi-sport CLI for live scores and game summaries from ESPN.

## Why this exists

Sports data is useful to agents only when it is easy to call, parse, and filter. This CLI is designed to expose common ESPN scoreboard and summary endpoints through stable commands that work in terminals, scripts, and AI-agent workflows.

## Install

The recommended path installs both the `espn-sports-pp-cli` binary and the `pp-espn-sports` agent skill in one shot:

```bash
npx -y @mvanhorn/printing-press install espn-sports
```

For CLI only, without the skill:

```bash
npx -y @mvanhorn/printing-press install espn-sports --cli-only
```

### Without Node

The generated install path is category-agnostic until this CLI is published. If `npx` is not available before publish, install Node or use the category-specific Go fallback from the public-library entry after publish.

### Pre-built binary

Download a pre-built binary for your platform from the [latest release](https://github.com/mvanhorn/printing-press-library/releases/tag/espn-sports-current). On macOS, clear the Gatekeeper quarantine:

```bash
xattr -d com.apple.quarantine <binary>
```

On Unix, mark it executable:

```bash
chmod +x <binary>
```

<!-- pp-hermes-install-anchor -->
## Install for Hermes

From the Hermes CLI:

```bash
hermes skills install mvanhorn/printing-press-library/cli-skills/pp-espn-sports --force
```

Inside a Hermes chat session:

```bash
/skills install mvanhorn/printing-press-library/cli-skills/pp-espn-sports --force
```

## Install for OpenClaw

Tell your OpenClaw agent:

```text
Install the pp-espn-sports skill from https://github.com/mvanhorn/printing-press-library/tree/main/cli-skills/pp-espn-sports. The skill defines how its required CLI can be installed.
```

## Quick start

### 1. Install

See [Install](#install) above.

### 2. Verify setup

```bash
espn-sports-pp-cli doctor
```

This checks your configuration.

### 3. Try a command

```bash
espn-sports-pp-cli site get-nba-scoreboard
```

## Usage

Run the full command reference:

```bash
espn-sports-pp-cli --help
```

## Commands

### site

- **`espn-sports-pp-cli site get-nba-scoreboard`** - Return the current NBA scoreboard payload from ESPN.
- **`espn-sports-pp-cli site get-nba-summary`** - Return an NBA game's summary and box score from ESPN.
- **`espn-sports-pp-cli site get-ncaab-scoreboard`** - Return the current NCAA men's basketball scoreboard payload from ESPN.
- **`espn-sports-pp-cli site get-ncaab-summary`** - Return an NCAA men's basketball game's summary and box score from ESPN.
- **`espn-sports-pp-cli site get-ncaaf-scoreboard`** - Return the current NCAA football scoreboard payload from ESPN.
- **`espn-sports-pp-cli site get-ncaaf-summary`** - Return an NCAA football game's summary and box score from ESPN.
- **`espn-sports-pp-cli site get-nfl-scoreboard`** - Return the current NFL scoreboard payload from ESPN.
- **`espn-sports-pp-cli site get-nfl-summary`** - Return an NFL game's summary and box score from ESPN.

## Output formats

```bash
# Human-readable table in a terminal, JSON when piped
espn-sports-pp-cli site get-nba-scoreboard

# JSON for scripting and agents
espn-sports-pp-cli site get-nba-scoreboard --json

# Filter to specific fields
espn-sports-pp-cli site get-nba-scoreboard --json --select id,name,status

# Dry run: show the request without sending
espn-sports-pp-cli site get-nba-scoreboard --dry-run

# Agent mode: JSON + compact + no prompts
espn-sports-pp-cli site get-nba-scoreboard --agent
```

## Agent usage

This CLI is designed for AI-agent consumption:

- **Non-interactive:** never prompts; every input is a flag.
- **Pipeable:** JSON output to stdout, errors to stderr.
- **Filterable:** `--select id,name` returns only the fields needed.
- **Previewable:** `--dry-run` shows the request without sending it.
- **Read-only by default:** does not create, update, delete, publish, send, or mutate remote resources.
- **Offline-friendly:** sync/search commands can use the local SQLite store when available.
- **Agent-safe by default:** no colors or formatting unless `--human-friendly` is set.

Exit codes: `0` success, `2` usage error, `3` not found, `5` API error, `7` rate limited, `10` config error.

## Use with Claude Code

Install the focused skill. It auto-installs the CLI on first invocation:

```bash
npx skills add mvanhorn/printing-press-library/cli-skills/pp-espn-sports -g
```

Then invoke `/pp-espn-sports <query>` in Claude Code. The skill is the most efficient path because Claude Code drives the CLI directly without an MCP server in the middle.

<details>
<summary>Use as an MCP server in Claude Code (advanced)</summary>

If you would rather register this CLI as an MCP server in Claude Code, install the MCP binary first.

Then register it:

```bash
claude mcp add espn-sports espn-sports-pp-mcp
```

</details>

## Use with Claude Desktop

This CLI ships an [MCPB](https://github.com/modelcontextprotocol/mcpb) bundle, Claude Desktop's standard format for one-click MCP extension installs.

To install:

1. Download the `.mcpb` for your platform from the [latest release](https://github.com/mvanhorn/printing-press-library/releases/tag/espn-sports-current).
2. Double-click the `.mcpb` file. Claude Desktop opens and walks you through the install.

Requires Claude Desktop 1.0.0 or later. Pre-built bundles ship for macOS Apple Silicon (`darwin-arm64`) and Windows (`amd64`, `arm64`). For other platforms, use the manual config below.

<details>
<summary>Manual JSON config (advanced)</summary>

If you cannot use the MCPB bundle, install the MCP binary and configure it manually.

Add this to your Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "espn-sports": {
      "command": "espn-sports-pp-mcp"
    }
  }
}
```

</details>

## Health check

```bash
espn-sports-pp-cli doctor
```

Verifies configuration and connectivity to the API.

## Configuration

Config file:

```text
~/.config/espn-sports-sample-pp-cli/config.toml
```

Static request headers can be configured under `headers`; per-command header overrides take precedence.

## Safety and limitations

- This CLI is read-only by design.
- ESPN endpoint behavior can change; run `doctor` when troubleshooting.
- Do not use this project to bypass terms of service or rate limits.

## Troubleshooting

**Not found errors, exit code 3**

- Check that the resource ID is correct.
- Run a list/scoreboard command to discover available items.

---

Generated by [CLI Printing Press](https://github.com/mvanhorn/cli-printing-press).
