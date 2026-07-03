# CLI Skills

Agent-ready CLI design, specification, audit, build, and end-to-end delivery skills. They sit alongside the `api/` skills in `paraskakis/skills` and follow the same philosophy: gather inputs once, then run a rigorous, checklist-driven process unattended.

## Available Skills

- **agent-ready-cli-story** — Workflow story and product-surface fit. Use before designing commands: actors, environments, jobs-to-be-done, success evidence, v1 priorities, and non-goals.
- **agent-ready-cli-spec** — Turns workflow stories, requirements, or an OpenAPI file into an exact CLI command contract: command tree, JSON schemas, auth/config, safety model, errors, exit codes, and tests.
- **agent-ready-cli-audit** — Evidence-first review of an existing CLI against the Agent-Ready CLI Checklist. Identifies the target, runs it with `--help`, finds install instructions and docs, then produces a scorecard, blockers, quick wins, and roadmap.
- **agent-ready-cli-build** — Implements or modifies a CLI in a repo. Produces a git-initialized, ready-to-push repo: code, executable metadata, passing tests, docs, `DISTRIBUTION.md` (npm/Homebrew/pipx publish instructions), and a verification transcript. Never pushes or publishes on its own.
- **agent-ready-cli-end-to-end** — Orchestrates story → spec → build → audit/eval for a complete CLI delivery package, unattended after one input round.

## Inputs

Every skill gathers its inputs **once**, up front, then runs to completion so you can walk away:

- **Requirements** — who the users/agents are and what jobs the CLI must do. The story, spec, build, and end-to-end skills ask for these if you don't provide them.
- **OpenAPI file (preferred)** — if the CLI wraps an API, provide its OpenAPI spec. The skills derive resources, verbs, JSON schemas, auth model (`securitySchemes`), and base URL (`servers`) from it.
- **Credentials (optional)** — names of env vars already set in your shell (never pasted secrets). Enables optional live-endpoint testing so the built CLI is proven against the real API. Without them, tests run mocked and the skills note the skip.
- **Target CLI (audit only)** — a command name, repo path, package name, or docs URL.

All five skills score and enforce the shared **Agent-Ready CLI Checklist** (`references/agent-ready-cli-checklist-v2.md`).

## Outputs

- Story/spec/audit produce markdown reports saved to files.
- Build and end-to-end produce a **git-ready repo on disk**: initialized, committed at milestones, tests passing without credentials, `README.md` + `DISTRIBUTION.md` with copy-paste publish steps for npm, Homebrew, pipx/uvx, and GitHub Releases. Pushing and publishing remain yours.

## Install

These skills follow the [Agent Skills](https://agentskills.io) format and work across agents (Claude Code, Cursor, Codex, and others).

### All CLI skills

```bash
npx skills add paraskakis/skills/cli
```

### Just one CLI skill

```bash
npx skills add paraskakis/skills/cli --skill agent-ready-cli-audit
```

### Agent-specific install

```bash
npx skills add paraskakis/skills/cli -a claude-code
npx skills add paraskakis/skills/cli -a cursor
npx skills add paraskakis/skills/cli -a codex
```

Add `-g` for global/user-level install:

```bash
npx skills add paraskakis/skills/cli -a claude-code -g
```
