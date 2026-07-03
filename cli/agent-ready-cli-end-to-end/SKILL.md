---
name: agent-ready-cli-end-to-end
description: "Deliver a complete agent-ready CLI end to end: gather inputs once (requirements and/or an OpenAPI file — preferred), then run story → spec → build → audit/eval unattended. Produces a git-initialized repo ready to push with tests, docs, distribution instructions (npm, Homebrew, pipx, etc.), verification transcript, and a final checklist score. Optionally tests live API endpoints when credentials are available. Use when user says '/agent-ready-cli-end-to-end' or asks to build an agent-ready CLI from idea (or API) to implementation. Does not push, publish, or submit unless explicitly requested."
license: MIT
metadata:
  version: "0.2.0"
  author: "Emmanuel Paraskakis / Level 250"
  tags: "cli, agents, end-to-end, orchestration, build, audit, openapi"
  related-skills: "agent-ready-cli-story, agent-ready-cli-spec, agent-ready-cli-build, agent-ready-cli-audit"
---

# Agent-Ready CLI End-to-End

## Overview

Use this skill when the user wants the whole pipeline, not a single artifact.

Pipeline:

```text
gather inputs → story → spec → build → audit/eval
```

The output is a complete delivery package: workflow story, CLI spec, git-ready repo-on-disk implementation, tests, docs, distribution instructions, verification transcript, and final audit score.

## Included References

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework selection and implementation guidance.

## When to Use

Use when the user asks:

- "Build us an agent-ready CLI."
- "Take this from idea to implementation."
- "Turn this OpenAPI spec into a CLI."
- "Do the full CLI workflow."
- "Create the CLI and prove it works."

Do not use when the user only wants an audit, spec, or framework recommendation — use the single skill instead.

## Inputs — gather once, then run unattended

| Input | Required | Notes |
|---|---|---|
| Requirements and/or OpenAPI file | Yes | **OpenAPI file is the preferred input** when the CLI wraps an API — it supplies resources, schemas, auth model, and base URL. Requirements supply actors and priorities. Either alone works; both together are best. |
| Target directory | Yes | Where to create the repo. |
| CLI name | No | Default: derive from product/API title. |
| Language/framework | No | Default: per `references/frameworks-and-implementation-guidance.md`, with reasons. |
| Credentials for live API testing | No | Env var **names** only — never ask the user to paste secrets. If absent, live testing is skipped and tests run mocked. |
| Distribution targets | No | npm, Homebrew, pipx/uvx, GitHub Releases, Docker. Default: the natural channel for the language; others documented. |

If required inputs are missing, ask ONE consolidated question round covering this table — nothing else. After that, **run the entire pipeline to completion without pausing for approval**, so the user can walk away. Record every default and inference in an Assumptions section of the final report. Only stop mid-run for destructive or irreversible actions (there should be none — this skill never pushes or publishes).

## Workflow

### 1. Story

Use the `agent-ready-cli-story` pattern:

- actors, environments, workflows;
- surface fit;
- success evidence;
- v1 priorities and non-goals;
- if an OpenAPI file was provided, mine operations/securitySchemes/servers for workflows, auth constraints, and environments.

Output: `docs/cli-story.md` in the target repo.

Completion criterion: v1 workflows are selected and success evidence is clear.

### 2. Spec

Use the `agent-ready-cli-spec` pattern:

- command tree; I/O rules; auth/config; JSON schemas; safety model; error/exit codes; tests;
- when wrapping an API: derive resources/verbs from paths, reuse `components/schemas`, map `securitySchemes` to env-var auth + `auth status`, map `servers` to base-URL config.

Output: `docs/cli-spec.md` in the target repo.

Completion criterion: implementation contract is concrete enough to test.

### 3. Build

Use the `agent-ready-cli-build` pattern:

- implement repo-on-disk changes; wire executable/package metadata;
- **git init** (if needed), `.gitignore`, and meaningful local commits at milestones — scaffold, commands, tests, docs; never push;
- add tests that pass without live credentials (mock the API);
- write `README.md` and **`DISTRIBUTION.md`** with copy-paste publish instructions for npm/Homebrew/pipx/GitHub Releases as relevant — instructions only, no publishing;
- run test suite and smoke tests (`--help`, `--version`, `--json` parses, stdout/stderr separation).

Output: git-ready repo state.

Completion criterion: local tests and smoke tests pass; history is reviewable.

### 4. Audit/eval

Use the `agent-ready-cli-audit` pattern after building:

- run the agent eval loop (discover → auth → inspect → plan → act → verify → summarize) with real commands;
- **optional live API check**: if credentials env vars are set and the server URL is real, run auth status plus one read-only command against the live API; otherwise record the skip;
- score the checklist; identify remaining gaps;
- save transcripts.

Output: `artifacts/agent-cli-eval.md` and `artifacts/agent-ready-cli-audit.md` in the target repo.

Completion criterion: final report states score, evidence, remaining gaps, and delivery status.

## Final Output Format

```markdown
# Agent-Ready CLI End-to-End Delivery: [Product]

## Delivery status

Status: ready-to-test / ready-to-submit / pushed / PR opened / published
Repo path: ...
Branch/commits: ...

## Assumptions

- [defaults chosen, OpenAPI inferences, skipped optional steps]

## Artifacts

- Story: docs/cli-story.md
- Spec: docs/cli-spec.md
- Implementation: ...
- Tests: ... (N passing)
- Docs: README.md, DISTRIBUTION.md
- Eval transcript: artifacts/agent-cli-eval.md
- Audit: artifacts/agent-ready-cli-audit.md

## Commands run

[real commands]

## Final audit score

N/30 with summary

## Live API check

performed (evidence) / skipped (reason)

## Remaining gaps

- ...

## Next actions

- test locally: [exact commands]
- review the repo and commits
- push / publish per DISTRIBUTION.md if desired
```

## Submission Boundary

Default final state is **git-ready repo on disk, committed locally, nothing pushed**.

Do not push, publish, open PRs, or release unless explicitly asked. `DISTRIBUTION.md` tells the user how.

## Common Pitfalls

1. **Skipping story.** Building the wrong CLI quickly is still wrong.
2. **Skipping spec.** Tests and implementation need a concrete contract.
3. **Skipping audit after build.** The final claim must be evidence-based.
4. **Publishing by surprise.** End-to-end does not mean automatic release.
5. **Leaving artifacts only in chat.** Save story/spec/eval/audit to files in the repo.
6. **Pausing mid-pipeline.** Questions belong in the input round; after that the run is unattended.
7. **Tests that need secrets.** A clean clone must pass tests with no credentials set.

## Verification Checklist

- [ ] Inputs gathered in one round; assumptions logged.
- [ ] Story artifact saved.
- [ ] Spec artifact saved.
- [ ] Repo implementation exists; git initialized with milestone commits; nothing pushed.
- [ ] Tests pass without live credentials.
- [ ] README.md and DISTRIBUTION.md are complete.
- [ ] Agent eval transcript saved; live API check performed or skip recorded.
- [ ] Post-build audit score saved.
- [ ] Final status and next actions are clear.
