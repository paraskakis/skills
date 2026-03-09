---
name: design-api
description: Design an API end-to-end — from requirements to a validated OpenAPI spec. Generates stories for review, then produces a linted spec. Emmanuel Paraskakis's method for designing APIs with LLMs. Use when user says "/design-api" or asks to design an API.
---

# Design API

Design an API end-to-end: requirements → stories → OpenAPI spec → lint → iterate. This is Emmanuel Paraskakis's method for designing APIs with LLMs.

All four foundation files (requirements, domain, standards, OpenAPI best practices) are always required. Stories are optional — if provided, they represent the human's design decisions and the skill skips straight to spec generation. If not, the skill generates stories first and pauses for review.

## When to Use

Use when the user says `/design-api` or asks to design an API from requirements or stories.

## Inputs

The user must provide (or point to) these files. Files can be named anything — identify each file by its `# Title` heading or content, not by filename.

**Always required:**
1. **Requirements** — ICP, needs, pain points, use cases, benefits. The "why" and "what." Look for a heading like `# Requirements`, `# Research`, or similar.
2. **Domain** — Data objects, properties, enums, object relations. Source of truth for schemas. Look for a heading like `# Domain`, `# Domain Model`, or similar.
3. **API Standards** — Style guide, naming, paths, security, error handling. Source of truth for conventions. Look for a heading like `# API Standards`, `# Style Guide`, or similar.
4. **OpenAPI Best Practices** — Formatting rules, DRY principles, SDK compatibility, component structure. Source of truth for OpenAPI document quality. Look for a heading like `# OpenAPI Best Practices`, `# OAS Best Practices`, or similar.

**Optional (determines entry point):**
5. **Stories** — API user stories with methods, resources, parameters. The human's design decisions — resource nesting, endpoint grouping, parameter choices. Look for a heading like `# Stories`, `# User Stories`, or similar. If provided → skip to Phase 2 (spec). If not → Phase 1 generates them for review.

If any required file is missing, ask the user to provide it before proceeding.

### Working Example

A complete set of inputs and outputs: [`paraskakis/apidesign/conference`](https://github.com/paraskakis/apidesign/tree/main/conference) — requirements, domain, standards, OpenAPI best practices, stories, and the JSON spec.

### Fetching Files from GitHub

If the user provides a GitHub URL, fetch files using the raw content URL — no authentication required for public repos:

```
https://raw.githubusercontent.com/[owner]/[repo]/[branch]/[path/to/file]
```

Convert any `github.com/[owner]/[repo]/blob/[branch]/[path]` or `github.com/[owner]/[repo]/tree/[branch]/[path]` URL to this format. If the directory listing is needed first, use WebFetch on the `github.com` URL to find the file names, then fetch each file via the raw URL. Only fall back to the `gh` CLI if WebFetch fails.

---

# Phase 1: Stories (skip if stories are provided)

## Step 1: Read Inputs

Read requirements, domain, and standards completely. Understand:
- Who the API consumers are (from requirements)
- What entities and relationships exist (from domain)
- What conventions to follow (from standards)

## Step 2: Identify Themes

Group use cases from the requirements into logical themes. Each theme maps to a cluster of related API operations. **Do not pause here — proceed immediately to Step 3.**

Exception: if the user explicitly asks for step-by-step review, present themes first and wait.

## Step 3: Generate Stories (Default = Simple)

By default, generate **simple stories** — just enough to review the API shape and validate the design direction.

### Simple Story Format (default)

For each story, output ONLY:

```
#### Story [Theme].[Number]: [Name]

**As a** [actor from requirements],
**I want** to [action],
**So that** [business value].

* **Method:** `GET` / `POST` / `PUT` / `PATCH` / `DELETE`
* **Resource:** `/path/{id}/subresource`
* **Parameters:**
  * `paramName` (type, required/optional): Brief description.
```

Rules:
- Method and resource MUST follow the API standards (naming, nesting, pluralization)
- Parameters include path params, query params, and request body fields
- Mark each parameter as required or optional
- Use domain object names and property names exactly as defined
- Do NOT include response schemas, error codes, headers, or implementation details

### Detailed Story Format (on request)

If the user asks for detailed stories (e.g., `--detailed`), add:
- Success response summary (status code + what's returned)
- Error responses (status codes + when they occur)
- Headers (rate limiting, pagination cursors)
- Notes on pagination approach

## Step 4: Review Checkpoint

Present all stories in a single pass, then ask:

**"Here are the stories. Any changes before I generate the spec, or good to go?"**

- If the user has changes → incorporate them, re-present, and ask again.
- If the user says go → save the final stories and proceed to Phase 2.
- If the user passes `--no-pause` → skip the checkpoint and proceed directly.

**Important:** Always save the final, reviewed stories to a file before generating the spec. The saved stories are the source of truth for Phase 2 — the spec must reflect any changes the user made during review.

Save stories to a file the user specifies, or ask where they'd like them saved.

**Write directly — do not check for or read existing files first.** If the Write tool fails due to a name conflict, append a number and try again.

---

# Phase 2: Spec

## Step 5: Read All Inputs

Read stories, domain, standards, and OpenAPI best practices completely. Build a mental model of:
- Every endpoint from the stories (method + resource + parameters)
- Every data object and enum from the domain
- Every convention from the standards
- Every formatting rule from the best practices

## Step 6: Generate the OpenAPI Document

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

## Step 7: Validate JSON

Before writing the file:
1. Ensure the output is valid JSON (no trailing commas, no duplicate keys)
2. Ensure every `$ref` points to a component that exists
3. Ensure every component is referenced at least once (no orphans)
4. Ensure no `nullable` keyword is used (use `"type": ["string", "null"]` instead per 3.1.0)

## Step 8: Save the Spec

Save as JSON to a location the user specifies, or ask where they'd like it saved.

**Write directly — do not check for or read existing files first.** If the Write tool fails due to a name conflict, append a number and try again.

## Step 9: Lint with RateMyOpenAPI (optional)

This step requires an API key from [RateMyOpenAPI](https://ratemyopenapi.com). Sign up for a free account at [api.ratemyopenapi.com/docs](https://api.ratemyopenapi.com/docs) — your API key appears in the Authentication section once logged in. Set it as the environment variable `RMOA_API_KEY` (or any name you prefer — just update the curl command below to match).

**If `RMOA_API_KEY` is not set**, try sourcing the user's shell profile first (`source ~/.zshrc`, `source ~/.bashrc`, or equivalent) — the key may be defined there but not yet loaded in the current session. If still not set, tell the user: "No RMOA API key found. Skipping automated linting. You can get a free key at ratemyopenapi.com and set `RMOA_API_KEY` to enable it." Then skip to Step 10.

**If `RMOA_API_KEY` is set**, upload the spec and get scores + full issue list:

```bash
curl -s -X POST \
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

Use the issue list to drive all fixes below.

### Interpreting Results

Scores four categories (0-100 each):
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

### Common Gotchas

- **No-auth APIs score ~65 on Security.** RMOA flags 8+ warnings about missing 401/403. If the API intentionally has no auth, these are expected — confirm with the user and move on.
- **`nullable` keyword.** OpenAPI 3.1.0 dropped `nullable`. Use `"type": ["string", "null"]` instead. RMOA will flag this.
- **Missing descriptions/examples.** The most common deductions. Every operation, parameter, schema property, and response needs both. Don't skip headers either.
- **Orphaned components.** RMOA flags schemas defined in `components` but never `$ref`'d. Remove them or wire them up.
- **Inline schemas.** Any schema defined directly in a path (not via `$ref`) hurts the SDK Generation score. Extract to `components/schemas`.

## Step 10: Report

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

Requires Node.js (for `npx http-server`) and internet access (Swagger UI loads from unpkg.com CDN). If Node is not installed, tell the user: "Swagger UI preview requires Node.js. You can still open the spec in any OpenAPI viewer — try pasting it at editor.swagger.io." Then skip the preview.

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
cd [spec-directory] && npx -y http-server -p 8090 -c-1 &
sleep 2 && open http://localhost:8090/swagger-preview.html
```

Use port 8090 by default. If it's in use, try 8091, 8092, etc.

After the user has finished reviewing, ask: **"Done previewing? I'll clean up the server and preview file."**

If yes:
1. Kill the http-server process: `lsof -ti:8090 | xargs kill 2>/dev/null`
2. Delete the preview HTML file: remove `swagger-preview.html` from the spec directory
3. Confirm: "Server stopped and preview file removed."

---

# Key Principles

1. **Stories are for human review, not engineering specs.** Keep them scannable. A PM should be able to look at the method + resource + parameters and say "yes, that's the right API" or "no, we're missing X."

2. **Follow the standards religiously.** If the standards say camelCase, every parameter is camelCase. If they say pluralized resources, every resource is plural. The stories ARE the first enforcement of the standards.

3. **Use domain language exactly.** If the domain says `exchangeMic`, the parameter is `exchangeMic`, not `exchange_mic` or `exchangeId`. Domain is the source of truth for naming.

4. **Nest resources per the domain relations.** If a Quote belongs to an Instrument, the resource is `/instruments/{id}/quotes`, not `/quotes?instrumentId=X`. Follow the nesting depth limit from standards.

5. **Don't invent requirements.** If the requirements don't mention delete or update operations, don't add them. Only design what was asked for. If you think something is missing, flag it as a question, don't silently add it.

6. **Pagination follows standards.** If standards specify cursor-based pagination, every collection endpoint gets `cursor` and `limit` parameters. Don't mix pagination styles.

7. **The domain is the schema's source of truth.** Property names, types, enums, relations — all come from the domain file exactly as written.

8. **The best practices govern OpenAPI quality.** DRY, descriptions, examples, component extraction — best practices file wins over shortcuts.

9. **Lint is validation, not gospel.** RMOA catches real issues but also flags intentional design choices. The user decides what to fix and what to ignore.

10. **JSON output only.** OpenAPI in JSON, not YAML. This matches RMOA's expected input and avoids YAML formatting issues with LLM output.
