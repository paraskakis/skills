---
name: agent-ready-cli-end-to-end
description: "Use when the user wants the full agent-ready CLI workflow handled end to end: story/workflow discovery, CLI spec, repo-on-disk build, tests, docs, verification transcript, and post-build audit/eval. Orchestrates the story, spec, build, and audit skills; does not push, publish, or submit unless explicitly requested."
license: MIT
metadata:
  version: "0.1.0"
  author: "Level 250 / Hermes Agent draft"
  hermes:
    tags: [cli, agents, end-to-end, orchestration, build, audit]
    related_skills: [agent-ready-cli-story, agent-ready-cli-spec, agent-ready-cli-build, agent-ready-cli-audit]
---

# Agent-Ready CLI End-to-End

## Overview

Use this skill when the user wants the whole pipeline, not a single artifact.

Pipeline:

```text
story → spec → build → audit/eval
```

The output is a complete delivery package: workflow story, CLI spec, repo-on-disk implementation, tests, docs, verification transcript, and final audit score.

## Included References

Linked reference files:

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework selection and implementation guidance.

## When to Use

Use when the user asks:

- “Build us an agent-ready CLI.”
- “Take this from idea to implementation.”
- “Do the full CLI workflow.”
- “Create the CLI and prove it works.”
- “Run story/spec/build/audit end to end.”

Do not use when the user only wants an audit, spec, or framework recommendation.

## Workflow

### 1. Story

Use the `agent-ready-cli-story` pattern:

- actors;
- environments;
- workflows;
- surface fit;
- success evidence;
- v1 priorities;
- non-goals.

Output: `docs/cli-story.md` or project artifact equivalent.

Completion criterion: v1 workflows are selected and success evidence is clear.

### 2. Spec

Use the `agent-ready-cli-spec` pattern:

- command tree;
- I/O rules;
- auth/config;
- JSON schemas;
- safety model;
- error/exit codes;
- tests.

Output: `docs/cli-spec.md` or project artifact equivalent.

Completion criterion: implementation contract is concrete enough to test.

### 3. Build

Use the `agent-ready-cli-build` pattern:

- implement repo-on-disk changes;
- wire executable/package metadata;
- add tests;
- update docs;
- run test suite and smoke tests.

Output: ready-to-test repo state.

Completion criterion: local tests and smoke tests pass.

### 4. Audit/eval

Use the `agent-ready-cli-audit` pattern after building:

- run agent eval;
- score the checklist;
- identify remaining gaps;
- save verification transcript.

Output: `artifacts/agent-cli-eval.md` and `artifacts/agent-ready-cli-audit.md` or equivalents.

Completion criterion: final report states score, evidence, remaining gaps, and delivery status.

## Final Output Format

```markdown
# Agent-Ready CLI End-to-End Delivery: [Product]

## Delivery status

Status: ready-to-test / ready-to-submit / pushed / PR opened / published
Repo path: ...
Branch/commit: ... if applicable

## Artifacts

- Story: ...
- Spec: ...
- Implementation: ...
- Tests: ...
- Docs: ...
- Eval transcript: ...
- Audit: ...

## Commands run

[real commands]

## Final audit score

N/30 with summary

## Remaining gaps

- ...

## Next actions

- test locally
- review
- commit/push/open PR/publish if desired
```

## Submission Boundary

Default final state is **repo on disk, ready to test**.

Do not push, publish, open PRs, or release unless explicitly asked.

## Common Pitfalls

1. **Skipping story.** Building the wrong CLI quickly is still wrong.
2. **Skipping spec.** Tests and implementation need a concrete contract.
3. **Skipping audit after build.** The final claim must be evidence-based.
4. **Publishing by surprise.** End-to-end does not mean automatic release.
5. **Leaving artifacts only in chat.** Save story/spec/eval/audit to files.

## Verification Checklist

- [ ] Story artifact saved.
- [ ] Spec artifact saved.
- [ ] Repo implementation exists.
- [ ] Tests pass.
- [ ] Docs updated.
- [ ] Agent eval transcript saved.
- [ ] Post-build audit score saved.
- [ ] Final status and next actions are clear.
