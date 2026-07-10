# CLI Skills — TODO

## Auto-discovery hint tag for agent skills/plugins (found Jul 9, 2026)

**What was observed:** Installing the Stripe CLI (`stripe`) causes a batch of companion Claude Code skills (`stripe:explain-error`, `stripe:test-cards`, `stripe:connect-recommend`, `stripe:stripe-directory`, etc.) to appear automatically in the agent's available-skills list — no separate `skills add` step required. The mechanism: Stripe CLI prints a machine-readable tag on *every* invocation, including error output:

```
<claude-code-hint v="1" type="plugin" value="stripe@claude-plugins-official" />
```

Claude Code detects this tag in command output and auto-registers the referenced skill bundle. Stripe CLI also backs this up with an `[Agent guidance]` block printed directly in `stripe --help`'s main output (not buried in docs): explicit imperative instructions ("Run `npx skills add --all stripe/ai` to add all Stripe AI skills to your agent," a no-browser sandbox bootstrap via `stripe sandbox create`, a pointer to `docs.stripe.com/llms.txt`).

This is a stronger agent-onboarding pattern than anything currently in the checklist: it collapses "install the CLI" and "onboard the agent with the right skills" into a single step, with zero extra action from the human or the agent.

## Action items

- [ ] **Add a checklist item to category 15 (Agent onboarding package)** in `agent-ready-cli-checklist-v2.md`, something like: *"Installing the CLI surfaces its companion agent skill(s) automatically (e.g., a machine-readable hint tag agents can detect in output), rather than requiring a separate manual `skills add` step."* Must be applied identically across all 5 bundled copies of the checklist (`agent-ready-cli-audit`, `-build`, `-end-to-end`, `-spec`, `-story`) — run `scripts/check-drift.sh` after.
- [ ] **`agent-ready-cli-audit`**: check for this pattern explicitly during Step 0/1 (run the CLI, grep output for known hint-tag formats) and score it under category 15.
- [ ] **`agent-ready-cli-spec` / `agent-ready-cli-build`**: recommend building this in for any new CLI — emit a stable, versioned hint tag (`<claude-code-hint v="1" type="plugin" value="<owner>@<bundle>" />` or an agreed equivalent) on `--help` and on error paths, pointing to the CLI's own companion skill bundle.
- [ ] Confirm whether this hint-tag format is a documented Claude Code convention (vs. Stripe-specific) before standardizing on it — check if other CLIs use a different/competing convention (Vercel's `<claude-code-hint>`-adjacent onboarding via `vercel mcp`/`vercel skills`/`agent init` is a different mechanism worth comparing against).

*Captured from the Jul 9, 2026 top-10 CLI re-audit session (live-installing Stripe/Terraform/Confluent/AWS CLIs for real, per Emmanuel's request). Full context: `01-Business/reference/top-10-cli-audit-rerun-2026-07-09.md` in the Agent vault.*

---

## Verify npm-distributed CLIs are actually npx-able (found Jul 9, 2026)

**What was observed:** Testing whether AWS CLI could be installed via `npx` surfaced that npx support isn't a special opt-in — it's just "does the package's `package.json` declare a `bin` field." Any npm package with exactly one `bin` entry works with bare `npx <package>` (even if the bin name differs from the package name, e.g. `agentmail-cli` → `agentmail`); packages with multiple `bin` entries need `npx --package=<name> <bin>` to disambiguate; packages with no `bin` field at all aren't npx-runnable as a CLI regardless of what else they do. AWS CLI, Terraform, and kubectl have no npx equivalent at all because they're not npm-distributed — npx only resolves against the npm registry, so native/Go/Python binaries distributed via Homebrew/OS package managers/vendor installers are simply outside its reach.

## Action item

- [ ] **`agent-ready-cli-spec` / `agent-ready-cli-build`**: when a generated/modified CLI is (or could be) npm-distributed, verify and enforce that `package.json` has exactly one `bin` entry (or, if multiple binaries are genuinely needed, document the `npx --package=<name> <bin>` invocation explicitly in the README/`--help` output) so that bare `npx <package-name>` — the zero-install path checklist item 12 already asks for — actually works out of the box, not just "in theory." Add this as an explicit build-verification step (e.g., `npx <package>@latest --version` as a smoke test) rather than assuming a `bin` field alone is sufficient.
- [ ] **`agent-ready-cli-audit`**: when scoring checklist item 12 ("zero-install path exists"), don't just check for the *existence* of an npx-style example in docs — actually run `npx <package>@latest --help` live where possible and confirm it resolves to something useful, since a missing/misconfigured `bin` field would otherwise go undetected by docs review alone.

## Companion-skill install line cannot resolve pre-publication (Jul 9, 2026)

Both `agent-ready-cli-build` and `agent-ready-cli-end-to-end` tell the builder to record `npx skills add <owner>/<repo>` in `DISTRIBUTION.md`, and `build`'s Verification Checklist asserts the line "has been checked to resolve." **Pre-publication it cannot resolve** — the repo is unpushed.

Found by two INDEPENDENT auditors, on two separately-built CLIs, neither prompted to look for it (checklist item 15.9). See the vault record `two-way-build-experiment-2026-07-09.md`.

This is the Agentmail failure in miniature: its bundled `SKILL.md` is repo-only, not in the npm package, so no agent outside the repo can reach it.

Fix candidates:
1. Emit a local install line (`npx skills add ./`) until a repo exists; record the published line as a documented TODO in `DISTRIBUTION.md`.
2. Apply the honesty rule `update --check --json` already follows — report that no channel is configured rather than printing a line that 404s.

Either way, `build`'s Verification Checklist item must stop asserting a check that cannot pass at that stage.
