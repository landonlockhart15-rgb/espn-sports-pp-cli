---
name: pp-espn-sports
description: "Printing Press CLI for Espn Sports. Multi-sport CLI spec for live scores and game summaries from ESPN."
author: "landonlockhart15-rgb"
license: "Apache-2.0"
argument-hint: "<command> [args] | install cli|mcp"
allowed-tools: "Read Bash"
metadata:
  openclaw:
    requires:
      bins:
        - espn-sports-pp-cli
---

# Espn Sports — Printing Press CLI

## Prerequisites: Install the CLI

This skill drives the `espn-sports-pp-cli` binary. **You must verify the CLI is installed before invoking any command from this skill.** If it is missing, install it first:

1. Install via the Printing Press installer:
   ```bash
   npx -y @mvanhorn/printing-press install espn-sports --cli-only
   ```
2. Verify: `espn-sports-pp-cli --version`
3. Ensure `$GOPATH/bin` (or `$HOME/go/bin`) is on `$PATH`.

If the `npx` install fails before this CLI has a public-library category, install Node or use the category-specific Go fallback after publish.

If `--version` reports "command not found" after install, the install step did not put the binary on `$PATH`. Do not proceed with skill commands until verification succeeds.

Multi-sport CLI spec for live scores and game summaries from ESPN.

## When Not to Use This CLI

Do not activate this CLI for requests that require creating, updating, deleting, publishing, commenting, upvoting, inviting, ordering, sending messages, booking, purchasing, or changing remote state. This printed CLI exposes read-only commands for inspection, export, sync, and analysis.

## Command Reference

**site** — Manage site

- `espn-sports-pp-cli site get-nba-scoreboard` — Return the current NBA scoreboard payload from ESPN.
- `espn-sports-pp-cli site get-nba-summary` — Return an NBA game's summary and box score from ESPN.
- `espn-sports-pp-cli site get-ncaab-scoreboard` — Return the current NCAA men's basketball scoreboard payload from ESPN.
- `espn-sports-pp-cli site get-ncaab-summary` — Return an NCAA men's basketball game's summary and box score from ESPN.
- `espn-sports-pp-cli site get-ncaaf-scoreboard` — Return the current NCAA football scoreboard payload from ESPN.
- `espn-sports-pp-cli site get-ncaaf-summary` — Return an NCAA football game's summary and box score from ESPN.
- `espn-sports-pp-cli site get-nfl-scoreboard` — Return the current NFL scoreboard payload from ESPN.
- `espn-sports-pp-cli site get-nfl-summary` — Return an NFL game's summary and box score from ESPN.


### Finding the right command

When you know what you want to do but not which command does it, ask the CLI directly:

```bash
espn-sports-pp-cli which "<capability in your own words>"
```

`which` resolves a natural-language capability query to the best matching command from this CLI's curated feature index. Exit code `0` means at least one match; exit code `2` means no confident match — fall back to `--help` or use a narrower query.

## Auth Setup

No authentication required.

Run `espn-sports-pp-cli doctor` to verify setup.

## Agent Mode

Add `--agent` to any command. Expands to: `--json --compact --no-input --no-color --yes`.

- **Pipeable** — JSON on stdout, errors on stderr
- **Filterable** — `--select` keeps a subset of fields. Dotted paths descend into nested structures; arrays traverse element-wise. Critical for keeping context small on verbose APIs:

  ```bash
  espn-sports-pp-cli site get-nba-scoreboard --agent --select id,name,status
  ```
- **Previewable** — `--dry-run` shows the request without sending
- **Offline-friendly** — sync/search commands can use the local SQLite store when available
- **Non-interactive** — never prompts, every input is a flag
- **Read-only** — do not use this CLI for create, update, delete, publish, comment, upvote, invite, order, send, or other mutating requests

### Response envelope

Commands that read from the local store or the API wrap output in a provenance envelope:

```json
{
  "meta": {"source": "live" | "local", "synced_at": "...", "reason": "..."},
  "results": <data>
}
```

Parse `.results` for data and `.meta.source` to know whether it's live or local. A human-readable `N results (live)` summary is printed to stderr only when stdout is a terminal — piped/agent consumers get pure JSON on stdout.

## Agent Feedback

When you (or the agent) notice something off about this CLI, record it:

```
espn-sports-pp-cli feedback "the --since flag is inclusive but docs say exclusive"
espn-sports-pp-cli feedback --stdin < notes.txt
espn-sports-pp-cli feedback list --json --limit 10
```

Entries are stored locally at `~/.espn-sports-pp-cli/feedback.jsonl`. They are never POSTed unless `ESPN_SPORTS_FEEDBACK_ENDPOINT` is set AND either `--send` is passed or `ESPN_SPORTS_FEEDBACK_AUTO_SEND=true`. Default behavior is local-only.

Write what *surprised* you, not a bug report. Short, specific, one line: that is the part that compounds.

## Output Delivery

Every command accepts `--deliver <sink>`. The output goes to the named sink in addition to (or instead of) stdout, so agents can route command results without hand-piping. Three sinks are supported:

| Sink | Effect |
|------|--------|
| `stdout` | Default; write to stdout only |
| `file:<path>` | Atomically write output to `<path>` (tmp + rename) |
| `webhook:<url>` | POST the output body to the URL (`application/json` or `application/x-ndjson` when `--compact`) |

Unknown schemes are refused with a structured error naming the supported set. Webhook failures return non-zero and log the URL + HTTP status on stderr.

## Named Profiles

A profile is a saved set of flag values, reused across invocations. Use it when a scheduled agent calls the same command every run with the same configuration - HeyGen's "Beacon" pattern.

```
espn-sports-pp-cli profile save briefing --json
espn-sports-pp-cli --profile briefing site get-nba-scoreboard
espn-sports-pp-cli profile list --json
espn-sports-pp-cli profile show briefing
espn-sports-pp-cli profile delete briefing --yes
```

Explicit flags always win over profile values; profile values win over defaults. `agent-context` lists all available profiles under `available_profiles` so introspecting agents discover them at runtime.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 2 | Usage error (wrong arguments) |
| 3 | Resource not found |
| 5 | API error (upstream issue) |
| 7 | Rate limited (wait and retry) |
| 10 | Config error |

## Argument Parsing

Parse `$ARGUMENTS`:

1. **Empty, `help`, or `--help`** → show `espn-sports-pp-cli --help` output
2. **Starts with `install`** → ends with `mcp` → MCP installation; otherwise → see Prerequisites above
3. **Anything else** → Direct Use (execute as CLI command with `--agent`)

## MCP Server Installation

Install the MCP binary from this CLI's published public-library entry or pre-built release, then register it:

```bash
claude mcp add espn-sports-pp-mcp -- espn-sports-pp-mcp
```

Verify: `claude mcp list`

## Direct Use

1. Check if installed: `which espn-sports-pp-cli`
   If not found, offer to install (see Prerequisites at the top of this skill).
2. Match the user query to the best command from the Unique Capabilities and Command Reference above.
3. Execute with the `--agent` flag:
   ```bash
   espn-sports-pp-cli <command> [subcommand] [args] --agent
   ```
4. If ambiguous, drill into subcommand help: `espn-sports-pp-cli <command> --help`.
