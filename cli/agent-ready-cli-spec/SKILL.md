---
name: agent-ready-cli-spec
description: "Turn CLI workflow stories, requirements, or an OpenAPI spec into an exact agent-ready command contract: command tree, grammar, flags, config precedence, auth, JSON schemas, stdin/stdout/stderr, dry-run/confirm behavior, verification commands, errors, exit codes, tests, and docs. Asks for requirements if none are given; OpenAPI file is the preferred input when the CLI wraps an API. Use when user says '/agent-ready-cli-spec' or asks to design a CLI command contract or write a CLI spec. Design only — not implementation."
license: MIT
metadata:
  version: "0.3.0"
  author: "Emmanuel Paraskakis / Level 250"
  tags: "cli, agents, specification, command-contract, json, openapi, testing"
  related-skills: "agent-ready-cli-story, agent-ready-cli-build, agent-ready-cli-end-to-end"
---

# Agent-Ready CLI Spec

## Overview

Use this skill to convert workflow stories into a precise **command contract** that a builder can implement and an auditor can test.

The spec must make the agent execution loop concrete:

```text
discover → authenticate → inspect → plan/dry-run → act → verify → recover/summarize
```

## Included References

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework and implementation guidance.

## When to Use

Use when the user asks:

- "Design the CLI command contract."
- "Write a CLI spec."
- "Turn these workflows into commands."
- "Give a coding agent the spec to build this."
- "Define JSON schemas / exit codes / auth behavior."

If implementation is requested after the spec, hand off to `agent-ready-cli-build`.

## Inputs

| Input | Required | Notes |
|---|---|---|
| Workflow stories | One of these three | Output of `agent-ready-cli-story`. Best input for a well-grounded spec. |
| OpenAPI spec | One of these three — **preferred when the CLI wraps an API** | Paths → resource nouns; operations → verbs; `components/schemas` → JSON output schemas; `securitySchemes` → auth model; `servers` → environment/base-URL config. |
| Requirements | One of these three | Plain-language description of actors and workflows; the skill will state story-level assumptions. |
| CLI name | No | Proposed binary name. Default: derive from the product/API title. |

If none of the three are provided, ask ONE consolidated question round:

> 1. What should this CLI do, and for whom (human dev, local coding agent, CI agent)?
> 2. Do you have an OpenAPI file for the underlying API (preferred)? Or workflow stories/requirements I should work from?
> 3. For the top workflows: do any change data (create/update/delete), and how would success be verified?
> 4. Any constraints (auth, environments, compliance)? Any preferred CLI name?

**Then run unattended.** After inputs are in hand, produce the complete spec without pausing. Log every inference (especially anything derived from the OpenAPI file) under Assumptions in the output — including fields the question round could not gather (side-effect levels, success evidence) that you inferred per workflow.

**CLI name heuristic** (when none is given): derive a short, typeable binary name from the product/API title — drop generic words (API, Public, Service, REST), keep one memorable stem (e.g., "Flight Tracking Public API" → `flighttrack`).

### Deriving the contract from an OpenAPI file

When an OpenAPI file is the input:

- map `paths` to resources and operations to verbs (`GET /todos` → `tool todos list`, `POST /todos` → `tool todos create`); a filter-heavy collection GET whose summary implies searching becomes `search`, not `list`;
- reuse `components/schemas` as the `--json` output schemas — do not invent parallel shapes;
- map `securitySchemes` to the auth model: apiKey → `TOOL_API_KEY` env var + `auth status --json`, plus documented key acquisition (this satisfies the checklist's auth-login item — `auth login` is for interactive/OAuth flows only); OAuth → token file/env var + `auth login` for humans; no schemes → no auth commands, say so;
- map `servers` to base-URL config (`--base-url` flag > `TOOL_BASE_URL` env var > config file > spec default);
- derive error behavior even when the OpenAPI file omits it: real APIs return 401/403/429 whether or not the spec documents them — include standard auth/rate-limit error codes and mark them as inferred. Use the default exit-code and error-code table in `references/frameworks-and-implementation-guidance.md` unless the user has a convention;
- group endpoints into workflows before designing commands — the CLI is not a 1:1 endpoint mirror; skip or merge endpoints that don't serve a workflow, and record that decision.

**Read-only APIs:** if the spec has no mutating operations, say so explicitly. Dry-run/confirm/verify-after-mutation sections become "N/A — read-only" (stated, not silently skipped); verification means re-fetching state.

### Optional: validate the contract against the live API

If the OpenAPI `servers` URL is real and credentials are available as env vars (ask for env var **names** only — never ask the user to paste secrets), send one or two safe read-only GET requests to confirm the spec's assumptions (auth header name, response shape). If no credentials or no network, skip and note it. This step must never block the spec.

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
- auth commands (if the API has auth);
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

Completion criterion: the spec prevents "acted but cannot prove it."

### 5. Specify errors, exit codes, and tests

Include:

- stable error codes;
- exit-code table;
- validation/auth/not-found/conflict/rate-limit behavior;
- test plan covering stdout/stderr, JSON, stdin, no-TTY, dry-run, confirm, verify-after-action.

Completion criterion: failure behavior is as testable as success behavior.

## Output Format

Save the spec to a file (default `cli-spec-<tool>.md`, or wherever the user asked) and summarize in the conversation.

```markdown
# Agent-Ready CLI Spec: [Product]

## Scope

Workflows covered: ...
Non-goals: ...
Primary actor/environment: ...
Source inputs: stories / OpenAPI file / requirements

## Assumptions

- [inferences from OpenAPI or unattended-mode defaults; endpoints skipped/merged and why]

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

[schemas — reuse OpenAPI components where they exist]

## Config and auth

[precedence, env vars, config files, auth status; API base URL config if wrapping an API]

## Safety model

[dry-run, confirm, production, idempotency]

## Error and exit-code tables

[tables]

## Test plan

[tests]

## Live API check

[performed/skipped; what was confirmed]

## Build handoff

Recommended next skill: `agent-ready-cli-build`.
```

## Common Pitfalls

1. **Specifying verbs without verification.** Every mutating workflow needs a verification command.
2. **Vague JSON.** Sketch exact fields and stable schemas — reuse OpenAPI components when available.
3. **Human-only auth.** Browser login is not enough for agents.
4. **No TTY plan.** Agents and CI often run without interactive terminals.
5. **Framework-first thinking.** Choose oclif/commander/etc. after the contract.
6. **Mirroring the API 1:1.** Commands serve workflows, not endpoints.
7. **Blocking on live checks.** The live API validation is optional evidence, never a gate.

## Verification Checklist

- [ ] Every workflow has command coverage for the agent execution loop.
- [ ] JSON/stdout/stderr/stdin behavior is specified.
- [ ] Auth and config precedence are specified (derived from securitySchemes when an OpenAPI file exists).
- [ ] Safety and verification behavior are specified.
- [ ] Error and exit-code tables are included.
- [ ] Test plan is concrete enough for implementation.
- [ ] Assumptions are logged; spec saved to a file.
