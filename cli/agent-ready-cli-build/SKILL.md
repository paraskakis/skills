---
name: agent-ready-cli-build
description: "Implement, scaffold, or modify an agent-ready CLI in a repository. Takes a CLI spec, an OpenAPI file (preferred when wrapping an API), or requirements, and produces a git-initialized repo on disk ready to push: source code, executable metadata, passing tests, docs, distribution instructions (npm, Homebrew, pipx, etc.), and a verification transcript. Optionally tests live API endpoints when credentials are available. Use when user says '/agent-ready-cli-build' or asks to build or implement a CLI against an existing spec or repo; for the full idea-to-delivery pipeline (story + spec + build + audit) prefer agent-ready-cli-end-to-end. Does not push, publish, or submit unless explicitly requested."
license: MIT
metadata:
  version: "0.5.0"
  author: "Emmanuel Paraskakis / Level 250"
---

# Agent-Ready CLI Build

## Overview

Use this skill to build or modify a CLI in a repo.

The primary deliverable is a **git-ready repo on disk**: source code, executable wiring, passing tests, docs, distribution instructions, local commits, and verification evidence — ready for the user to review and push. Pushing, publishing, opening PRs, or releasing are separate actions that require explicit user instruction.

## Included References

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.
- `references/frameworks-and-implementation-guidance.md` — framework selection and implementation guidance.

## Scope and Routing

Triggering is defined in the frontmatter description. In scope:

- building a new CLI end-to-end from a spec, OpenAPI file, or requirements;
- adding agent-ready behavior to an existing CLI (`--json`, stdin, dry-run, auth status, exit codes, verification commands, tests);
- producing a ready-to-test local package/binary with docs and a verification transcript.

For the full idea-to-delivery pipeline (story and spec included), route to `agent-ready-cli-end-to-end`.

## Inputs

| Input | Required | Notes |
|---|---|---|
| Contract source | Yes | A CLI spec (from `agent-ready-cli-spec`), an OpenAPI file (**preferred when the CLI wraps an API**), or plain requirements. |
| Target directory | Yes | Where the repo lives or should be created. |
| CLI name | No | Default: derive from spec/API title. |
| Language/framework | No | Default: choose per `references/frameworks-and-implementation-guidance.md` and say why. |
| Credentials for live testing | No | Env var **names** only — never ask the user to paste secrets. A credential-helper command the user points to (e.g., `export GITHUB_TOKEN=$(gh auth token)`) is also fine. Enables the optional live-endpoint step. |
| Distribution targets | No | npm, Homebrew, pipx/uvx, GitHub Releases, Docker. Default: the natural one for the chosen language, documented for the rest. |

**Any input can arrive as a path on disk, a URL, a GitHub repo, or text pasted into the conversation.** Never go looking on disk and report what you found there.

### Opening ask (only when the contract source or target directory is missing)

Ask once, like a person. Do not announce that a directory is empty, do not cite these instructions, do not explain what the skill requires — just ask:

> Do you have a CLI spec, an OpenAPI file, or written requirements for this? Send them whichever way is easiest — a path on disk, a link, a GitHub repo, or just paste them here. And where should the repo live?
>
> If you don't have anything written down, no problem — let's talk it through. What should this CLI do, and who's going to use it: you at a terminal, a coding agent, CI, or all three?

If they have no files, **have the conversation** — that *is* the input round. Cover the table above in plain sentences, a couple at a time. Never present it as a numbered questionnaire.

**A placeholder API server URL is normal — never stop over one.** `example.com`, `localhost`, `{host}`, `TODO` and the like are placeholders, not missing inputs. Wire the base URL through config (`--base-url` > `TOOL_BASE_URL` > config file > spec default), ask once in passing for the real one, and proceed either way — skipping only the live-endpoint check, logged under Assumptions.

**Then run unattended** — complete the build without pausing, and log defaults chosen under Assumptions in the final summary. If only an OpenAPI file or requirements were given (no spec), first produce a condensed command contract (per `agent-ready-cli-spec`'s derivation rules) inside `docs/cli-spec.md`, then build against it.

## Actual Deliverables

### Default: git-ready repo on disk

Unless the user explicitly asks to push/publish/submit, deliver:

- source code changed/created in the target repo;
- **git initialized** (`git init` if not already a repo) with a `.gitignore` and meaningful local commits at milestones — scaffold, commands, tests, docs — so the history is reviewable; never `git push`;
- executable entrypoint wired (`package.json` `bin`, Python console script, Go/Rust binary target, etc.);
- package/project metadata updated (name, version, description, license, repository placeholder);
- tests added and passing locally;
- docs added/updated: `README.md` (quickstart, install, top workflows, auth setup, safety model, troubleshooting);
- **an agent runbook** — `SKILL.md`, or `AGENTS.md` where that is the host convention. Not a second copy of the README's prose: compact, directly-invocable instructions that walk an agent through discover → authenticate → inspect → plan → act → verify for this CLI's real workflows, with the exact commands. The README is for a human deciding whether to use the tool; the runbook is for an agent already using it. Checklist category 15 scores this, and prose in a README does not satisfy it.
- **an update check** — `tool update --check --json`, reporting installed version, latest version, whether an update is available, and the exact update command. Implement it once a distribution channel is chosen. When nothing is published yet, still add the command and have it report that no channel is configured — then say so in `DISTRIBUTION.md` rather than omitting the command. Checklist category 11 scores the capability, not the registry.
- **`DISTRIBUTION.md`** — exact, copy-paste instructions for every relevant channel: npm (`npm publish` steps, `npx` usage, semver/tagging), Homebrew (formula or tap steps), pipx/uvx, GitHub Releases (binary + checksums), Docker if relevant. Instructions only — do not run publish commands;
- verification transcript saved to `artifacts/agent-cli-eval.md`;
- concise summary of changed files, commands run, and assumptions made.

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

Require or produce (in `docs/cli-spec.md` if absent):

- command tree;
- JSON schemas (reuse OpenAPI `components/schemas` when wrapping an API);
- auth model (derive from OpenAPI `securitySchemes`: apiKey → env var; OAuth → token env var/file + `auth login`; none → no auth commands);
- config precedence, including API base-URL config when wrapping an API;
- dry-run/confirm behavior;
- verification commands;
- error and exit-code tables (default table in `references/frameworks-and-implementation-guidance.md` — don't invent a new scheme per project);
- framework choice;
- test plan.

Completion criterion: code can be judged against a concrete spec.

### 2. Choose framework by scope

Default guidance (details in `references/frameworks-and-implementation-guidance.md`):

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
- `tool auth status --json` (if the API has auth)
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

Network-dependent tests must not require live credentials: mock/stub the API by default so `npm test`/`pytest` passes in a clean clone. Preferred pattern: start a local HTTP stub server in the test suite and point the CLI's `--base-url`/`TOOL_BASE_URL` override at it — this exercises the real HTTP layer and justifies the base-URL config. (Note: interception libraries like nock do not catch Node's native fetch/undici by default.)

Docs must include: quickstart; install (matching `DISTRIBUTION.md`); top workflows as copy-paste commands; auth setup; examples; troubleshooting; safety model.

Completion criterion: tests pass and docs include copy-paste workflows.

### 5. Optional: live endpoint check, then agent eval

**Live endpoint check (optional, never blocking):** if the API's server URL is real and required credentials exist as env vars (check with `test -n "$VAR"` — never print values), verify the CLI works against the real API: run auth status, one read-only list/get command, and confirm parseable `--json` output. If credentials or network are missing, skip, use the mocked test evidence, and record the skip in the transcript.

**Agent eval:** run the loop with real commands in a safe environment:

```text
discover → auth → inspect → plan → act → verify → summarize
```

Save the transcript with actual commands and outputs to `artifacts/agent-cli-eval.md`.

### 6. Self-check against the bundled checklist before declaring done

`references/agent-ready-cli-checklist-v2.md` is the rubric this build will be scored against. Walk it, category by category, before you report finished. For each item: satisfied (name the evidence — a command you ran, a file you wrote), deferred (say why, e.g. no distribution channel chosen yet), or genuinely not applicable (say why).

Do not skip the items this skill's deliverables list does not spell out. The deliverables are a floor, not the rubric. Anything the checklist scores and the build can satisfy, the build should satisfy — and where it does not, the final summary must say so rather than leave an auditor to discover it.

Exercise the three `--json` parser-error paths here (unknown subcommand, unknown flag, missing required option). They are the most commonly missed item, they cannot be verified by reading, and a passing test suite does not imply they work — see `references/frameworks-and-implementation-guidance.md`.

Completion criterion: every checklist category has a verdict with evidence, and unmet items appear in the summary under Assumptions rather than being discovered later by an audit.

Completion criterion: final report cites actual commands and outputs, and states whether live API testing ran or was skipped.

## Submission Boundary

Do not push, publish, open PRs, or release unless explicitly asked.

Deliverable ladder:

1. local repo ready to test;
2. local commits on a branch (default deliverable);
3. pushed branch;
4. opened PR;
5. packed artifact;
6. published package/release.

Levels 3–6 require explicit instruction. `DISTRIBUTION.md` documents how to do 5–6; the skill does not do them.

## Output Format

End with this summary in the conversation:

```markdown
# Build Summary: [tool]

Status: ready-to-test (committed locally, nothing pushed — the default) / pushed / PR opened / packed / published
Repo path: ...
Commits: [git log --oneline]
Tests: [command] → N passing (no credentials required)
Live API check: performed (evidence) / skipped (reason)
Changed files: ...
Assumptions: ...
Next actions: [exact commands to test locally; publish steps are in DISTRIBUTION.md]
```


1. **Snippet-only output.** The deliverable is a repo state, not a pasted code sample.
2. **Prompt/TUI-only implementation.** Agents need headless commands.
3. **JSON polluted by banners/spinners.** `--json` stdout must parse directly.
4. **No verification transcript.** "Tests pass" is not the same as an agent workflow proof.
5. **Publishing by surprise.** Never push/publish/release without explicit permission.
6. **Tests that need secrets.** A clean clone must pass tests with no credentials set.
7. **Uncommitted work.** Milestone commits make the deliverable reviewable and recoverable; end with a clean `git status`.
8. **Printing secrets.** Check env vars with existence tests; never echo values into logs or transcripts.

## Verification Checklist

- [ ] Repo on disk contains implementation.
- [ ] Git initialized, `.gitignore` present, milestone commits made, `git status` clean, nothing pushed.
- [ ] Executable entrypoint is wired.
- [ ] Tests pass without live credentials.
- [ ] Docs are updated; `DISTRIBUTION.md` covers every relevant channel with copy-paste steps.
- [ ] An agent runbook (`SKILL.md`/`AGENTS.md`) exists, distinct from the README, covering discover → auth → inspect → plan → act → verify with real commands.
- [ ] `tool update --check --json` exists, and reports honestly when no distribution channel is configured.
- [ ] `--help` and `--version` work.
- [ ] `--json` output parses — including for the framework's own parser errors: unknown subcommand, unknown flag, missing required option. Each emits a valid envelope and exits 2. Run all three; do not infer from a passing suite.
- [ ] `E_INTERNAL` output carries `version`, and a report path where one exists.
- [ ] Every checklist category has a verdict with evidence; unmet items are named in the summary.
- [ ] stdout/stderr are separated.
- [ ] Mutations have dry-run/confirm where applicable.
- [ ] Verification command proves results.
- [ ] Agent eval transcript is saved; live API check performed or skip recorded.
- [ ] Final status says ready-to-test, ready-to-submit, or published with evidence, plus assumptions made.
