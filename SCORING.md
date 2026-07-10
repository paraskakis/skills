# Scoring methodology — Agent-Ready CLI Checklist

How `agent-ready-cli-audit` turns 130 checkboxes into a number, why that number is shaped the way it is, and what it deliberately does not claim.

## The model

**Score = passed ÷ scored, expressed as a percentage.** Every box is worth one point. There are no per-category scores to aggregate and no weights to argue about.

```
130 boxes
 −4 not scored          → 126 scorable
 −N/A (varies per CLI)  → the denominator
```

Three rules decide what is in scope and what passed:

1. **A box passes on evidence, not on claims.** Tick it when you ran the command or read the source. A promise in the README passes nothing.
2. **Not-scored items never count.** Four items assert something about the team's process or the product's future. No auditor can observe them by running commands, so they are excluded permanently, for every CLI, and reported as observations.
3. **N/A leaves the denominator; unverified does not.** N/A means the item cannot apply to this product. It never means "I could not check it." An item you could not verify **fails** and lowers Confidence.

Because N/A varies per CLI, denominators vary. **Compare percentages, never raw counts.**

## The two numbers are different claims

The percentage measures **checklist completion**. The Verdict measures **agent-readiness**. Conflating them is the single easiest way to misread an audit.

A polished human CLI — good help text, `--no-color`, POSIX conventions, a small package, cross-platform notes — can tick most of 130 boxes while an agent cannot complete a single loop. The handful of things that actually break an agent are a small share of the count. Unweighted counting would call that CLI 85% agent-ready. It is not agent-ready at all.

So nine boxes are marked **[C]**. They score one point like any other, but **failing any one caps the Verdict at "Partially ready," whatever the percentage says.**

| [C] gate | Why the loop breaks without it |
|---|---|
| Core workflows run without a TTY | The agent has no terminal to type into |
| `--json` is valid and parseable | The agent's parser throws instead of reading a result |
| Primary output goes to stdout | Data and diagnostics become indistinguishable |
| Errors/logs go to stderr | Same, in reverse |
| `auth status --json` exists | The agent cannot tell whether it is authenticated before acting |
| Every action can be verified afterwards | The agent cannot prove what changed |
| Destructive commands require confirmation | The agent destroys things while exploring |
| Exit codes are meaningful and documented | **The agent has no eyes. This is how it learns anything happened.** |
| No "error text with exit 0" | The agent proceeds confidently past a failure |

Note what is *not* on that list: `--plain`, `--no-color`, spinner degradation, package footprint, help-text ordering. All real quality. None load-bearing for an agent.

Separately, a category whose core capability is **actively agent-hostile** scores zero across its boxes and caps the Verdict the same way. A `--json` mode that interleaves a spinner into stdout is worse than no `--json` at all: it corrupts the parse rather than omitting data. Arithmetic cannot express "worse than absent." A gate can.

## What the percentage does not mean

Borrowed, deliberately, from CIS: **a 95% CIS compliance score means 95% of scored items pass. It does not mean the system is 5% insecure.**

The same disclaimer applies here. 80% does not mean an agent will succeed 80% of the time, and the missing 20% is not necessarily minor — *"should this even be a CLI?"* is six boxes out of 130. Read the findings for what is wrong. Read the number for how much is done.

## Why this model, and not the others

There is no standard for this. There are three families, and we chose one on purpose.

**Weighted average of continuous sub-scores — [Lighthouse](https://developer.chrome.com/docs/lighthouse/performance/performance-scoring).** Each metric gets a 0–100 from a log-normal distribution of real-world data, then a weighted average (TBT 30%, LCP 25%, CLS 25%, FCP 10%, Speed Index 10%). The weights were chosen from research into user-perceived performance and revised over time.
*Rejected:* we have no distribution of real-world CLI behaviour to calibrate against, and no research basis for weights. Inventing them would be false precision.

**Weighted by risk — [OpenSSF Scorecard](https://github.com/ossf/scorecard).** Each check returns 0–10; the aggregate is a weighted average where weight comes from risk level (Critical 10, High 7.5, Medium 5, Low 2.5). They explicitly refused to let the *number* of checks determine influence.
*Partly adopted:* their insight — that importance must outrank count — is correct and is why the **[C]** gates exist. We took the idea as a pass/fail overlay rather than as 130 weights, because weighting would still let a long tail of hygiene points outvote a broken parse contract, only more slowly.

**Count the passing items — [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/cis-benchmarks-faq).** Compliance percentage = passed scored items ÷ scored items. CIS splits recommendations into *Scored* and *Not Scored*: not-scored items are context-dependent or need manual assessment, and [do not affect the total](https://www.cisecurity.org/insights/blog/changes-to-cis-benchmark-assessment-recommendation-scoring).
*Adopted.* It is simple, reproducible, auditable, and every number in it traces to a command someone ran. The Scored/Not-Scored split is what lets *"agent eval is run before release"* — a claim about somebody's process — stop poisoning every audit's ceiling.

Linters sit outside all three. ESLint and Spectral emit severities and a pass/fail gate, not a score. SonarQube's quality gate is conditions, not a number. That is a coherent choice too, and it is essentially what the **[C]** gates are.

## Known weaknesses

Stated plainly, because an audit method that hides its own failure modes is not worth much.

**Item counts weight the score.** Testing has 11 boxes; Product-surface fit has 6. Nothing decided that Testing should matter 83% more — that is an artefact of how many bullets were written. `/130` measures completion, and 11 items is 11 items of work, which is defensible. It is not a claim about importance. The **[C]** gates carry importance instead.

**N/A is the only lever, so it is the one to watch.** Marking an item inapplicable shrinks the denominator and raises the percentage. This is why N/A must be justified per item, why *"I could not check it"* is never N/A, and why an audit that N/As liberally should be distrusted. A perverse consequence survives: a CLI that has no stdin support at all makes three stdin boxes inapplicable, while a CLI that supports stdin imperfectly carries three boxes it can fail. Supporting a capability gives you boxes to lose.

**Precision exceeds the evidence.** 126 scorable boxes means 126 chances for two auditors to disagree about an N/A call. 61.2% and 58.9% will read as meaningfully different when they are not. Treat the bands, not the decimals.

**Pre-distribution CLIs need a second number.** Categories 11 (updates) and 12 (distribution) hold 19 boxes, 17 of them scorable. A CLI that has not shipped fails most of them for reasons that are true today and false next week. Report the raw percentage *and* an agent-readiness percentage over the remaining 109, naming the deferral. Never mark 11 and 12 N/A: *"not shipped yet"* is a fact about today; N/A is a fact about the product forever.

## Interpretation bands

| Score | Interpretation |
|---:|---|
| 0–33% | Not an agent-ready CLI. Human-only or prototype surface. |
| 34–66% | Basic CLI exists, but agents will need human help or brittle guessing. |
| 67–80% | Good classic CLI, incomplete agent-readiness. |
| 81–93% | Mostly agent-ready; fix remaining safety/verification gaps. |
| 94–100% | Strong agent-ready CLI candidate. Run agent evals before public claim. |

**A failed [C] gate caps the Verdict at "Partially ready," regardless of the band.** So does an agent-hostile category. The band says how much is done. The gates say whether an agent can finish the loop.

## History

The checklist previously scored each of 15 categories `0/1/2` for a total out of 30. That model was replaced because it could not be reproduced: nothing said how to collapse a category's 6–11 items into one number, so the same repository scored 26/30 from one auditor and 23/30 from another. An interim fix — all items checked → `2`, none → `0`, anything between → `1` — was reproducible but collapsed the scale: fourteen of fifteen categories landed on `1`, and two CLIs, one of which had a broken `--json` contract and one of which had fixed it, became indistinguishable.

Counting boxes fixes both problems. The gates keep the number honest about what it is measuring.
