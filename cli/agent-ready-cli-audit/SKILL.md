---
name: agent-ready-cli-audit
description: "Audit an existing CLI against the Agent-Ready CLI Checklist. Evidence-first: identifies the target command, runs it with --help and safe read-only commands, finds install instructions and the docs page, scores the checklist, and produces prioritized fixes. Use when user says '/agent-ready-cli-audit' or asks to audit a CLI, check whether a CLI is agent-ready, or review a CLI/repo/docs for agent readiness — including questions like 'is our CLI good for agents?' or 'why do coding agents get stuck with our tool?'. Does not design new commands."
license: MIT
metadata:
  version: "0.4.0"
  author: "Emmanuel Paraskakis / Level 250"
---

# Agent-Ready CLI Audit

## Overview

Use this skill to evaluate an existing CLI against the Agent-Ready CLI Checklist.

Audit mode is **evidence-first**. Inspect docs/code and run the CLI where possible. Do not replace missing evidence with imagined best practices.

The audit asks:

> Would a coding agent get stuck trying to discover, authenticate, inspect, plan, act, verify, and recover?

## Included References

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric. Use it as the source of truth for scoring.

## Scope and Routing

Triggering is defined in the frontmatter description. In scope: evidence-based review of an existing CLI, repo, or docs. Out of scope: greenfield command design (use `agent-ready-cli-spec`) and implementation (use `agent-ready-cli-build`).

## Inputs

| Input | Required | Notes |
|---|---|---|
| Target CLI | Yes | Installed command name, repo path, npm/PyPI/Homebrew package name, or docs URL — any one is enough. |
| Focus workflows | No | Specific workflows the user cares about most. |
| Safe environment | No | Whether mutating commands may be exercised. Default: no — read-only commands only. |
| Credentials | No | Env var names for auth'd commands. Never ask the user to paste secrets into the conversation; ask for names of env vars already set in the shell. |

**The target can arrive as a command name, a path on disk, a package name, a docs URL, or a GitHub repo.** Never go looking on disk and report what you found there.

**Gather inputs once, then run unattended.** If the target CLI is named in the request, skip questions entirely — proceed straight to Step 0 with the table's defaults for everything else.

Only if the target is missing, ask once, like a person. Do not announce that a directory is empty, do not cite these instructions:

> Which CLI should I look at? A command name, a repo path, a package name, or a docs URL — whatever you've got.
>
> Also: is it safe to run commands that change things, or should I stick to read-only? (Read-only is my default.)

After that, complete the entire audit without further questions. When anything is ambiguous mid-run, choose the safe option (read-only), log the assumption in the report, and continue.

**Expected fallbacks (all fine — log them, lower confidence where noted):**
- Source/tests not reasonably available (closed or large repo): score category 14 from inferred evidence and mark it low-confidence rather than cloning everything.
- No web access: skip the docs-page fetch, note degraded confidence on docs-related items.
- Clean-environment install can't be truly verified read-only: reason from package metadata and docs, mark as unverified.
- Working directory not writable: save the report wherever writes are permitted and state the path.
- Environment already authenticated as a real user: read-only commands are still fine; cite only the minimum account evidence needed (no token values, no scopes dumps beyond the finding).

## Audit Workflow

### 0. Identify and onboard the target

Before scoring anything, onboard the way a fresh agent would:

1. **Locate the command**: `which <tool>`. If not installed, find install instructions (README, `npm view <pkg>`, `brew info <tool>`, PyPI page). Do not install without the user's permission; audit from docs/source with lowered confidence instead.
2. **Run discovery commands**: `<tool> --help`, `<tool> -h`, `<tool> --version`, and `--help` on the key subcommands.
3. **Find the install path**: identify the documented one-line install (brew, npm/npx, pipx/uvx, curl script, releases page) and whether it would work in a clean environment.
4. **Find the docs page**: from help-text links, README links, or package metadata. If web access is available, load the docs page and note whether it shows the top workflows as copy-paste commands.

Completion criterion: the audit records where the CLI comes from, how it installs, and where its docs live — or explicitly states these could not be found (that is itself a finding).

### 1. Gather evidence

Inspect, as available:

- README/docs/help pages;
- package metadata and executable entrypoint;
- source code for command parsing, I/O, auth, exit codes;
- tests;
- installed CLI behavior.

Run safe read-only commands where possible:

```bash
tool --help
tool --version
tool auth status --json
tool <resource> --help
tool <resource> list --json
```

Avoid destructive commands unless the user explicitly provides a safe test environment.

**Stopping rule:** don't `--help` every leaf of a large CLI. Sample until each checklist category has at least one piece of direct evidence, favoring the user's focus workflows; then stop.

Completion criterion: audit distinguishes observed evidence from untested assumptions.

### 2. Score the checklist

Score each category per `references/agent-ready-cli-checklist-v2.md`:

- `0` = missing or agent-hostile;
- `1` = partial/unreliable/undocumented;
- `2` = works, documented, and verified.

Categories:

1. Product-surface fit
2. Discoverability
3. Predictable command grammar
4. Noninteractive automation
5. Machine-readable I/O
6. Composability and stdin
7. Authentication and environment
8. Inspectability and verification
9. Safe side effects
10. Errors, recovery, and exit codes
11. Versioning and updates
12. Distribution and runtime
13. Security/privacy/enterprise trust
14. Testing and release quality
15. Agent onboarding package

Completion criterion: each score has evidence and a fix.

### 3. Identify agent blockers

Prioritize blockers that prevent the execution loop:

- no noninteractive auth;
- no inspect/status commands;
- no JSON output;
- stdout/stderr mixed;
- no dry-run/confirm for mutations;
- no verification command;
- bad exit codes;
- hangs without TTY;
- undocumented install/update path;
- secret leakage or unsafe shell-outs.

Completion criterion: top 5 fixes are ordered by agent-blocking impact.

### 4. Recommend next path

Depending on score:

- strong CLI: recommend agent eval and docs/Skill polish;
- partial CLI: recommend spec patch and implementation roadmap;
- human-only CLI: recommend headless layer beneath prompts/TUI;
- wrong surface: recommend API/MCP/Skill/UI instead of CLI.

Completion criterion: recommendation is actionable and does not overclaim certainty.

## Output Format

Save the full report to a file (default `agent-ready-cli-audit-<tool>.md` in the working directory, or wherever the user asked) and give the verdict summary in the conversation.

```markdown
# Agent-Ready CLI Audit: [CLI]

## Verdict

Status: Agent-ready / Mostly ready / Partially ready / Human-only CLI / Wrong surface
Score: N/30
Confidence: high/medium/low based on evidence available

## Target

Command: ... | Version: ... | Install path: ... | Docs page: ...

## Assumptions

- [anything assumed because the run was unattended]

## Evidence inspected

- ...

## Scorecard

| Category | Score | Evidence | Recommended fix |
|---|---:|---|---|

## Agent blockers

1. ...

## Quick wins

- ...

## Roadmap

### High priority
### Medium priority
### Low priority

## Agent eval prompt

[prompt tailored to this CLI]
```

## Common Pitfalls

1. **Auditing from docs only when the CLI can be run.** Run safe commands where possible.
2. **Penalizing non-applicable items.** Mark N/A honestly if Docker/plugin/etc. is irrelevant.
3. **Overvaluing pretty terminal UX.** Rich output is fine only if headless/JSON mode works.
4. **Ignoring tests.** Agent-readiness should be testable, not just documented.
5. **Inventing command contracts during audit.** Audit first; spec redesign second.
6. **Interrogating the user.** One consolidated question round at most; then run to completion.

## Verification Checklist

- [ ] Target command, version, install path, and docs page are identified (or their absence is reported as a finding).
- [ ] Evidence sources are listed.
- [ ] Safe commands were run where possible.
- [ ] Scores are tied to evidence.
- [ ] Agent blockers are prioritized.
- [ ] Fixes are concrete.
- [ ] Report is saved to a file; assumptions are logged.
- [ ] Recommendation distinguishes audit facts from design hypotheses.
