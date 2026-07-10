# Agent-Ready CLI Checklist v2

*A practical checklist for designing command-line interfaces that coding agents can discover, run, verify, and recover from.*

## Positioning

A good CLI is not just a developer convenience. It is an **executable product interface** for agents.

Classic CLI best practices still matter. But agent-ready CLIs need one more contract:

> An agent must be able to discover the workflow, inspect current state, plan safely, act explicitly, verify the result, and recover from failure without guessing.

## Who this is for

Use this when your product should be usable by coding agents such as Claude Code, Codex, Cursor/IDE-style agents, Replit-style agents, CI/workflow agents, or any agent with:

- shell access;
- filesystem access;
- network access;
- environment variables/config;
- ability to run commands and inspect stdout/stderr/exit codes.

This is **not primarily for chat-only assistants** unless they have tool execution access. Chatbot/assistant surfaces usually need MCP/tools/actions plus Skills; terminal-capable agents can use CLIs directly.

---

## The agent execution loop

Every important workflow should support:

```text
discover → authenticate → inspect → plan/dry-run → act → verify → recover/summarize
```

If the agent cannot prove what changed, the workflow is not agent-ready.

---

# Checklist

## 1. Product-surface fit

- [ ] The team has identified the primary actor: human user, local coding agent, hosted coding agent, CI agent, chatbot/assistant agent, or integration partner.
- [ ] The workflow is a good CLI fit: repeatable, scriptable, inspectable, local/dev/project-oriented, CI-friendly, import/export-heavy, or operational.
- [ ] The team has decided which layers are needed: API, CLI, MCP, Skill, UI, TUI, desktop app, mobile app.
- [ ] The CLI is not being used as a substitute for MCP when the target user is a chat-only assistant.
- [ ] The CLI is not being used as a substitute for UI when the workflow is primarily visual, exploratory, or nontechnical-human-facing.
- [ ] The CLI sits on a stable product capability/API layer where possible, rather than duplicating business logic inconsistently.

## 2. Discoverability

- [ ] `tool --help` exists.
- [ ] `tool <resource> --help` exists.
- [ ] `tool <resource> <action> --help` exists for multi-command CLIs.
- [ ] Help works with both `--help` and `-h` where appropriate.
- [ ] Help text leads with real examples, not only flag descriptions.
- [ ] Help text shows the most common workflows first.
- [ ] Help text links to web docs and support/issue paths.
- [ ] Docs show the top 5 workflows as copy-paste commands.
- [ ] If the user mistypes a command, the CLI suggests likely corrections without silently running a different command.

## 3. Predictable command grammar

- [ ] Commands follow a consistent grammar, e.g. `tool <resource> <verb> [args] [flags]`.
- [ ] Resource names are consistent across commands.
- [ ] Flag names are consistent: do not mix `--project`, `--project-id`, and `--pid` randomly.
- [ ] Similar commands behave similarly.
- [ ] Aliases do not have surprising different semantics.
- [ ] POSIX-style conventions are respected where practical: `--long-flag`, `-s`, optional args in `[brackets]`, required args in `<angle-brackets>`.
- [ ] A real argument parsing library/framework is used rather than custom brittle parsing.

## 4. Noninteractive automation path

- [ ] Core workflows can run without a TTY.
- [ ] Interactive prompts have flag/env/config alternatives.
- [ ] Confirmation flags are explicit: `--confirm`, `--yes`, or equivalent.
- [ ] The CLI never hangs invisibly waiting for input in automation mode.
- [ ] Browser-based auth is not the only path for agent workflows.
- [ ] Rich prompts/TUIs are optional human affordances layered on top of headless commands.
- [ ] When stdin is a TTY and required input is missing, the CLI either prompts intentionally or fails clearly.
- [ ] When stdin is piped/non-TTY, input-consuming commands read it instead of prompting.

## 5. Machine-readable I/O

- [ ] `--json` is available for inspect/action commands.
- [ ] JSON output is valid JSON and parseable without stripping banners, spinners, or progress text.
- [ ] JSON schemas are stable across versions or versioned explicitly.
- [ ] Primary data/result output goes to stdout.
- [ ] Errors, warnings, progress, diagnostics, and logs go to stderr.
- [ ] Human formatting does not break machine parsing.
- [ ] Color can be disabled with `--no-color` and/or `NO_COLOR`.
- [ ] Spinners/progress bars degrade gracefully when stdout is not a TTY.
- [ ] `--quiet`, `--verbose`, and/or `--debug` exist where useful.
- [ ] If plain tabular output is useful for `grep`/`awk`, a stable `--plain` or equivalent mode exists.

## 6. Composability and stdin

- [ ] Commands work in scripts and CI.
- [ ] Input-consuming commands support stdin by default when data is piped.
- [ ] Explicit stdin forms are supported where useful: `--stdin`, `-f -`, or equivalent.
- [ ] The Unix `-` convention is documented where relevant: in file/input positions, `-` means “read from stdin.”
- [ ] Commands support files and pipes where useful.
- [ ] Output is deterministic enough for tests.
- [ ] Commands avoid hidden global state where possible.
- [ ] Config precedence is documented: flags > env vars > project config > user config > system config.

Examples:

```bash
cat input.json | tool import --json
tool apply -f - < config.yaml
tool projects list --json | jq '.projects[].id'
```

## 7. Authentication and environment

- [ ] Env-var auth is supported where appropriate, e.g. `ACME_API_KEY`.
- [ ] Config-file auth is documented.
- [ ] `auth login` exists for humans where auth is interactive (OAuth/browser flows). For plain API-key schemes, documented key acquisition plus `auth status` satisfies this item.
- [ ] `auth status --json` exists for agents.
- [ ] Missing, expired, and insufficient credentials fail differently and clearly.
- [ ] Required scopes/permissions are documented.
- [ ] Secret handling avoids printing tokens in stdout/stderr/logs/debug output.
- [ ] Proxy/network configuration is documented if relevant.

## 8. Inspectability and verification

- [ ] Every action has a way to inspect current state before acting.
- [ ] Every action has a way to verify the result after acting.
- [ ] `get`, `status`, `list`, `logs`, `history`, or equivalent commands exist where relevant.
- [ ] Verification commands support `--json`.
- [ ] Mutating commands return resource IDs that can be checked later.
- [ ] Docs teach “inspect → act → verify” workflows.
- [ ] The CLI can summarize what changed without relying on human-only UI state.

## 9. Safe side effects

- [ ] Destructive commands require explicit confirmation.
- [ ] `--dry-run`, `plan`, or equivalent is available before meaningful side effects.
- [ ] Dry-run output is specific enough to predict what will change.
- [ ] Production-impacting commands are clearly marked and require explicit environment/target selection.
- [ ] Operations are idempotent or safe to retry where possible.
- [ ] Partial failures are explicit and machine-readable.
- [ ] Rate limits and retry behavior are documented.
- [ ] The CLI never silently succeeds when nothing happened.

## 10. Errors, recovery, and exit codes

- [ ] Exit codes are meaningful and documented: `0` means success; nonzero means failure or a documented alternate outcome.
- [ ] The CLI avoids “error text with exit 0.”
- [ ] Error messages say what happened.
- [ ] Error messages explain how to fix it.
- [ ] Errors include stable, searchable error codes where useful, e.g. `E_AUTH_MISSING`, `E_NOT_FOUND`.
- [ ] Auth errors distinguish missing token, expired token, and insufficient permissions.
- [ ] Validation errors identify the invalid field/argument and expected format.
- [ ] Conflict/not-found/rate-limit cases are distinguishable.
- [ ] `--debug` or `DEBUG=tool:*` gives enough diagnostics to recover without leaking secrets.
- [ ] Crash/bug output includes version and a support/report path.

## 11. Versioning, compatibility, and updates

- [ ] `tool --version` prints the installed version and exits successfully.
- [ ] Version is available in machine-readable form where useful.
- [ ] The CLI can check whether a newer version exists.
- [ ] Update checks do not block automation or require a TTY.
- [ ] If a newer version exists, output includes the exact update command.
- [ ] Update notices are machine-readable with `--json` where possible.
- [ ] Stale-version warnings do not hide command output or change successful command exit semantics.
- [ ] Breaking changes follow semver or an equivalent compatibility policy.
- [ ] Deprecated commands/flags include a migration path before removal.

Example:

```bash
tool update --check --json
```

```json
{
  "installed_version": "1.4.2",
  "latest_version": "1.5.0",
  "update_available": true,
  "update_command": "npm update -g acme-cli"
}
```

## 12. Distribution, installation, and runtime

- [ ] One-line install exists.
- [ ] A zero-install/latest path exists where appropriate, e.g. `npx your-cli@latest`, `uvx your-cli`, Docker, or equivalent.
- [ ] Version pinning is possible.
- [ ] Update command is documented for every distribution path.
- [ ] Install instructions work in a clean environment.
- [ ] Package distribution is documented: npm/npx, Homebrew, pipx, Docker, GitHub Releases, etc.
- [ ] Package footprint is small enough for the expected use case, especially if invoked through `npx`/zero-install paths.
- [ ] Runtime requirements are explicit, e.g. Node/Python/Go binary/platform support.
- [ ] Cross-platform support or constraints are documented.
- [ ] The CLI handles cancellation/signals (`CTRL+C`, `SIGINT`, `SIGTERM`) cleanly.

## 13. Security, privacy, and enterprise trust

- [ ] User-supplied arguments are treated as untrusted.
- [ ] Shell-outs use safe array forms where possible, not string concatenation.
- [ ] Argument injection risks are tested, especially around file paths, URLs, branch names, and command passthrough.
- [ ] Filesystem reads/writes are scoped and documented.
- [ ] Destructive operations are explicit and auditable.
- [ ] Telemetry/analytics are strict opt-in.
- [ ] If telemetry exists, docs explain what is collected, where it goes, and how to disable it.
- [ ] Logs/debug output do not leak secrets, PII, or proprietary data.
- [ ] Enterprise environments can configure proxies, certs, and noninteractive auth where relevant.

## 14. Testing and release quality

- [ ] Tests cover `--help`, subcommand help, and `--version`.
- [ ] Tests cover success, validation failure, auth failure, not found, conflict, partial failure, and rate limit where relevant.
- [ ] Tests assert stdout/stderr separation.
- [ ] Tests assert exit codes.
- [ ] Tests cover `--json` parseability.
- [ ] Tests cover piped stdin and no-input/non-TTY behavior.
- [ ] Tests cover dry-run/plan and explicit confirmation.
- [ ] Tests cover verification commands after mutation.
- [ ] Tests avoid brittle locale-dependent assertions or lock locale explicitly.
- [ ] Clean-environment install is tested before release.
- [ ] Agent eval is run before claiming agent-readiness.

## 15. Agent onboarding package

- [ ] Quickstart for agents exists.
- [ ] Common workflows are documented as copy-paste command sequences.
- [ ] JSON input/output examples are included.
- [ ] Authentication setup for agents is documented.
- [ ] Troubleshooting guide includes common failure modes and recovery commands.
- [ ] Side-effect/destructive-command safeguards are explicit.
- [ ] A Skill/runbook exists that teaches agents how to use the CLI.
- [ ] The Skill/runbook includes the inspect → plan → act → verify loop.
- [ ] The Skill is installable in one command (e.g. `npx skills add <owner>/<repo>`), not only a file inside the repo. An agent that is not already working in the repo will never find a file it cannot install.
- [ ] The docs include an agent evaluation prompt.

---

# The agent test

Give a coding agent this prompt:

```text
Use this CLI to complete [workflow].

Requirements:
1. Discover the right command from the CLI/docs.
2. Check authentication and current state.
3. If the action mutates state, run dry-run/plan first.
4. Execute only with explicit confirmation flags.
5. Verify the result using get/status/list/logs/history commands.
6. Summarize exactly what changed with resource IDs and evidence.
7. Do not assume success from a zero exit code alone if a verification command exists.
```

Watch for:

- Can the agent discover the right command?
- Does it understand flags and required arguments?
- Can it authenticate noninteractively?
- Does it parse stdout/stderr correctly?
- Does it avoid unsafe side effects?
- Does it use dry-run/plan before mutation?
- Does it verify success independently?
- Does it recover from errors?
- Does it notice stale versions and know how to update?
- Does it produce a useful evidence-backed summary?

If the agent gets stuck, the problem may not be the model. It may be your CLI UX.

**The agent test is not optional colour — it is the evidence for two boxes.** Category 14's "Agent eval is run before claiming agent-readiness" ticks only when this test was actually run, and category 15's "The docs include an agent evaluation prompt" ticks only when a tailored prompt ships with the CLI. An audit that never runs the test leaves the first box open, which caps category 14 at `1` — correctly. "Verified" cannot be claimed for a category whose central test nobody executed.

Run it against the user's focus workflow wherever the CLI is installed and a safe path exists: read-only commands, or a mutation with `--dry-run`. When it genuinely cannot be run — the CLI is not installed, no safe environment exists, no credentials — leave the box open, lower Confidence, and say in the Verdict that the ceiling was set by audit conditions rather than by the CLI. Never silently omit it.

---

# Scoring rubric

Score each section:

- `0` = missing or actively agent-hostile.
- `1` = partially present but unreliable or undocumented.
- `2` = works, documented, and verified.

## How to score a category

The checkboxes are the input; the `0/1/2` is the output. Count them, don't weigh them:

- **All applicable items checked → `2`.**
- **No applicable items checked → `0`.**
- **Anything in between → `1`.** There is no fourth score, so nothing here is left to the auditor's discretion.

Three rules govern what "checked" means:

1. **A box ticks on evidence, not on claims.** Tick it when you ran the command or read the source. A promise in the README does not tick a box. This is what keeps the score honest — binary counting otherwise rewards documentation over behavior.
2. **Agent-hostile beats arithmetic.** A category scores `0` when its core capability actively misleads an agent, however many boxes are ticked. A `--json` mode that interleaves a spinner into stdout is worse than no `--json` at all: the agent's parse fails silently. Eight ticks and a corrupt parse is a `0`, not a `1`.
3. **N/A items leave the denominator. Unverified items do not.** N/A means the item does not apply to this product — no Docker, no plugins, no mutating operations. Say why. It never means "I could not check this." An item you were unable to verify stays **open**: it costs the box, and the audit's Confidence drops to record why. Otherwise every hard-to-check item quietly becomes N/A and the score inflates. If *every* item in a category is N/A, the category leaves the total too: the denominator drops by 2 — the same mechanism a pre-distribution target uses to report an agent-readiness score alongside the raw one.

`1` does not mean "nearly there." It means **an agent cannot rely on this category.** One box ticked and eight boxes ticked both score `1`, and that is deliberate — the gradient between them was never reproducible across auditors. The written findings carry the detail; the number carries the verdict.

| Total | Interpretation |
|---:|---|
| 0–10 | Not an agent-ready CLI. Human-only or prototype surface. |
| 11–20 | Basic CLI exists, but agents will need human help or brittle guessing. |
| 21–24 | Good classic CLI, incomplete agent-readiness. |
| 25–28 | Mostly agent-ready; fix remaining safety/verification gaps. |
| 29–30 | Strong agent-ready CLI candidate. Run agent evals before public claim. |

Note: scoring 15 categories at 0–2 gives 30 possible points. Weight sections 4, 5, 8, 9, 10, and 15 higher for agent-critical workflows if you need a stricter rubric.
