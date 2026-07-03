# CLI Skills

Agent-ready CLI design, specification, audit, build, and end-to-end delivery skills.

These are intended to sit alongside the existing `api/` skills in `paraskakis/skills`.

## Available Skills

- **agent-ready-cli-story** — Workflow story and product-surface fit. Use before designing commands: actors, environments, jobs-to-be-done, success evidence, v1 priorities, and non-goals.
- **agent-ready-cli-spec** — Turns workflow stories into an exact CLI command contract: command tree, JSON schemas, auth/config, safety model, errors, exit codes, and tests.
- **agent-ready-cli-audit** — Evidence-first review of an existing CLI against the Agent-Ready CLI Checklist. Produces scorecard, blockers, quick wins, and roadmap.
- **agent-ready-cli-build** — Implements or modifies a CLI in a repo. Produces repo-on-disk deliverable: code, executable metadata, tests, docs, and verification transcript. Does not push/publish/submit unless explicitly requested.
- **agent-ready-cli-end-to-end** — Orchestrates story → spec → build → audit/eval for a complete CLI delivery package.

## Install

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

## Suggested API-folder README addition

In the root README, add a section similar to the existing API section:

```markdown
## Agent-Ready CLI

- **agent-ready-cli-story** — Workflow story and product-surface fit.
- **agent-ready-cli-spec** — Exact CLI command contract from stories.
- **agent-ready-cli-audit** — Evidence-based audit of an existing CLI against the checklist.
- **agent-ready-cli-build** — Repo-on-disk implementation from a spec.
- **agent-ready-cli-end-to-end** — Full story → spec → build → audit/eval pipeline.

Install all CLI skills:

\```bash
npx skills add paraskakis/skills/cli
\```
```
