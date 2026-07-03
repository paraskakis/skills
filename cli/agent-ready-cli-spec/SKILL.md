---
name: agent-ready-cli-spec
description: "Use when turning CLI workflow stories into an exact agent-ready command contract: command tree, grammar, flags, config precedence, auth, JSON schemas, stdin/stdout/stderr, dry-run/confirm behavior, verification commands, errors, exit codes, tests, and docs. This is the design/spec skill, not the implementation skill."
license: MIT
metadata:
  version: "0.1.0"
  author: "Level 250 / Hermes Agent draft"
  hermes:
    tags: [cli, agents, specification, command-contract, json, testing]
    related_skills: [agent-ready-cli-story, agent-ready-cli-build, agent-ready-cli-end-to-end]
---

# Agent-Ready CLI Spec

## Overview

Use this skill to convert workflow stories into a precise **command contract** that a builder can implement and an auditor can test.

The spec must make the agent execution loop concrete:

```text
discover → authenticate → inspect → plan/dry-run → act → verify → recover/summarize
```

## Included References

Linked reference files:

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework and implementation guidance.

## When to Use

Use when the user asks:

- “Design the CLI command contract.”
- “Write a CLI spec.”
- “Turn these workflows into commands.”
- “Give Claude Code/Codex/Replit the spec to build this.”
- “Define JSON schemas / exit codes / auth behavior.”

If the workflow story is missing, use `agent-ready-cli-story` first or explicitly state assumptions.
If implementation is requested after the spec, hand off to `agent-ready-cli-build`.

## Workflow

### 1. Confirm workflow inputs

For every workflow, confirm:

- actor/environment;
- trigger and goal;
- required inputs;
- side-effect level;
- success evidence;
- safety/approval requirements.

Completion criterion: no workflow enters command design without success evidence.

### 2. Design the command tree

Use a predictable grammar:

```bash
tool <resource> <verb> [args] [flags]
```

Include:

- root help and version;
- auth commands;
- inspect commands;
- plan/dry-run commands;
- mutating commands with explicit confirmation;
- verification commands.

Completion criterion: every workflow maps to discover/auth/inspect/plan/act/verify commands.

### 3. Specify I/O and config

Define:

- stdout/stderr rules;
- `--json` behavior and schemas;
- stdin / `--stdin` / `-f -` behavior;
- TTY vs no-TTY behavior;
- config precedence: flags > env vars > project config > user config > system config;
- color/progress/spinner behavior;
- debug/verbose behavior.

Completion criterion: an automated test can validate output without human interpretation.

### 4. Specify safety and verification

For each mutating command, specify:

- dry-run/plan behavior;
- confirmation flag;
- production target selection;
- idempotency/retry semantics;
- returned resource IDs;
- verification command.

Completion criterion: the spec prevents “acted but cannot prove it.”

### 5. Specify errors, exit codes, and tests

Include:

- stable error codes;
- exit-code table;
- validation/auth/not-found/conflict/rate-limit behavior;
- test plan covering stdout/stderr, JSON, stdin, no-TTY, dry-run, confirm, verify-after-action.

Completion criterion: failure behavior is as testable as success behavior.

## Output Format

```markdown
# Agent-Ready CLI Spec: [Product]

## Scope

Workflows covered: ...
Non-goals: ...
Primary actor/environment: ...

## Command tree

[commands]

## Workflow contracts

### Workflow: [name]

- Discover: `...`
- Auth: `...`
- Inspect: `...`
- Plan: `...`
- Act: `...`
- Verify: `...`

## JSON schemas

[schemas]

## Config and auth

[precedence, env vars, config files, auth status]

## Safety model

[dry-run, confirm, production, idempotency]

## Error and exit-code tables

[tables]

## Test plan

[tests]

## Build handoff

Recommended next skill: `agent-ready-cli-build`.
```

## Common Pitfalls

1. **Specifying verbs without verification.** Every mutating workflow needs a verification command.
2. **Vague JSON.** Sketch exact fields and stable schemas.
3. **Human-only auth.** Browser login is not enough for agents.
4. **No TTY plan.** Agents and CI often run without interactive terminals.
5. **Framework-first thinking.** Choose oclif/commander/etc. after the contract.

## Verification Checklist

- [ ] Every workflow has command coverage for the agent execution loop.
- [ ] JSON/stdout/stderr/stdin behavior is specified.
- [ ] Auth and config precedence are specified.
- [ ] Safety and verification behavior are specified.
- [ ] Error and exit-code tables are included.
- [ ] Test plan is concrete enough for implementation.
