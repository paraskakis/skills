---
name: design-api-stories
description: Generate API design stories from requirements, a domain model, and API standards. Stories bridge product requirements and OpenAPI specs — Emmanuel Paraskakis's method for designing APIs with LLMs. Use when user says "/design-api-stories" or asks to generate API user stories.
---

# Design API Stories

Generate API design stories from requirements, a domain model, and API standards. This is Emmanuel Paraskakis's method for designing APIs with LLMs — the stories become the bridge between product requirements and an OpenAPI specification.

## When to Use

Use when the user says `/design-api-stories` or asks to generate API user stories from requirements.

## Inputs

The user must provide three files (or paste their content):

1. **Requirements** — ICP, needs, pain points, use cases, benefits. The "why" and "what."
2. **Domain** — Data objects, properties, enums, object relations. The "nouns."
3. **API Standards** — Style guide, naming conventions, path rules, security, error handling. The "how."

If any file is missing, ask the user to provide it before proceeding.

### Fetching Files from GitHub

If the user provides a GitHub URL, fetch files using the raw content URL — no authentication required for public repos:

```
https://raw.githubusercontent.com/[owner]/[repo]/[branch]/[path/to/file]
```

Convert any `github.com/[owner]/[repo]/blob/[branch]/[path]` or `github.com/[owner]/[repo]/tree/[branch]/[path]` URL to this format. If the directory listing is needed first, use WebFetch on the `github.com` URL to find the file names, then fetch each file via the raw URL. Only fall back to the `gh` CLI if WebFetch fails.

## Step 1: Read All Inputs

Read all three files completely. Understand:
- Who the API consumers are (from requirements)
- What entities and relationships exist (from domain)
- What conventions to follow (from standards)

## Step 2: Identify Themes and Use Cases

Group the use cases from the requirements into logical themes. Each theme maps to a cluster of related API operations. **Do not pause here — proceed immediately to Step 3 and generate all stories.**

Exception: if the user explicitly asks for step-by-step review, present the themes first and wait for confirmation.

## Step 3: Generate Stories (Default = Simple)

By default, generate **simple stories** — just enough for a product manager to review the API shape and validate the design direction.

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

Rules for simple stories:
- Method and resource MUST follow the API standards (naming, nesting, pluralization)
- Parameters include path params, query params, and request body fields
- Mark each parameter as required or optional
- Use domain object names and property names exactly as defined
- Do NOT include response schemas, error codes, headers, or implementation details
- Do NOT include authentication details unless the standards specify something unusual

### Detailed Story Format (on request)

If the user asks for detailed stories (e.g., `/design-api-stories --detailed`), add:
- Success response summary (status code + what's returned)
- Error responses (status codes + when they occur)
- Headers (rate limiting, pagination cursors)
- Notes on pagination approach

## Step 4: Present for Review

Present all themes and stories in a single pass. Do not pause between themes or ask for confirmation after each one — deliver the complete output, then ask once at the end if anything needs to change.

Exception: if the user explicitly asks for step-by-step review, pause after each theme.

## Step 5: Save

Save the completed stories to a file the user specifies, or suggest a default name based on the domain:
- `[domain]-stories.md`

**Write directly — do not check for or read existing files first.** If the Write tool fails due to a name conflict, append a number (e.g., `[domain]-stories-2.md`) and try again.

## Key Principles

1. **Stories are for PM review, not engineering specs.** Keep them scannable. A PM should be able to look at the method + resource + parameters and say "yes, that's the right API" or "no, we're missing X."

2. **Follow the standards religiously.** If the standards say camelCase, every parameter is camelCase. If they say pluralized resources, every resource is plural. If they say no /api prefix, don't add one. The stories ARE the first enforcement of the standards.

3. **Use domain language exactly.** If the domain says `exchangeMic`, the parameter is `exchangeMic`, not `exchange_mic` or `exchangeId`. Domain is the source of truth for naming.

4. **Nest resources per the domain relations.** If a Quote belongs to an Instrument, the resource is `/instruments/{id}/quotes`, not `/quotes?instrumentId=X`. Follow the nesting depth limit from standards.

5. **Don't invent requirements.** If the requirements don't mention delete or update operations, don't add them. Only design what was asked for. If you think something is missing, flag it as a question, don't silently add it.

6. **Pagination follows standards.** If standards specify cursor-based pagination, every collection endpoint gets `cursor` and `limit` parameters. Don't mix pagination styles.

## Example Output (Simple)

```markdown
# Pet Store API: User Stories

## Theme 1: Pet Management

#### Story 1.1: List Pets

**As a** store employee,
**I want** to browse all pets with optional filters,
**So that** I can find pets matching a customer's preferences.

* **Method:** `GET`
* **Resource:** `/pets`
* **Parameters:**
  * `cursor` (string, optional): Pagination cursor.
  * `limit` (integer, optional): Max results. Default 20.
  * `species` (enum, optional): Filter by species (Dog, Cat, Bird, Fish).
  * `status` (enum, optional): Filter by availability (Available, Sold, Pending).

#### Story 1.2: Get Pet Details

**As a** store employee,
**I want** to view full details of a specific pet,
**So that** I can answer customer questions about the pet.

* **Method:** `GET`
* **Resource:** `/pets/{petId}`
* **Parameters:**
  * `petId` (string, required): Unique pet identifier.
```
