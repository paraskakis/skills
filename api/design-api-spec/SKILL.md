---
name: design-api-spec
description: Generate an OpenAPI 3.1.0 specification from API design stories, a domain model, API standards, and OpenAPI best practices. Lints with vacuum and iterates to 100/100. Use when user says "/design-api-spec" or asks to generate an OpenAPI spec from stories. Does not write the stories (that is `design-api-stories`) and does not review an existing spec (that is `design-api-review`).
license: MIT
metadata:
  version: "1.1.0"
  author: "Emmanuel Paraskakis / Level 250"
---

# Design API Spec

Generate an OpenAPI 3.1.0 specification from API design stories, a domain model, API standards, and an OpenAPI best practices file. Then lint it with vacuum and fix issues. This is part of Emmanuel Paraskakis's method for designing APIs with LLMs. Stories can come from the companion `design-api-stories` skill or be written by hand — either way, this skill takes stories + domain + standards + OpenAPI best practices and produces a validated spec.

## Scope and Routing

Triggering is defined in the frontmatter description. In scope: turning stories + domain + standards + best practices into a linted OpenAPI document. Out of scope: writing the stories (use `design-api-stories`), reviewing a spec you did not just generate (use `design-api-review`), and running the full pipeline (use `design-api`).

## Optional Dependencies

The core skill (spec generation) works with no extra tools. For the full experience:

- **vacuum** — enables automated linting and scoring. Runs locally, no account or key. Install: `brew install --cask daveshanley/vacuum/vacuum` (other options at https://quobix.com/vacuum/installing/). If it is missing, the skill offers to install it at the start of a run.
- **Node.js** — enables local Swagger UI preview via `npx http-server`.
- **python3** — used to read vacuum's JSON report.

Without these, the skill still generates a complete OpenAPI spec — it just skips linting and local preview.

## Inputs

The user must provide (or point to) these files. Files can be named anything — identify each file by its `# Title` heading or content, not by filename.

1. **Stories** — Output from `/design-api-stories`. Defines methods, resources, parameters, and themes. Look for a heading like `# Stories`, `# User Stories`, or similar.
2. **Domain** — Data objects, properties, enums, object relations. Source of truth for schemas. Look for a heading like `# Domain`, `# Domain Model`, or similar.
3. **API Standards** — Style guide, naming, paths, security, error handling. Source of truth for conventions. Look for a heading like `# API Standards`, `# Style Guide`, or similar.
4. **OpenAPI Best Practices** — Formatting rules, DRY principles, SDK compatibility, component structure. Source of truth for OpenAPI document quality. Look for a heading like `# OpenAPI Best Practices`, `# OAS Best Practices`, or similar.

If any file is missing, ask the user to provide it before proceeding.

### Working Example

See `references/examples/` for a complete set of inputs (conference scheduling API):
- `conference-api-stories.md` — stories (output from `/design-api-stories`)
- `conference-domain.md` — domain model
- `API-standards.md` — API standards
- `OpenAPI-best-practices.md` — OpenAPI best practices

## Before You Start: Linter Check

The lint step (Step 5) needs [vacuum](https://quobix.com/vacuum/) on the user's machine. Settle this now, before any other work, so the run is not interrupted later.

Run:

```bash
command -v vacuum || echo "vacuum-not-found"; test -f ~/.config/design-api/skip-vacuum && echo "never-ask"; true
```

- **The output is a path to vacuum** — say nothing and go to Step 1.
- **The output has `vacuum-not-found` and `never-ask`** — the user already chose not to be asked. Do not ask. Go to Step 1; the lint step will be skipped.
- **The output has `vacuum-not-found` only** — ask the user once. Use this question and exactly these three options:

  "vacuum, the linter I use to score the spec, isn't installed on this machine. What would you like to do?"

  1. **Install vacuum now** — a free, open-source OpenAPI linter that runs on your machine. No account, nothing uploaded. It lets me score your spec out of 100 and use the score to guide fixes.
  2. **Not now** — skip scoring for this run. I'll ask again next time.
  3. **Never ask again** — skip scoring from now on.

If you cannot ask the user (a non-interactive run), treat it as **Not now**.

**Install vacuum now.** If Homebrew is available (`command -v brew`), run `brew install --cask daveshanley/vacuum/vacuum`. If it is not, show the user the options at https://quobix.com/vacuum/installing/ and run only a command they confirm. Then check `command -v vacuum` again. If vacuum is still not found, tell the user the install did not work, and continue without linting.

**Not now.** Change nothing. Continue; the lint step will be skipped.

**Never ask again.** Run `mkdir -p ~/.config/design-api && touch ~/.config/design-api/skip-vacuum`. Tell the user: "Done. I won't ask again in any of the API design skills. To be asked again, delete `~/.config/design-api/skip-vacuum`." This choice also applies to the other API design skills, which share the same marker file. Continue; the lint step will be skipped.

Whatever the answer, the rest of the skill runs the same way and still produces a complete spec.

## Step 1: Read All Inputs

Read all four files completely. Build a mental model of:
- Every endpoint from the stories (method + resource + parameters)
- Every data object and enum from the domain
- Every convention from the standards
- Every formatting rule from the best practices

## Step 2: Generate the OpenAPI Document

Output a single valid JSON file. Default to OpenAPI 3.1.0 unless the user specifies a different version.

### Structure

Follow this order in the document:

1. `openapi` — "3.1.0" (or the user-specified version)
2. `info` — Title, description, version, contact, license (per best practices)
3. `servers` — At least one server with description
4. `security` — Global security scheme if standards require auth
5. `tags` — One tag per theme from the stories
6. `paths` — All endpoints from the stories
7. `components` — schemas, parameters, responses, headers, securitySchemes

### Schema Generation Rules

- **Every domain object becomes a component schema.** Use the exact property names from the domain file.
- **Every enum becomes a component schema.** Don't inline enums.
- **Collection responses get their own schema.** e.g., `InstrumentCollection` with `data` array + pagination fields.
- **Error responses use RFC 9457 (Problem Details)** unless standards specify otherwise.
- **No inline schemas.** Extract everything to `components/schemas` and `$ref` it.
- **Reusable parameters go in `components/parameters`.** Pagination params (`cursor`, `limit`), common filters — define once, reference everywhere.
- **Reusable response objects go in `components/responses`.** Error responses (400, 401, 404, 429, 500) — define once per unique shape.
- **Reusable headers go in `components/headers`.** Rate limit headers etc.

### Content Rules

- **Every** operation, parameter, schema, property, response, and header MUST have a non-empty `description`.
- **Every** schema and parameter MUST have an `example` value. Use realistic examples from the domain file.
- **Every** operation MUST have a `summary` and `operationId`.
- Error examples must match the error type (a 429 example should describe rate limiting, not "bad request").
- Use `$ref` aggressively. The document should be DRY.

### Naming Rules

- operationIds: camelCase verbs matching the story action (e.g., `searchInstruments`, `getInstrumentByFigi`)
- Tags: Match theme names from stories
- Schemas: PascalCase matching domain object names
- Parameters: camelCase matching domain property names

### What NOT to Add

- Do not add endpoints that aren't in the stories
- Do not add properties that aren't in the domain
- Do not add security schemes that aren't in the standards
- If stories are simple (no error codes listed), still add standard error responses (400 for collection endpoints with filters, 404 for single-resource endpoints, 401 if auth is required, 429 rate limiting, 500 server error)

## Step 3: Validate JSON

Before writing the file:
1. Ensure the output is valid JSON (no trailing commas, no duplicate keys)
2. Ensure every `$ref` points to a component that exists
3. Ensure every component is referenced at least once (no orphans)
4. Ensure no `nullable` keyword is used (use `"type": ["string", "null"]` instead per 3.1.0)

## Step 4: Save the File

Save as JSON to a location the user specifies, or ask where they'd like it saved. No specific naming convention required.

**Write directly — do not check for or read existing files first.** If the Write tool fails due to a name conflict, append a number and try again.

## Step 5: Lint with vacuum (optional)

This step uses [vacuum](https://quobix.com/vacuum/), a free open-source OpenAPI linter that runs on the user's machine. Nothing is uploaded, and there is no account or API key.

Check for it:

```bash
command -v vacuum
```

**If vacuum is not installed**, the user already made their choice in "Before You Start". Do not ask again and do not install anything. Skip to Step 6.

**If vacuum is installed**, write the report to a file, then parse it.

```bash
vacuum report --no-update-check -q -o [/absolute/path/to/spec.json] > /tmp/vacuum-report.json
```

Then parse the saved report:

```bash
python3 -c "
import json
data = json.load(open('/tmp/vacuum-report.json'))
stats = data.get('statistics')
issues = (data.get('resultSet') or {}).get('results') or []
if stats:
    print(f'Score: {stats[\"overallScore\"]}/100')
    for c in stats.get('categoryStatistics') or []:
        print(f'  {c[\"categoryName\"]}: {c[\"score\"]} ({c[\"numIssues\"]} issues)')
else:
    print('vacuum could not read the document as OpenAPI. Issues are listed below.')
print(f'Total issues: {len(issues)}')
for i, issue in enumerate(issues, 1):
    line = ((issue.get('range') or {}).get('start') or {}).get('line')
    print(f'{i}. [{issue.get(\"ruleSeverity\")}] {issue.get(\"ruleId\")} (line {line}) {issue.get(\"path\")}')
    print(f'   {issue.get(\"message\")}')
"
```

Use the issue list to drive all fixes below.

### Interpreting Results

vacuum gives one overall score (0-100) plus nine categories, each 0-100: Contract Information, Operations, Tags, Schemas, Validation, Descriptions, Security, Examples, OWASP. It uses vacuum's default "recommended" ruleset.

**Target: 100/100 overall.**

### Handling Issues

1. **Auto-fix** anything that's clearly a formatting or completeness issue (missing description, missing example, missing error response).

2. **Ask the user** about issues that involve design decisions. If a rule conflicts with the standards file, the standards file wins. Tell the user.

3. **Re-run after fixes.** Keep iterating until either:
   - Score is 100/100, or
   - Remaining issues are intentional design choices the user has approved ignoring

### Common Gotchas

- **Errors sink the score.** One `oas3-schema` error took a 98 to 10 in testing. Fix errors first, then warnings, then info.
- **`nullable` keyword.** OpenAPI 3.1.0 dropped `nullable`; use `"type": ["string", "null"]`. vacuum reports it as an `oas3-schema` error.
- **Missing examples** (`oas3-missing-example`). A common deduction: every media type and schema property needs an `example` or `examples`.
- **Duplicate descriptions** (`description-duplication`, info level). Two fields with identical description text; make each one specific.
- **Orphaned components** (`oas3-unused-component`). Schemas in `components` that are never `$ref`'d: remove them or wire them up.
- **The default ruleset is lenient on security.** A no-auth API can still score Security 100. For a stricter pass run `vacuum lint -z [spec]` (hard mode: every rule, including OWASP). Expect many findings; treat that list as things to review with the user, not a score to chase.

## Step 6: Report

Show the user:

```
## OpenAPI Spec Complete

**File:** [path]
**Score:** [Overall] / 100 (vacuum, recommended ruleset)
  - [each category below 100: name and score]

**Report (optional):** For a shareable local HTML report, run `vacuum html-report [spec.json] [vacuum-report.html]`.

**Issues ignored (by design):**
- [list any intentional deviations the user approved]
```

Offer the HTML report; do not generate it unprompted.

If linting was skipped, write `**Score:** not scored (vacuum not installed)` and leave out the category lines, the Report line and the "Issues ignored" section.

Then ask: **"Want to preview this in Swagger UI?"**

Requires Node.js (for `npx http-server`) and internet access (Swagger UI loads from unpkg.com CDN). If Node is not installed, tell the user: "Swagger UI preview requires Node.js. You can paste the spec into https://editor.swagger.io to preview it there instead." Then skip the preview.

If yes and Node is available, create a `swagger-preview.html` file in the same directory as the spec:

```html
<!DOCTYPE html>
<html>
<head>
  <title>[API Name] — Swagger UI</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script>
    fetch('./[spec-filename].json')
      .then(r => r.json())
      .then(spec => {
        SwaggerUIBundle({
          spec: spec,
          dom_id: '#swagger-ui',
          deepLinking: true,
          presets: [SwaggerUIBundle.presets.apis],
          layout: "BaseLayout"
        });
      });
  </script>
</body>
</html>
```

Then serve it locally and open in the browser:

```bash
cd [spec-directory] && npx -y http-server . -p 8090 -c-1 &
sleep 2 && open http://localhost:8090/swagger-preview.html
```

Use port 8090 by default. If it's in use, try 8091, 8092, etc.

After the user has finished reviewing, ask: **"Done previewing? I'll clean up the server and preview file."**

If yes:
1. Kill the http-server process: `lsof -ti:8090 | xargs kill 2>/dev/null`
2. Delete the preview HTML file: remove `swagger-preview.html` from the spec directory
3. Confirm: "Server stopped and preview file removed."

## Key Principles

1. **The stories are the spec's requirements.** Every story becomes one or more operations. No more, no less.

2. **The domain is the schema's source of truth.** Property names, types, enums, relations — all come from the domain file exactly as written.

3. **The standards govern conventions.** Naming, nesting, pagination, error format, auth — standards file wins over any default.

4. **The best practices govern OpenAPI quality.** DRY, descriptions, examples, component extraction — best practices file wins over shortcuts.

5. **Lint is validation, not gospel.** vacuum catches real issues but also flags intentional design choices. The user decides what to fix and what to ignore.

6. **JSON output only.** OpenAPI in JSON, not YAML. This avoids YAML formatting issues with LLM output.
