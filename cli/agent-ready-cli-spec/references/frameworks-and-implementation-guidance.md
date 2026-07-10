# Frameworks and Implementation Guidance

## Short answer on oclif

**Use oclif when the CLI is a serious, multi-command product surface** — especially if you need plugins, generated command docs, a Heroku/Salesforce-style command tree, TypeScript support, and long-term extensibility.

**Do not make oclif the default for every CLI.** For a small product CLI, internal tool, or agent-facing wrapper around a few workflows, `commander`, `yargs`, `clipanion`, or `cac` may be faster to build, easier to inspect, and easier for coding agents to modify.

Decision rule:

> Choose the smallest framework that gives you predictable parsing, generated/helpful help, noninteractive behavior, JSON output, testability, and long-term maintainability.

## Framework decision table

| Framework | Use when | Avoid when | Agent-readiness notes |
|---|---|---|---|
| **oclif** | Large Node/TS CLI, many subcommands, plugins, generated docs, durable product surface | Small wrapper CLI, minimal dependencies, simple one-command tool | Strong for structured command trees; ensure generated help includes examples, JSON flags, noninteractive paths, and tests. |
| **commander** | General-purpose Node CLI, straightforward commands, common patterns | Very complex nested command trees or plugin ecosystems | Simple and popular; easy for agents to inspect and modify. Add your own JSON/stdin/dry-run conventions. |
| **yargs** | Complex args/subcommands, config/env integration, mature parser behavior | You want very small dependency footprint or strict TS command modeling | Good command parsing; be deliberate about output conventions and no-TTY behavior. |
| **clipanion** | Type-safe TS CLI, Yarn-style command architecture, low runtime dependency posture | Team wants mainstream docs/community or stable non-RC surface only | Attractive for type-safe agent-facing CLIs, but check maturity/version constraints. |
| **cac** | Small, fast Node CLI with simple command definitions | Enterprise-grade docs/plugins/lifecycle expectations | Good for lightweight CLIs; you must supply quality gates yourself. |
| **Clack / prompts** | Human-friendly prompts and setup flows | Headless core commands | Use for optional human onboarding only. Do not make prompts the only path. |
| **Ink / Bubble Tea / TUI frameworks** | Rich terminal UI for humans | Agent/CI primary path | TUI should sit on top of headless CLI/API commands. |
| **Go Cobra / urfave/cli** | Static binary, ops/devtool distribution, no Node runtime | Need npm/npx distribution as primary path | Strong for agent workflows because install/runtime can be simple. |
| **Python Click/Typer** | Python/data/dev workflows, pipx/uvx distribution | Need single static binary or npm-native distribution | Good for internal/data tools; test clean install and env handling. |
| **Rust clap** | Fast/static/reliable CLI, strong typed parsing | Team lacks Rust capacity | Excellent for durable tools; more upfront engineering cost. |

## Captured package metadata

Captured 2026-07-02 via npm/GitHub APIs:

| Package/repo | Version / repo signal |
|---|---|
| `oclif` | npm `4.23.24`; `@oclif/core` npm `4.11.14`; repo `oclif/core` active |
| `commander` | npm `15.0.0`; repo `tj/commander.js` very widely starred |
| `yargs` | npm `18.0.0`; repo active |
| `clipanion` | npm `4.0.0-rc.4`; repo active; type-safe/no-runtime-dependency positioning |
| `cac` | npm `7.0.0`; repo active; simple/powerful positioning |
| `@clack/prompts` | npm `1.6.0`; human prompt layer, not headless CLI core |

Do not overinterpret star counts as quality; they are popularity signals, not architecture decisions.

## Recommended default stack by scenario

### Scenario A — serious SaaS/devtool CLI

Use:

- **Node/TypeScript + oclif** if npm distribution and plugin architecture matter.
- Or **Go/Rust** if single-binary install, CI/devops environments, and low dependency footprint matter more than npm-native distribution.

Must include:

- command contract doc;
- JSON schemas;
- dry-run/plan;
- auth status;
- verification commands;
- tests for stdout/stderr/exit codes/stdin/no-TTY.

### Scenario B — small agent-facing workflow wrapper

Use:

- `commander`, `yargs`, `clipanion`, or `cac` for Node;
- Python Typer/Click if the product/workflow is Python-native;
- Go Cobra/urfave if static binary helps.

Avoid overbuilding plugin architecture before the command contract is proven. (Input validation, safe error handling, and auth hygiene are baseline requirements, never "overbuilding.")

### Scenario C — human setup wizard plus agent automation

Use two layers:

1. Headless CLI commands: parseable, noninteractive, JSON, stdin, exit codes.
2. Optional human setup: Clack/prompts/Ink/TUI that calls the headless commands underneath.

Rule:

> If a prompt/TUI can do it, a headless command must be able to do it too.

### Scenario D — chatbot/assistant user is primary

Do not lead with CLI. Lead with:

- MCP/tools/actions for assistant surfaces;
- Skill/runbook for behavior;
- API underneath;
- CLI only as a secondary surface for coding agents and CI.

## Implementation contract before coding

Before choosing a framework, write:

1. Primary workflows.
2. Command tree.
3. Input sources and config precedence.
4. JSON output schemas.
5. Error codes and exit-code semantics.
6. Mutating-command safety rules.
7. Verification commands.
8. Test plan.
9. Distribution path.
10. Agent eval prompt.

Framework choice should serve this contract, not substitute for it.

## Default exit-code and error-code table

Use this scheme unless the project already has a convention — don't invent a new one per CLI:

| Exit code | Meaning | Error code examples |
|---:|---|---|
| 0 | Success | — |
| 1 | Unexpected/internal error | `E_INTERNAL` |
| 2 | Usage/validation error (bad flag, invalid argument) | `E_USAGE`, `E_VALIDATION` |
| 3 | Resource not found | `E_NOT_FOUND` |
| 4 | Auth failure (distinguish in the error code) | `E_AUTH_MISSING`, `E_AUTH_INVALID`, `E_AUTH_FORBIDDEN` |
| 5 | Conflict / precondition failed | `E_CONFLICT` |
| 6 | Rate limited | `E_RATE_LIMIT` |
| 7 | Upstream API/server error | `E_API` |

Error output rules: human-readable message on stderr; in `--json` mode also emit a machine envelope `{"error": {"code": "E_NOT_FOUND", "message": "...", "hint": "..."}}`. Real APIs return 401/403/429 even when the OpenAPI file omits them — spec and implement these paths anyway, marked as inferred.

**Crash-shaped errors carry two extra fields.** The envelope above is right for taxonomized failures the CLI expects — validation, auth, not-found, conflict, rate-limit. `E_INTERNAL` is different: it means something broke that nobody anticipated, and whoever hits it needs to file a bug. Add the installed version and a report path to that case only:

```json
{"error": {"code": "E_INTERNAL", "message": "...", "hint": "...",
           "version": "1.2.3", "reportUrl": "https://github.com/<org>/<repo>/issues"}}
```

The version tells a maintainer which build produced the trace; the report path tells an agent where to send it. Use a route that actually exists — if the repo has no issues URL yet, omit `reportUrl` and say in the message where to report instead. Never invent a link. Routine errors do not carry these fields.

**`--json` is a promise about stderr, not about your error handler.** It means *every byte the process writes to stderr is parseable JSON* — including errors the CLI framework emits before your code runs. This is the single easiest agent-readiness item to miss, because the tests you would naturally write all exercise your own error paths, which already work.

Most frameworks print their own plain text and exit for: an unknown subcommand, an unknown flag, and a missing required option. That output never passes through your envelope. Verify by running each of these and piping stderr to a JSON parser:

```bash
tool bogus-subcommand --json          # unknown command
tool tasks list --bogus-flag --json   # unknown flag
tool tasks create --json              # required flag omitted
```

All three must emit a valid envelope with `E_USAGE` and exit 2. In Commander, reach this by disabling its own exit and writer (`exitOverride()`, and a `configureOutput` whose `writeErr` discards), catching the error it throws, and routing it through the same reporter as every other error. Other frameworks name it differently — argparse, cobra, and clap all have an equivalent hook. The rule is the same: your reporter is the only thing allowed to write to stderr.

Test all three paths explicitly. A test named for JSON output that only exercises application errors will pass while the contract is broken.

## Testing without live credentials

Tests must pass in a clean clone with no secrets set. Preferred pattern: start a local HTTP stub server inside the test suite and point the CLI's `--base-url`/`TOOL_BASE_URL` override at it — this exercises the real HTTP client and justifies the base-URL config existing at all. Caution: interception libraries like nock do not catch Node's native fetch (undici) by default; a real local server avoids the trap. Keep any live-API tests in a separate, optional test target gated on credential presence.

## Node implementation notes

For any Node CLI:

- Use `#!/usr/bin/env node`.
- Define `bin` explicitly in `package.json`.
- Declare supported Node versions in `engines`.
- Keep dependency footprint intentional.
- Consider `npm-shrinkwrap.json` or bundling for published CLIs where deterministic transitive deps matter.
- Use safe child process APIs: prefer `execFile`/`spawn` with arg arrays over shell string concatenation.
- Test on macOS/Linux and document Windows support honestly.

## Good builder prompt

```text
You are building an agent-ready CLI for [PRODUCT].

Before coding, produce:
1. command tree;
2. JSON schemas;
3. exit-code table;
4. error-code table;
5. config precedence;
6. auth model;
7. dry-run/plan behavior;
8. verification commands;
9. framework recommendation with tradeoffs;
10. test plan.

Then implement the smallest CLI that passes the agent eval:
discover → auth status → inspect → dry-run/plan → act with explicit confirmation → verify → summarize evidence.
```
