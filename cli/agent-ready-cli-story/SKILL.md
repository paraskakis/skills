---
name: agent-ready-cli-story
description: "Use when defining what an agent-ready CLI should expose before writing commands: actors, environments, jobs-to-be-done, product-surface fit, workflow stories, success evidence, and non-goals. This is the upstream story/workflow skill for CLI strategy, analogous to an API story skill; it does not produce implementation code."
license: MIT
metadata:
  version: "0.1.0"
  author: "Level 250 / Hermes Agent draft"
  hermes:
    tags: [cli, agents, product-strategy, workflows, mcp, skills]
    related_skills: [agent-ready-cli-spec, agent-ready-cli-end-to-end]
---

# Agent-Ready CLI Story

## Overview

Use this skill to decide **what CLI workflows should exist and why**.

The story layer comes before command syntax. It answers:

> Which actor needs which workflow, in which environment, with what evidence of success — and is CLI actually the right surface?

Do not design a command tree until the actor, workflow, side effects, and success evidence are clear.

## Included References

Linked reference files:

- `references/agent-ready-cli-checklist-v2.md` — canonical checklist and scoring rubric.

Use the checklist for terminology and evaluation criteria, but keep this skill focused on workflow story and product-surface fit.

## When to Use

Use when the user asks:

- “What CLI should we build?”
- “Which workflows should the CLI expose?”
- “Should this be API, CLI, MCP, Skill, UI, or TUI?”
- “What would make this product agent-consumable?”
- “Help me prepare a CLI workshop/product strategy story.”

Do not use for existing-CLI evidence audits; use `agent-ready-cli-audit`.
Do not use for command contracts; use `agent-ready-cli-spec`.
Do not use for implementation; use `agent-ready-cli-build`.

## Workflow

### 1. Identify actors and environments

Capture:

- primary actor: human, local coding agent, hosted coding agent, CI agent, chatbot/assistant agent, integration partner;
- environment: local repo, terminal, cloud workspace, CI, assistant app, production account;
- available capabilities: shell, filesystem, network, env vars, MCP/tools, browser only;
- constraints: auth, network, secrets, approvals, compliance, rate limits.

Completion criterion: every target actor has an environment and capability profile.

### 2. Define workflow stories

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

```markdown
# Agent-Ready CLI Story: [Product]

## Summary

Primary recommendation: ...
Primary actor: ...
Primary surface: CLI / API / MCP / Skill / UI / TUI
Supporting surfaces: ...
Do not build: ...

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

The next skill should be `agent-ready-cli-spec` using these workflow stories.
```

## Common Pitfalls

1. **Starting with commands before jobs.** Command syntax is downstream of workflow story.
2. **Making CLI a religion.** Chatbot users may need MCP; visual workflows may need UI.
3. **Ignoring success evidence.** If the agent cannot verify success, the story is incomplete.
4. **Overloading v1.** Start with high-value, low-risk, verifiable workflows.
5. **Treating Skill as a surface by itself.** Skill teaches; API/CLI/MCP executes.

## Verification Checklist

- [ ] Primary actor/environment is explicit.
- [ ] Workflows have triggers, inputs, side effects, and success evidence.
- [ ] Surface recommendation includes alternatives and boundaries.
- [ ] v1 workflows are prioritized.
- [ ] Non-goals are stated.
- [ ] Handoff to CLI spec is clear.
