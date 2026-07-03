---
name: agent-ready-cli-audit
description: "Use when evaluating an existing CLI, repo, docs, or installed command against the Agent-Ready CLI Checklist. This is evidence-first audit mode: inspect docs/code and run commands where possible, score the checklist, identify agent-blocking gaps, and produce prioritized fixes. Do not invent a greenfield design unless asked."
license: MIT
metadata:
  version: "0.1.0"
  author: "Level 250 / Hermes Agent draft"
  hermes:
    tags: [cli, agents, audit, scorecard, evidence, checklist]
    related_skills: [agent-ready-cli-spec, agent-ready-cli-build]
---

# Agent-Ready CLI Audit

## Overview

Use this skill to evaluate an existing CLI against the Agent-Ready CLI Checklist.

Audit mode is **evidence-first**. Inspect docs/code and run the CLI where possible. Do not replace missing evidence with imagined best practices.

The audit asks:

> Would a coding agent get stuck trying to discover, authenticate, inspect, plan, act, verify, and recover?

## Included References

Linked reference files:

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.

Use the linked checklist as the source of truth for scoring.

## When to Use

Use when the user asks:

- “Audit this CLI.”
- “Is this CLI agent-ready?”
- “Compare this CLI to the checklist.”
- “Review this repo/docs for CLI agent readiness.”
- “Tell me what to fix first.”

Do not use for greenfield command design; use `agent-ready-cli-spec`.
Do not use for implementation; use `agent-ready-cli-build`.

## Audit Workflow

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

Completion criterion: audit distinguishes observed evidence from untested assumptions.

### 2. Score the checklist

Score each category:

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

```markdown
# Agent-Ready CLI Audit: [CLI]

## Verdict

Status: Agent-ready / Mostly ready / Partially ready / Human-only CLI / Wrong surface
Score: N/30
Confidence: high/medium/low based on evidence available

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

## Verification Checklist

- [ ] Evidence sources are listed.
- [ ] Safe commands were run where possible.
- [ ] Scores are tied to evidence.
- [ ] Agent blockers are prioritized.
- [ ] Fixes are concrete.
- [ ] Recommendation distinguishes audit facts from design hypotheses.
