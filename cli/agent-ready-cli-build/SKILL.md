---
name: agent-ready-cli-build
description: "Use when implementing, scaffolding, or modifying an agent-ready CLI in a repository. Takes a CLI spec or explicit workflow requirements and produces a repo-on-disk deliverable: source code, executable metadata, tests, docs, and verification transcript. Does not push, publish, or submit unless explicitly requested."
license: MIT
metadata:
  version: "0.1.0"
  author: "Level 250 / Hermes Agent draft"
  hermes:
    tags: [cli, agents, implementation, build, testing, npm, python, go, rust]
    related_skills: [agent-ready-cli-spec, agent-ready-cli-audit, agent-ready-cli-end-to-end]
---

# Agent-Ready CLI Build

## Overview

Use this skill to build or modify a CLI in a repo.

The primary deliverable is the **repo on disk**: source code, executable wiring, tests, docs, and verification evidence. Pushing, publishing, opening PRs, or releasing are separate actions that require explicit user instruction.

## Included References

Linked reference files:

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework selection and implementation guidance.

## When to Use

Use when the user asks to:

- build a new CLI end-to-end from an existing spec;
- add agent-ready behavior to an existing CLI;
- implement `--json`, stdin, dry-run, auth status, exit codes, verification commands, or tests;
- produce a ready-to-test local package/binary;
- create docs/guidelines and verification transcript.

If there is no workflow/spec, use `agent-ready-cli-story` and `agent-ready-cli-spec` first, or ask for/declare assumptions.

## Actual Deliverables

### Default: ready-to-test repo on disk

Unless the user explicitly asks to push/publish/submit, deliver:

- source code changed/created in the target repo;
- executable entrypoint wired (`package.json` `bin`, Python console script, Go/Rust binary target, etc.);
- package/project metadata updated;
- tests added and passing locally;
- docs added/updated (`README.md`, `CLI_GUIDELINES.md`, `docs/cli.md`, etc.);
- verification transcript saved, e.g. `artifacts/agent-cli-eval.md`;
- concise summary of changed files and commands run.

### Node/npm deliverables

Depending on scope:

- local npm package ready to test via `npm link`, `npm test`, `npx . --help`, or equivalent;
- packed `.tgz` from `npm pack`, smoke-tested from tarball if requested;
- publish-ready package only if requested;
- published npm package only after explicit instruction and credential confirmation.

### Python deliverables

- local package with `pyproject.toml` console script and tests passing;
- wheel/sdist built and smoke-tested in a clean venv if requested;
- upload only after explicit instruction.

### Go/Rust deliverables

- source implementation with tests passing;
- built binary under `dist/` or equivalent if requested;
- checksums/release artifacts only if requested.

## Build Workflow

### 1. Confirm or create the implementation contract

Require or produce:

- command tree;
- JSON schemas;
- auth model;
- config precedence;
- dry-run/confirm behavior;
- verification commands;
- error and exit-code tables;
- framework choice;
- test plan.

Completion criterion: code can be judged against a concrete spec.

### 2. Choose framework by scope

Default guidance:

- **oclif** for serious multi-command Node/TypeScript product CLIs with plugins/generated docs.
- **commander/yargs/clipanion/cac** for smaller Node CLIs.
- **Go/Rust** when single-binary distribution and low runtime friction matter.
- **Python Typer/Click** for Python/data-native workflows.
- TUI/prompt frameworks only on top of headless commands.

Completion criterion: framework choice states why at least one plausible alternative was not chosen.

### 3. Implement headless commands first

Prioritize:

- `tool --help`
- `tool --version`
- `tool auth status --json`
- inspect commands (`list/get/status/logs/history --json`)
- plan/dry-run commands
- confirmed mutating commands
- verification commands

Completion criterion: core commands work without a TTY.

### 4. Add tests and docs

Tests must cover:

- help/version;
- JSON parseability;
- stdout/stderr separation;
- stdin/piped input where relevant;
- no-TTY behavior;
- error and exit codes;
- dry-run/confirm;
- verify-after-action workflow.

Docs must include:

- quickstart;
- top workflows;
- auth setup;
- examples;
- troubleshooting;
- safety model.

Completion criterion: tests pass and docs include copy-paste workflows.

### 5. Run agent eval

Run or simulate with real commands in a safe environment:

```text
discover → auth → inspect → plan → act → verify → summarize
```

Save transcript to `artifacts/agent-cli-eval.md` or equivalent.

Completion criterion: final report cites actual commands and outputs.

## Submission Boundary

Do not push, publish, open PRs, or release unless explicitly asked.

Deliverable ladder:

1. local repo ready to test;
2. local commit/branch;
3. pushed branch;
4. opened PR;
5. packed artifact;
6. published package/release.

Levels 3–6 require explicit instruction.

## Common Pitfalls

1. **Snippet-only output.** The deliverable is a repo state, not a pasted code sample.
2. **Prompt/TUI-only implementation.** Agents need headless commands.
3. **JSON polluted by banners/spinners.** `--json` stdout must parse directly.
4. **No verification transcript.** “Tests pass” is not the same as an agent workflow proof.
5. **Publishing by surprise.** Never push/publish/release without explicit permission.

## Verification Checklist

- [ ] Repo on disk contains implementation.
- [ ] Executable entrypoint is wired.
- [ ] Tests pass.
- [ ] Docs are updated.
- [ ] `--help` and `--version` work.
- [ ] `--json` output parses.
- [ ] stdout/stderr are separated.
- [ ] Mutations have dry-run/confirm where applicable.
- [ ] Verification command proves results.
- [ ] Agent eval transcript is saved.
- [ ] Final status says ready-to-test, ready-to-submit, or published with evidence.
