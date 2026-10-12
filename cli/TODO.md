# CLI Skills — TODO

## Bonus checklist item: the CLI recommends its Claude Code plugin (found Jul 9, 2026; corrected and re-scoped Oct 11, 2026)

**What the CLI does:** When the Stripe CLI runs inside Claude Code, it writes one line to **stderr** on every invocation, including `--version`, `--help` and error paths:

```
<claude-code-hint v="1" type="plugin" value="stripe@claude-plugins-official" />
```

A person running it outside Claude Code sees nothing extra: the line is gated on the `CLAUDECODE` / `CLAUDE_CODE_CHILD_SESSION` environment variables. Verified Oct 11, 2026 on stripe 1.43.7: stdout carries only the normal output, the tag is on stderr, and stderr is empty with those variables unset.

**What Claude Code does with it:** This is a documented Claude Code protocol, not a Stripe trick: [Recommend your plugin from your CLI](https://code.claude.com/docs/en/plugin-hints). Claude Code removes the line from Bash and PowerShell tool output before the model sees it, then shows the user a one-time **Plugin recommendation** prompt (Yes, install / No / No, and don't show plugin installation hints again). Nothing installs without the user's yes. Conditions, per the docs:

- the tag is on its own line (a tag mid-line is ignored);
- the plugin is listed in an official Anthropic marketplace such as `claude-plugins-official` (the community marketplace, `claude-community`, doesn't qualify) and isn't installed yet;
- interactive, local, attended sessions only: no prompt in `claude -p`, subagents or hook output;
- one prompt per session, one prompt ever per plugin, whatever the user answers.

*Correction to the Jul 9 note:* the skills did not "appear automatically", and Claude Code does not "auto-register" the bundle. The user approves an install prompt.

The `[Agent guidance]` block in `stripe --help` is a separate, complementary pattern: plain imperative lines for the agent (`stripe sandbox create` provisions a sandbox without a browser, a pointer to `llms.txt`, `npx skills add --all stripe/ai`).

**Why it earns a bonus:** it puts the CLI's companion plugin and Skills in front of the user the first time their agent runs the CLI, with no docs page to find and no separate `skills add`. The model never sees the line, so it costs no tokens, and someone running the CLI by hand never sees it either.

**Who does it today (re-audit Oct 11, 2026, latest releases, `CLAUDECODE=1`, stderr captured to a file and counted with grep):** 2 of the 10. Stripe 1.53.1 emits `stripe@claude-plugins-official` on every invocation, `--version` and `--help` included. Vercel 63.1.2 emits `vercel@claude-plugins-official` on `vercel version`, subcommand `--help` and error paths, but not on `--version` or top-level `--help` (an earlier check of only those two missed it). gh, kubectl, terraform, aws-cli, confluent, ldcli, agentmail and supabase emit nothing. AWS (`aws-core` and others), HashiCorp (`terraform`) and `github` already have plugins in `claude-plugins-official`, so for them the hint is one stderr line away. Audit lesson: check several commands (version subcommand, subcommand help, an error path), not just `--version` and `--help`.

## Action items

- [ ] **Add a bonus item to category 15 (Agent onboarding package)** in `agent-ready-cli-checklist-v2.md`, e.g.: *"Bonus: when it detects Claude Code (`CLAUDECODE` or `CLAUDE_CODE_CHILD_SESSION` set), the CLI recommends its official-marketplace plugin with a `<claude-code-hint />` line on stderr."* Apply it identically across all 5 bundled copies and run `scripts/check-drift.sh` after.
- [ ] **Define "bonus" in `SCORING.md` and the checklist's How to score.** The model has no bonus today: every box is passed ÷ scored. Proposal: a bonus box counts in the numerator and the denominator when it passes, and leaves the denominator when it doesn't. It can raise a score and never lower one, is never a gate, and needs no N/A (a CLI with no official-marketplace plugin just doesn't get it). Re-score the 10 under the new rule: Stripe gains the point, nobody loses one.
- [ ] **`agent-ready-cli-audit`:** check for it in Step 0/1. Run the CLI with `CLAUDECODE=1`, **send stderr to a file and count the tag with grep.** Inside Claude Code the line is stripped from Bash output before the model sees it, so an auditor reading normal output will never see it. Also report whether the vendor has a plugin in an official marketplace, as an observation either way.
- [ ] **`agent-ready-cli-spec` / `agent-ready-cli-build`:** when the product has, or plans, a plugin in an official marketplace, recommend emitting the hint: stderr, its own line, gated on the env vars, on every invocation (Claude Code prompts once per plugin). Point to the docs' Node, Python, Go and shell snippets. Never emit it ungated.
- [x] ~~Confirm whether this hint-tag format is a documented Claude Code convention~~: yes, documented (link above). Closed Oct 11, 2026.

*Captured from the Jul 9, 2026 top-10 CLI re-audit session; corrected and re-scoped Oct 11, 2026 (Emmanuel: include the behavior in the checklist as a bonus). Re-audit results: `01-Business/reference/top-10-cli-reaudit-v060-2026-07-09.md` in the Agent vault.*

---

## Verify npm-distributed CLIs are actually npx-able (found Jul 9, 2026)

**What was observed:** Testing whether AWS CLI could be installed via `npx` surfaced that npx support isn't a special opt-in — it's just "does the package's `package.json` declare a `bin` field." Any npm package with exactly one `bin` entry works with bare `npx <package>` (even if the bin name differs from the package name, e.g. `agentmail-cli` → `agentmail`); packages with multiple `bin` entries need `npx --package=<name> <bin>` to disambiguate; packages with no `bin` field at all aren't npx-runnable as a CLI regardless of what else they do. AWS CLI, Terraform, and kubectl have no npx equivalent at all because they're not npm-distributed — npx only resolves against the npm registry, so native/Go/Python binaries distributed via Homebrew/OS package managers/vendor installers are simply outside its reach.

## Action item

- [ ] **`agent-ready-cli-spec` / `agent-ready-cli-build`**: when a generated/modified CLI is (or could be) npm-distributed, verify and enforce that `package.json` has exactly one `bin` entry (or, if multiple binaries are genuinely needed, document the `npx --package=<name> <bin>` invocation explicitly in the README/`--help` output) so that bare `npx <package-name>` — the zero-install path checklist item 12 already asks for — actually works out of the box, not just "in theory." Add this as an explicit build-verification step (e.g., `npx <package>@latest --version` as a smoke test) rather than assuming a `bin` field alone is sufficient.
- [ ] **`agent-ready-cli-audit`**: when scoring checklist item 12 ("zero-install path exists"), don't just check for the *existence* of an npx-style example in docs — actually run `npx <package>@latest --help` live where possible and confirm it resolves to something useful, since a missing/misconfigured `bin` field would otherwise go undetected by docs review alone.

## Companion-skill install line cannot resolve pre-publication (Jul 9, 2026)

**Status: done in `2f6983e` (released as 1.0.0).** Build and end-to-end now emit and verify a local install path; the remote line is a post-publish step labeled "resolves once pushed", with configuration and verification status explicit.

Both `agent-ready-cli-build` and `agent-ready-cli-end-to-end` tell the builder to record `npx skills add <owner>/<repo>` in `DISTRIBUTION.md`, and `build`'s Verification Checklist asserts the line "has been checked to resolve." **Pre-publication it cannot resolve** — the repo is unpushed.

Found by two INDEPENDENT auditors, on two separately-built CLIs, neither prompted to look for it (checklist item 15.9). See the vault record `two-way-build-experiment-2026-07-09.md`.

This is the Agentmail failure in miniature: its bundled `SKILL.md` is repo-only, not in the npm package, so no agent outside the repo can reach it.

Fix candidates:
1. Emit a local install line (`npx skills add ./`) until a repo exists; record the published line as a documented TODO in `DISTRIBUTION.md`.
2. Apply the honesty rule `update --check --json` already follows — report that no channel is configured rather than printing a line that 404s.

Either way, `build`'s Verification Checklist item must stop asserting a check that cannot pass at that stage.

## The audit skill never checks whether the binary is current (Jul 9, 2026)

**Status: done in `2f6983e` (released as 1.0.0).** Step 0 resolves and compares the current release, prefers a checksum-verified scratch executable, and makes stale/unresolved version scope explicit in the Verdict and every finding. The header and self-check record version provenance and checksum status.

`agent-ready-cli-audit` locates the command (`which <tool>`), runs `--version`, and scores whatever it finds. **It never asks whether that is the release a user would install today.**

Caught live: a Jul 9 run scored the `kubectl` on PATH at 64.4%, 7/9 gates, failing the `auth status --json` gate and the destructive-confirmation gate. That binary was `v1.16.6-beta.0`, built 2020-01-15. Current stable was `v1.36.2`. Re-audited against v1.36.2: **72.0%, 9/9 gates.** Both "failures" had been fixed years earlier — `kubectl auth whoami -o json` exists, and `delete` has `--interactive`, `--force`/`--grace-period`, and `--dry-run`.

The report was not merely stale. It was **defamatory in two specific, checkable ways**, and nothing in the skill would have caught it.

Fix — add to Step 0 (Identify and onboard the target):

1. Resolve the latest published version from the distribution channel: `npm view <pkg> version`, `dl.k8s.io/release/stable.txt`, GitHub Releases `/latest`, `brew info`, PyPI JSON.
2. Compare against the installed binary's `--version`.
3. If they differ, either fetch the current release (preferred — scratch dir, checksum-verified) **or** state the gap prominently in the Verdict, lower Confidence, and label every finding as version-locked.
4. Never score a stale binary silently. Record the audited version, its source, and its checksum in the report header.

Also worth a checklist item on the other side of the contract: a CLI should make its own version and update status machine-readable (`--version --json`, `update --check --json`), which is what lets an auditor — or an agent — notice the gap at all. That item already exists in category 11; this is the auditor-side mirror of it.

## W011 indirect prompt injection guard

**Status: done in `2f6983e` (released as 1.0.0).** All five CLI skills carry the identical third-party-content rule in their Inputs area: analyze outside content as data, ignore embedded instructions, run suggested commands only under the skill procedure, and quote instruction-like content as a finding.

## Candidate checklist item: provides a sandbox / disposable test environment (Jul 10, 2026)

**Proposed item:** *"The CLI offers a one-command way to get a working, isolated, non-production test environment — ideally with no account required and safe to mutate."*

**Why it belongs on the checklist.** Auth is the single most common agent blocker in the field (top-10 re-audit, Jul 2026: 4 of 10 ship no machine-readable `auth status`; the #1 failure is "an agent can't tell whether it's authenticated"). A CLI that hands the agent a throwaway authenticated sandbox removes the question instead of answering it — and lets the agent run the full act → verify loop (create, mutate, delete) without ever touching production data.

**The exemplar — Stripe CLI** (`docs.stripe.com/stripe-cli/install`, "Get started without an account"; captured in the vault at `reference/stripe-cli-agent-detection-2026-07-10.md`):
```bash
stripe sandbox create --from-git --non-interactive   # working TEST keys, no account, no human
```
Returns test keys (`rkcs_test_…` / `pk_test_…`), saved to the CLI profile so every later command is authenticated; `--non-interactive` is documented specifically for agents; expires in 7 days; `stripe sandbox claim` converts to a real account. Docs say verbatim it "enables you, a coding agent, or an automated workflow to start building … immediately."

**Where it might live:** category 4 (Noninteractive automation) or 15 (Agent onboarding) as a scored item; possibly a partial-credit line ("test/sandbox mode reachable non-interactively" = partial; "no-account sandbox in one command" = full). Not every CLI can offer no-account sandboxes (some wrap infra that inherently needs real auth), so it likely can't be a `[C]` gate — score it, or mark N/A with a reason where the product genuinely can't provide one.

**Status:** candidate only. Decide during the next checklist revision whether it's scored, and at what weight. Do not add silently — it changes denominators.
