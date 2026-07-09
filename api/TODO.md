# API Design Skills — Future Improvements

## Examples
- [ ] Consider more extensive standards file
- [ ] **Sample spec for `design-api-review`?** The skill bundles the two rulesets but no spec, so it cannot be run standalone — every invocation needs the user to bring one. A bundled conference-API spec (the output of running `design-api-spec` on the bundled conference stories + domain) would make it demoable and give the other three skills a shared worked example end to end. Open question, not yet decided: a bundled spec is a fifth thing to keep in sync with the standards, and a *clean* spec makes a dull review — a deliberately flawed one teaches more but has to be maintained as the rulesets evolve. Emmanuel wants to think about it. *(Raised Jul 9, 2026.)*

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
