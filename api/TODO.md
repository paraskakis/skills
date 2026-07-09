# API Design Skills — Future Improvements

## Examples
- [ ] Consider more extensive standards file
- [ ] **Sample spec for `design-api-review`?** The skill bundles the two rulesets but no spec, so it cannot be run standalone — every invocation needs the user to bring one. A bundled conference-API spec (the output of running `design-api-spec` on the bundled conference stories + domain) would make it demoable and give the other three skills a shared worked example end to end. Open question, not yet decided: a bundled spec is a fifth thing to keep in sync with the standards, and a *clean* spec makes a dull review — a deliberately flawed one teaches more but has to be maintained as the rulesets evolve. Emmanuel wants to think about it. *(Raised Jul 9, 2026.)*

## Skill Consistency
- [ ] **`design-api-review`: make the Step 3 verdict names match the Step 4 report headings.** Step 3 defines three verdicts — `DIVERGES`, `DELIBERATE`, `UNJUSTIFIED-DELIBERATE` — but the Step 4 template heads the buckets "Diverges", "Deliberate", "Needs a decision". The third pair doesn't match, so the model has to translate `UNJUSTIFIED-DELIBERATE` → "Needs a decision" on every run. It does this correctly (observed Jul 9, 2026 on a Sonnet review of a Todo API spec: the `PUT /tasks/{taskId}` status split was documented as intentional but gave no reason, and was filed under "Needs a decision"), but the translation is avoidable. Rename the Step 3 verdict to `NEEDS-A-DECISION`, or rename the Step 4 heading — either way, one name per concept. *(Raised Jul 9, 2026. Not urgent — the skill behaves correctly today.)*

## OpenAPI Version Policy — design proposes, review accepts
- [ ] **3.1.0 is the right default, but the skills state it in the wrong voice, and the review skill inherits a rule that doesn't apply to it.** We standardise on 3.1.0 because it's currently the best for tool compatibility. Two different behaviours are needed:
  - **Design skills (`design-api`, `design-api-spec`)** should *propose* 3.1.0 and say so — "I'm generating 3.1.0 because it's the best-supported version; want a different one?" Today they silently default (`design-api/SKILL.md:143`, `design-api-spec/SKILL.md:57`: "Default to OpenAPI 3.1.0 unless the user specifies a different version"). The override exists; the user is never told it exists.
  - **Review skill (`design-api-review`)** must accept whatever it's handed. It currently claims "any 3.x version" (Inputs #1) — but it sweeps the spec against `OpenAPI-best-practices.md`, whose **rule 1 reads "Design an API using the OpenAPI specification version 3.1.0."** So reviewing a perfectly valid 3.0.3 spec would flag rule 1 as a divergence, and the rule tells a *reviewer* to *design*. That's a real false positive waiting to happen — the ruleset is written in authoring voice (see the standards-files item below).
- [ ] **What version range do we accept for review? TBD.** Options: accept any `3.x`; constrain to a supported set (Emmanuel's suggestion: ~3.0–3.2) and refuse or warn outside it; or accept anything and note the version in the report header. Ties directly to the validation item below — deciding to constrain implies deciding to *check*, which implies a validator.

## Validation & Linting in the Review Skill
- [ ] **Deterministic validation before the model reads anything.** Right now `design-api-review` runs the model against the ruleset and nothing else. Two cheap, deterministic layers are missing:
  - **Parse validation** — is the input even well-formed JSON/YAML? Today a malformed spec reaches the model, which will try to review it anyway.
  - **OpenAPI structural validation** — does it validate against the OpenAPI meta-schema for its declared version? A structurally invalid spec should fail fast with a parse error, not produce a standards-compliance verdict.
  Neither is a judgement call, so neither belongs to the model. Open question: do these run always, or only when the spec came from a URL/repo rather than a trusted local path?
- [ ] **Do we wire a linter into the review, or stay model-vs-ruleset?** Candidates: RMOA (already used by `design-api-spec` Step 5), Spectral, Vacuum, Jentic, 42Crunch. Arguments both ways, unresolved:
  - *For:* linters are deterministic, fast, and catch the mechanical class of findings (missing descriptions, orphaned components, inline schemas) that currently consume model attention. The model could then spend its budget on the findings only it can make — semantic lies like a documented `?expand=project` with no property to receive it (observed Jul 9, 2026, Todo API review).
  - *Against:* a linter enforces *its* rules, not the user's standards file. Key Principle 1 says the rulesets in play are the law. A linter that disagrees with the standards file introduces a second law, and we'd have to say which wins — the `design-api-spec` skill already has this problem and resolves it "the standards file wins, tell the user."
  - Decide the *layering* first: parse → structural validate → linter (mechanical) → model (semantic + standards). Then decide which linter, if any.

## Standards Files — voice and in-repo sync
*(Scope note: the cross-repo "canonical source of samples, standards, prompts" question is a bigger, separate piece of work and does not live here. Tracked in the vault backlog.)*

- [ ] **The rulesets are written in authoring voice.** `OpenAPI-best-practices.md` opens with `## Your Role:` / "You are an experienced API Architect." (line 4) and `## Outcome:` / "Design an API using the OpenAPI specification version 3.1.0" (line 7). That's a *prompt*, not a *ruleset* — right when the file was fed to a model to build a spec, wrong now that four skills with four different jobs consume it. A review skill is not designing; a stories skill is not writing OpenAPI. Proposal: lift the role/outcome preamble out of the ruleset and into whichever skill needs it, leaving the file as voice-neutral rules any consumer can apply. This is also what makes the version bug above possible. (`API-standards.md` is already close — no role preamble, no version pin.)
- [ ] **`check-drift.sh` covers none of the bundled rulesets.** The skills repo carries 4 × `API-standards.md` and 3 × `OpenAPI-best-practices.md` (one per skill that needs them). Identical as of Jul 9, 2026, but the guard only compares SKILL.md blocks — these seven files have no protection at all, which is exactly the hole that let the story rules drift. Each skill genuinely needs its own copy (skills install as standalone directories), so the copies stay; extend the guard to assert they match. Cheap, and independent of wherever the canonical file eventually lives.

## Additional Linters / Scanners
- [ ] Jentic scanner
- [ ] 42Crunch scanner
- [ ] OpenAPIDoctor — talk to Dave about making it an API
- [ ] Vacuum (Dave Shanley) — fast linting
- [ ] Spectral linting

## Additional Previews
- [ ] Redoc as an alternative to Swagger UI
- [ ] Self-contained Swagger UI preview. The current preview step (`design-api`, `design-api-spec`) writes an HTML file that `fetch()`es the spec, so it needs `npx http-server` and a cleanup step. Embedding the spec directly in the HTML would remove the server, the port juggling, and the teardown. In Cowork this renders as an artifact with an "Open in Safari" button — an instant visual payoff at the end of the flow. (Discovered Mar 16, 2026 during Cowork testing.)

## Relationships
- [ ] Talk to Martyn about improvements to RMOA
