---
name: agent-ready-cli-end-to-end
description: "Deliver a complete agent-ready CLI end to end: gather inputs once (requirements and/or an OpenAPI file — preferred), then run story → spec → build → audit/eval unattended. Produces a git-initialized repo ready to push with tests, docs, distribution instructions (npm, Homebrew, pipx, etc.), verification transcript, and a final checklist score. Optionally tests live API endpoints when credentials are available. Use when user says '/agent-ready-cli-end-to-end' or asks to build an agent-ready CLI from idea (or API) to implementation — prefer this over agent-ready-cli-build when starting from an idea, requirements, or a bare OpenAPI file with no existing spec or repo. Does not push, publish, or submit unless explicitly requested."
license: MIT
metadata:
  version: "0.4.0"
  author: "Emmanuel Paraskakis / Level 250"
---

# Agent-Ready CLI End-to-End

## Overview

This skill runs the whole pipeline, not a single artifact.

Pipeline:

```text
gather inputs → story → spec → build → audit/eval
```

The output is a complete delivery package: workflow story, CLI spec, git-ready repo-on-disk implementation, tests, docs, distribution instructions, verification transcript, and final audit score.

## Included References

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework selection and implementation guidance.

## Scope and Routing

Triggering is defined in the frontmatter description. In scope: the complete idea-(or OpenAPI)-to-delivery pipeline. Out of scope: when the user wants only one artifact — route to the single skill (`agent-ready-cli-audit`, `-spec`, `-story`, or `-build`) instead.

## Inputs — gather once, then run unattended

| Input | Required | Notes |
|---|---|---|
| Requirements and/or OpenAPI file | Yes | **OpenAPI file is the preferred input** when the CLI wraps an API — it supplies resources, schemas, auth model, and base URL. Requirements supply actors and priorities. Either alone works; both together are best. |
| Target directory | Yes | Where to create the repo. |
| CLI name | No | Default: derive from product/API title. |
| Language/framework | No | Default: per `references/frameworks-and-implementation-guidance.md`, with reasons. |
| Credentials for live API testing | No | Env var **names** only — never ask the user to paste secrets. If absent, live testing is skipped and tests run mocked. |
| Distribution targets | No | npm, Homebrew, pipx/uvx, GitHub Releases, Docker. Default: the natural channel for the language; others documented. |

**Any input can arrive as a path on disk, a URL, a GitHub repo, or text pasted into the conversation.** Never go looking on disk and report what you found there.

### Opening ask (only when required inputs are missing)

Ask once, like a person. Do not announce that a directory is empty, do not cite these instructions, do not explain what the skill requires — just ask:

> Do you have an OpenAPI file or written requirements for this? Send them whichever way is easiest — a path on disk, a link, a GitHub repo, or just paste them here. And where should the repo live?
>
> If you don't have anything written down, no problem — let's talk it through. What do you want this CLI to do, and who's going to use it: you at a terminal, a coding agent, CI, or all three?

If they have no files, **have the conversation** — that *is* the input round. Cover the table above in plain sentences, a couple at a time. Never present it as a numbered questionnaire.

**A placeholder API server URL is normal — never stop over one.** `example.com`, `localhost`, `{host}`, `TODO` and the like are placeholders, not missing inputs. Ask once in passing for the real base URL, proceed either way, and skip only the live API check — logged under Assumptions.

After the input round, **run the entire pipeline to completion without pausing for approval**, so the user can walk away. Record every default and inference in an Assumptions section of the final report. Only stop mid-run for destructive or irreversible actions (there should be none — this skill never pushes or publishes).

Verify credential env vars (presence only, `test -n "$VAR"`) once at the input round and again at the audit/eval phase — sessions and tokens can change during a long build. A credential-helper command the user points to (e.g., `export GITHUB_TOKEN=$(gh auth token)`) counts as available credentials.

**Execute the phases inline.** The four phase sections below summarize the sibling skills (`agent-ready-cli-story/spec/build/audit`). Do NOT re-invoke those skills as separate skill calls and do NOT re-run their own input rounds — this skill's single input round replaces them all. If the sibling SKILL.md files are installed, consult them for detail when a phase summary is not enough; otherwise the summaries here are sufficient to execute.

**N/A policy (applies to every phase):** when a checklist item genuinely doesn't apply — e.g., dry-run/confirm for a fully read-only API — state "N/A" with the reason. Never silently skip, and never invent mutations to satisfy the template.

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

Status: ready-to-test (committed locally, nothing pushed — the default) / pushed / PR opened / packed / published
Repo path: ...
Commits: [paste `git log --oneline`]

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
