---
name: agent-ready-cli-story
description: "Define what an agent-ready CLI should expose before writing commands: actors, environments, jobs-to-be-done, product-surface fit, workflow stories, success evidence, and non-goals. Accepts requirements and/or an OpenAPI spec as input and asks for requirements if missing. Use when user says '/agent-ready-cli-story' or asks what CLI to build, which workflows a CLI should expose, or whether CLI/API/MCP/Skill/UI is the right surface. Does not produce implementation code."
license: MIT
metadata:
  version: "0.4.0"
  author: "Emmanuel Paraskakis / Level 250"
---

# Agent-Ready CLI Story

## Overview

Use this skill to decide **what CLI workflows should exist and why**.

The story layer comes before command syntax. It answers:

> Which actor needs which workflow, in which environment, with what evidence of success — and is CLI actually the right surface?

Do not design a command tree until the actor, workflow, side effects, and success evidence are clear.

## Included References

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric. Use it for terminology and evaluation criteria; keep this skill focused on workflow story and product-surface fit.

## Scope and Routing

Triggering is defined in the frontmatter description. In scope: deciding which workflows a CLI should expose and whether CLI is the right surface. Out of scope: existing-CLI evidence audits (`agent-ready-cli-audit`), command contracts (`agent-ready-cli-spec`), implementation (`agent-ready-cli-build`).

## Inputs

| Input | Required | Notes |
|---|---|---|
| Requirements | One of these two | Who the users/agents are, what jobs they need done, pain points, constraints. A file or a paragraph both work. |
| OpenAPI spec | One of these two — **preferred when the CLI wraps an API** | Operations reveal candidate workflows; `securitySchemes` reveal auth constraints; `servers` reveal environments. |
| Existing docs/product context | No | Product docs, existing CLI/API docs, competitor notes. |

**Any input can arrive as a path on disk, a URL, a GitHub repo, or text pasted into the conversation.** Never go looking on disk and report what you found there.

### Opening ask (only when you have neither requirements nor an OpenAPI file)

Ask once, like a person. Do not announce that a directory is empty, do not cite these instructions, do not explain what the skill requires — just ask:

> Do you have an OpenAPI file or some written requirements for this? Send them whichever way is easiest — a path on disk, a link, a GitHub repo, or just paste them here.
>
> If you don't have anything written down, no problem — let's talk it through. What do you want this CLI to do, and who's going to use it: you at a terminal, a coding agent, CI, or all three?

If they have no files, **have the conversation** — that *is* the input round. Cover these, in plain sentences, a couple at a time, and only as far as they can answer: the primary actor (human dev, local coding agent, CI agent, chat assistant); the top three jobs the tool should do; whether an API sits underneath, and whether they have its OpenAPI file; constraints around auth, environments, compliance, and destructive operations. Never present it as a numbered questionnaire.

**Then run unattended.** Once inputs are in hand, go quiet and produce the complete story document without further questions. If only an OpenAPI file was given, derive requirements from it (operations → jobs, securitySchemes → auth constraints) and log every inference under Assumptions. Note: an OpenAPI file describes the API, not the calling agent's environment — in OpenAPI-only mode, default the actor/environment profile to "local coding agent + CI, shell/network/env-var capable" and log that as an assumption.

## Workflow

### 1. Identify actors and environments

Capture:

- primary actor: human, local coding agent, hosted coding agent, CI agent, chatbot/assistant agent, integration partner;
- environment: local repo, terminal, cloud workspace, CI, assistant app, production account;
- available capabilities: shell, filesystem, network, env vars, MCP/tools, browser only;
- constraints: auth, network, secrets, approvals, compliance, rate limits.

Completion criterion: every target actor has an environment and capability profile.

### 2. Define workflow stories

If an OpenAPI spec was provided, mine it first: group operations into workflows (not one story per endpoint), and use `securitySchemes`/`servers` to fill auth and environment fields. Grouping example: `GET /flights` + `GET /flights/{id}` + `GET /airports/{id}` → one "track a flight" workflow, because the actor's job spans all three. If the API is fully read-only, every story's side effects are legitimately "none" — state it, don't invent mutations.

Use this format:

```markdown
## Workflow Story: [name]

Actor: ...
Environment: ...
Trigger: ...
Goal: ...
Inputs: ...
Side effects: none / reversible / destructive / production-impacting
Success evidence: ...
Failure/recovery evidence: ...
Human approval needed: yes/no/when
```

Completion criterion: every workflow includes success evidence an agent can verify.

### 3. Decide product surface fit

Use this map:

| Surface | Best for | Weak when |
|---|---|---|
| API | Stable programmable foundation, integrations | Too low-level without workflow packaging |
| CLI | Terminal-capable agents, CI, local/dev workflows | Chat-only assistant users, visual workflows |
| MCP | Assistant/chat surfaces and permissioned delegated actions | Local shell/file workflows or large tool explosions |
| Skill | Teaching agents how to use API/CLI/MCP well | Cannot execute by itself |
| UI/TUI | Human understanding, setup, exploration | Brittle if it is the only automation path |

Completion criterion: recommendation names primary and supporting surfaces, plus non-goals.

### 4. Prioritize workflows

Prioritize by:

1. agent value — repetitive, inspectable, high-friction human work;
2. safety — low-risk before destructive/production actions;
3. feasibility — stable API/capability exists underneath;
4. evidence — success can be verified from CLI/API state;
5. distribution — reachable by the target agent environment.

Completion criterion: workflows are ranked as v1 / later / do not build.

## Output Format

Save the story document to a file (default `cli-story-<product>.md`, or wherever the user asked) and summarize the recommendation in the conversation.

```markdown
# Agent-Ready CLI Story: [Product]

## Summary

Primary recommendation: ...
Primary actor: ...
Primary surface: CLI / API / MCP / Skill / UI / TUI
Supporting surfaces: ...
Do not build: ...

## Assumptions

- [inferences made from the OpenAPI spec or unattended-mode defaults]

## Actor/environment map

| Actor | Environment | Capabilities | Constraints | Surface implication |
|---|---|---|---|---|

## Workflow stories

[stories]

## Prioritized v1 workflows

1. ...

## Non-goals

- ...

## Handoff to spec

The next skill should be `agent-ready-cli-spec` using these workflow stories (plus the OpenAPI file if one exists).
```

## Common Pitfalls

1. **Starting with commands before jobs.** Command syntax is downstream of workflow story.
2. **Making CLI a religion.** Chatbot users may need MCP; visual workflows may need UI.
3. **Ignoring success evidence.** If the agent cannot verify success, the story is incomplete.
4. **Overloading v1.** Start with high-value, low-risk, verifiable workflows.
5. **Treating Skill as a surface by itself.** Skill teaches; API/CLI/MCP executes.
6. **One story per endpoint.** An OpenAPI file lists operations; stories describe workflows, which typically span 2–5 operations.

## Verification Checklist

- [ ] Primary actor/environment is explicit.
- [ ] Workflows have triggers, inputs, side effects, and success evidence.
- [ ] Surface recommendation includes alternatives and boundaries.
- [ ] v1 workflows are prioritized.
- [ ] Non-goals are stated.
- [ ] Assumptions are logged (especially anything inferred from an OpenAPI file).
- [ ] Story document is saved to a file.
- [ ] Handoff to CLI spec is clear.
