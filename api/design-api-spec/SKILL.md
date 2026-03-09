---
name: design-api-spec
description: Generate an OpenAPI 3.1.0 specification from API design stories, a domain model, API standards, and OpenAPI best practices. Lints with RateMyOpenAPI and iterates to 100/100. Use when user says "/design-api-spec" or asks to generate an OpenAPI spec from stories.
---

# Design API Spec

Generate an OpenAPI 3.1.0 specification from API design stories, a domain model, API standards, and an OpenAPI best practices file. Then lint it with RateMyOpenAPI and fix issues. This is part of Emmanuel Paraskakis's method for designing APIs with LLMs. Stories can come from the companion `design-api-stories` skill or be written by hand — either way, this skill takes stories + domain + standards + OpenAPI best practices and produces a validated spec.

## When to Use

Use when the user says `/design-api-spec` or asks to generate an OpenAPI spec from stories.

## Inputs

The user must provide (or point to) these files. Files can be named anything — identify each file by its `# Title` heading or content, not by filename.

1. **Stories** — Output from `/design-api-stories`. Defines methods, resources, parameters, and themes. Look for a heading like `# Stories`, `# User Stories`, or similar.
2. **Domain** — Data objects, properties, enums, object relations. Source of truth for schemas. Look for a heading like `# Domain`, `# Domain Model`, or similar.
3. **API Standards** — Style guide, naming, paths, security, error handling. Source of truth for conventions. Look for a heading like `# API Standards`, `# Style Guide`, or similar.
4. **OpenAPI Best Practices** — Formatting rules, DRY principles, SDK compatibility, component structure. Source of truth for OpenAPI document quality. Look for a heading like `# OpenAPI Best Practices`, `# OAS Best Practices`, or similar.

If any file is missing, ask the user to provide it before proceeding.

### Working Example

A complete set of input files and output is available at [`paraskakis/apidesign/conference`](https://github.com/paraskakis/apidesign/tree/main/conference):

- `conference-api-stories.md` — Stories (heading: `# Conference Schedule API — User Stories`)
- `conference-domain.md` — Domain (heading: `# Conference Domain`)
- `API-standards.md` — Standards (heading: `# API Standards`)
- `OpenAPI-best-practices.md` — Best practices (heading: `# OpenAPI Best Practices for LLMs`)
- `conference-schedule-api-example.json` — Spec output from this skill

## Step 1: Read All Inputs

Read all four files completely. Build a mental model of:
- Every endpoint from the stories (method + resource + parameters)
- Every data object and enum from the domain
- Every convention from the standards
- Every formatting rule from the best practices

## Step 2: Generate the OpenAPI Document

Output a single valid JSON file conforming to OpenAPI 3.1.0.

### Structure

Follow this order in the document:

1. `openapi` — Always "3.1.0"
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

## Step 5: Lint with RateMyOpenAPI

Upload the spec and get scores + full issue list in one API call:

```bash
source ~/.zshrc && curl -s -X POST \
  -H "Authorization: Bearer $RMOA_API_KEY" \
  -F "apiFile=@[/absolute/path/to/spec.json]" \
  "https://api.ratemyopenapi.com/sync-report" | python3 -c "
import json, sys
data = json.load(sys.stdin)
r = data['results']['simpleReport']
issues = data['results']['fullReport']['issues']
print(f'Score: {r[\"score\"]} | Docs: {r[\"docsScore\"]} | Completeness: {r[\"completenessScore\"]} | SDK: {r[\"sdkGenerationScore\"]} | Security: {r[\"securityScore\"]}')
print(f'Report: https://ratemyopenapi.com/report/{r.get(\"reportId\", \"\")}')
print(f'Total issues: {len(issues)}')
for i, issue in enumerate(issues, 1):
    path = ' > '.join(str(p) for p in issue.get('path', []))
    print(f'{i}. [{\"ERROR\" if issue[\"severity\"]==0 else \"WARN\"}] {issue[\"code\"]}')
    print(f'   {issue[\"message\"]}')
    print(f'   Path: {path}')
    print()
"
```

The response contains everything needed: scores, `reportUrl`, and the full `issues` array (code, message, path, severity). No second API call required.

Use the issue list to drive all fixes below.

### Interpreting Results

The tool scores four categories (0-100 each):
- **Docs** — Descriptions, summaries, examples
- **Completeness** — Required fields, response codes, schemas
- **SDK Generation** — operationIds, no inline schemas, proper refs
- **Security** — Auth schemes, 401/403 responses

**Target: 100/100 on all categories.**

### Handling Issues

1. **Auto-fix** anything that's clearly a formatting or completeness issue (missing description, missing example, missing error response).

2. **Ask the user** about issues that involve design decisions. Common examples:
   - **No authentication / missing 401**: If the API intentionally has no auth (e.g., a training exercise), tell the user RMOA flagged it and ask if they want to ignore it or add auth.
   - **Missing error codes**: If RMOA expects 401/403 but the stories don't include auth, ask.
   - **Naming conventions**: If RMOA flags a naming pattern that conflicts with the standards file, the standards file wins. Tell the user.

3. **Re-run after fixes.** Keep iterating until either:
   - Score is 100/100, or
   - Remaining issues are intentional design choices the user has approved ignoring

## Step 6: Report

Show the user:

```
## OpenAPI Spec Complete

**File:** [path]
**Score:** [Overall] / 100
  - Docs: [score]
  - Completeness: [score]
  - SDK Generation: [score]
  - Security: [score]

**Report:** [RMOA report URL]

**Issues ignored (by design):**
- [list any intentional deviations the user approved]
```

Then ask: **"Want to preview this in Swagger UI?"**

If yes, create a `swagger-preview.html` file in the same directory as the spec:

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
cd [spec-directory] && npx -y http-server -p 8090 -c-1 &
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

5. **Lint is validation, not gospel.** RMOA catches real issues but also flags intentional design choices. The user decides what to fix and what to ignore.

6. **JSON output only.** OpenAPI in JSON, not YAML. This matches RMOA's expected input and avoids YAML formatting issues with LLM output.
