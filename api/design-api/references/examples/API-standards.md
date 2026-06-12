# Emmanuel Paraskakis's API Standards

## Guidelines:
1. Default to a HTTP "REST" API unless otherwise specified.
2. Follow Joshua Bloch's principles in "How to Design a Good API and Why it Matters": https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/32713.pdf
   * Characteristics of a good API:
   * Easy to learn
   * Easy to use, even without documentation
   * Hard to misuse
   * Easy to read and maintain code that uses it
   * Sufficiently powerful to satisfy requirements
   * Easy to extend
   * Appropriate to audience
3. Design for agents as well as humans. Agents run on pattern matching - be boring. Keep it simple, keep it standard, no surprises, name it well, describe it well. Every extra decision point lowers an agent's success rate.
4. Be consistent. You may diverge from consistency to follow a specific standard, for example use different casing from main API to follow an authentication standard.
5. Use accepted global and industry standards as far as possible unless specified otherwise.

## Standards:
Follow every MUST below; deviate from SHOULD only with good reason; MAY is genuinely optional.
The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are to be interpreted as described in BCP 14 (RFC 2119: https://www.rfc-editor.org/rfc/rfc2119 and RFC 8174: https://www.rfc-editor.org/rfc/rfc8174) when they appear in capitals.
Default to HTTP standards as found in the following RFCs:
https://www.rfc-editor.org/rfc/rfc9110
https://www.rfc-editor.org/rfc/rfc9111
https://www.rfc-editor.org/rfc/rfc9112
https://www.rfc-editor.org/rfc/rfc9113
https://www.rfc-editor.org/rfc/rfc9114

### Casing:
One convention per surface - no exceptions, no special cases:

| Element | Convention | Example |
|---------|-----------|---------|
| JSON field names | camelCase; acronyms are words | `taskId`, `imageUrl`, `apiKey` - never `taskID` |
| Primary key field | lowercase `id` | `"id": "1c6764cb-..."` |
| Query parameters | camelCase (mirror the field names), matched case-insensitively | `?minPrice=100` |
| Path segments | lowercase; kebab-case for multi-word resources | `/tasks`, `/line-items` |
| Path template parameters | camelCase | `{taskId}` |
| Headers | Hyphenated-Pascal-Case (case-insensitive per HTTP) | `X-RateLimit-Limit` |
| Enum values | lowercase words | `"pending"`, `"active"` |
| Booleans | literal `true` / `false` | `?completed=false` |

### Naming Conventions:
1. Use established names: schema repositories (schema.org, GS1, ISO, and similar vertical industry standards) and the definitions in RFCs, IANA registries, and JSON Schema.
2. Avoid abbreviations except where they are very well known - for example, `ID` is ok and preferred over `identifier`.
3. Prefer descriptive, self-explanatory field names an agent can interpret without a lookup - for example, `activeUserCount`, not `AUC`. Good names mean the value is trusted without an extra verification call.
4. Use names the way the industry uses them - they align with model training data and whatever is in the agent's context.
5. Use the standard vocabulary - do not invent language. Specifically:
   * Timestamps end in `At`: `createdAt`, `updatedAt`, `completedAt` - never `dateLastActivity`, `creationDate`, or `modifyTime`.
   * Booleans read as bare adjectives or past participles: `completed`, `active` - never `isComplete` or `hasBeenCompleted`.
   * Status enums are lowercase words: `"pending"`, `"active"`, `"completed"`, `"cancelled"`.
   * Keep fields concise - do not over-qualify: `unit`, not `unitCode`; `status`, not `statusType`.
   * Prefer the international term: `postalCode`, not `zip`.

### Paths:
1. Do not use /api or other redundant element as a base path unless specified.
2. Do not put a version number like /v1 in the path unless specified. APIs start unversioned - see Versioning & Deprecation for when `/v2` appears.
3. No trailing slashes, ever - `/tasks`, never `/tasks/`.

### Resources:
1. Pluralize resource names.
2. You SHOULD nest collection paths to follow object relations, but not more than 3 levels - for example, `projects/{id}/tasks`.
3. Nest collection operations, but keep item-level operations flat - for example, `GET projects/{id}/tasks` and `POST projects/{id}/tasks` are good, but prefer `GET /tasks/{id}`, `PUT /tasks/{id}` and `DELETE /tasks/{id}` over `projects/{id}/tasks/{id}`, which is unnecessarily complex. Exception: keep the nested item path when the item's identifier is only unique within its parent (common with slugs - see IDs).
4. Every collection resource MUST have a list endpoint (GET on the collection). Agents cannot guess IDs - discovery starts at the list.

### Outcome Endpoints:
When requirements describe a multi-step goal, consider a single use-case-driven endpoint instead of forcing clients to orchestrate several calls. An outcome endpoint is legitimate only when ALL of the following hold:
1. It maps to a goal stated in the requirements - never speculative.
2. It replaces a multi-call orchestration (an aggregate read, or a write spanning resources).
3. It stays resource-framed - `POST /orders/{id}/cancel`, never `POST /cancelOrder`.
4. The CRUD primitives still exist underneath - the outcome endpoint is a shortcut, not the only path.
If any test fails, use plain CRUD. Do not use RPC-style endpoints such as `POST /deletetask`.

### Methods:
1. Avoid using PATCH unless specifically requested and appropriate to the use case. Prefer PUT instead. If PATCH is requested, use JSON Merge Patch (RFC 7396) with the `application/merge-patch+json` media type.
2. POST creation MUST return 201 with a `Location` header and the created representation. For long-running operations, return 202 Accepted with a `Location` header pointing to a status resource the client can poll; when the work completes, the status resource links to the final result.
3. PUT is a full replacement and returns 200 with the updated representation.
4. DELETE returns 204 with an empty body. Long-running deletes follow the same 202 pattern as POST.
5. Create and long-running examples:
```
POST /tasks
{ "name": "Buy Milk", "completed": false }

HTTP/1.1 201 Created
Location: /tasks/1c6764cb-c211-4be8-aa42-91bd1ba38c83

{ "id": "1c6764cb-c211-4be8-aa42-91bd1ba38c83", "name": "Buy Milk", "completed": false }
```
```
POST /reports

HTTP/1.1 202 Accepted
Location: /reports/jobs/7e0a5f0e-9d4b-4c6a-8f2d-3b1a9c5e7d42
```

### IDs:
1. Default to UUIDs for all resource identifiers, unless otherwise specified for each resource in requirements - Follow https://www.rfc-editor.org/rfc/rfc9562.html
2. Prefer UUIDv7: it is time-ordered, which gives collections a stable sort order and good index locality. Note that v7 exposes creation time - where that is sensitive, use UUIDv4.
3. Use slugs or well-known codes instead when the requirements ask for them, or when a natural, stable, public identifier exists - for example, public handles, country codes, currency codes, airport codes, postal codes, or public entities such as a school or a cohort.
4. Slugs are often unique only within their parent resource - if so, keep the nested item path (see Resources). Examples: `/countries/GR` (globally unique code, flat), `/schools/emmanuel/cohorts/2` (slug unique within parent, nested).

### References:
1. Reference another resource with a plain ID field named `<resource>Id` - for example, a task carries `"projectId": "1c6764cb-..."`. Do not embed full objects or URLs by default.
2. With `?expand=project`, ADD an embedded `project` object alongside `projectId`. Fields never change type - `projectId` stays a string whether or not the expansion is present.
3. Do not use URLs as references. IDs plus this document's predictable path patterns make every URL derivable - that is the only hypermedia you need.

### Properties:
1. Use camelCase for field names and parameters; acronyms are words (see Casing). The bare primary key is `id`.
2. If possible, use enums over strings
3. Every resource carries the standard attributes `id`, `createdAt`, and `updatedAt` (add `createdBy` / `updatedBy` when there is a user model). Uniform shapes across resources let consumers - especially agents - transfer what they learned from one resource to all the others.
4. Name the same concept identically across all resources - if it is `lineOfBusiness` in one place, it is never `lob` in another. Same name, same type, same validation everywhere.
5. Booleans are the literal lowercase values `true` and `false` everywhere - fields and query parameters alike (`?completed=false`). Never `1`/`0` or `yes`/`no`.
6. Treat enums as open and extensible: consumers MUST tolerate unknown enum values, and adding a value is then non-breaking. Document any enum that is truly closed.

### Dates:
Use ISO 8601 Dates - Follow https://datatracker.ietf.org/doc/html/rfc3339 &  https://datatracker.ietf.org/doc/html/rfc9557 - for example, `"createdAt": "2026-06-11T19:30:00Z"`.

### Requests:
1. All request bodies MUST be JSON with the `application/json` media type. Do not use XML or form-encoded bodies.
2. Unknown fields in request bodies MUST be rejected with a clear Problem Details error naming the offending field (see Errors). Silently ignoring them hides client mistakes - a named rejection lets an agent correct itself in one try.

### Responses:
1. All responses MUST use JSON with the `application/json` media type. Errors use `application/problem+json` (see Errors).
2. Keep response shapes focused. Return the fields consumers need, not everything you have - verbose responses are a silent token tax on agents and compound across every call.
3. Omit optional fields that have no value - do NOT emit `null` unless null itself carries meaning (such as an explicitly cleared value).
4. Monetary amounts MUST be decimal strings paired with an ISO 4217 currency field - for example, `{ "amount": "19.99", "currency": "USD" }`. Never use floating point for money.

### Query Parameters:
1. Parameter names are camelCase for readability (`minPrice`, mirroring the field they filter), but servers MUST match parameter names case-insensitively - downcase before comparing. `?promoCode=X` and `?promocode=X` MUST behave identically; silently ignoring a mis-cased parameter is a classic, painful failure.
2. Filter with per-resource field=value parameters - for example, `GET /orders?status=active`. For ranges, use simple named parameters such as `?minPrice=100&maxDate=2026-12-31`. Do not invent query languages.
3. Accept comma-separated values to match multiple values for one field - for example, `GET /orders?status=active,pending`.
4. Do not add a universal search endpoint (`POST /search`) unless search IS the product. Per-resource filters are self-documenting; universal search is a hallucination factory.
5. Sort with `sort` and `order` parameters - for example, `GET /tasks?sort=year&order=desc`. `order` defaults to `asc`.
6. You SHOULD support sparse fieldsets via a `fields` parameter - for example, `GET /tasks?fields=id,name,completed` returns only those fields. This lets consumers - especially agents - avoid paying for 80 fields when they need 3.
7. You MAY support expanding references via an `expand` parameter - for example, `GET /tasks/{id}?expand=project` embeds the referenced resource and saves an extra call.

### Collections & Pagination:
1. Every collection response uses a wrapper - no bare arrays. A filtered, paginated request and its response look like this:
```
GET /tasks?completed=false&limit=2&offset=0

{
  "data": [
    { "id": "1c6764cb-c211-4be8-aa42-91bd1ba38c83", "name": "Buy Milk", "completed": false },
    { "id": "7e0a5f0e-9d4b-4c6a-8f2d-3b1a9c5e7d42", "name": "Buy Cookies", "completed": false }
  ],
  "meta": { "totalCount": 77, "limit": 2, "offset": 0 }
}
```
2. `meta.totalCount` MUST be present, even when the full set fits in one page - unless there is a documented good reason (such as a count query that is prohibitively expensive at scale). Omission is the exception, never the default.
3. Paginate with `offset` and `limit` query parameters. Default `limit`: 50. Maximum `limit`: 1000. Requests above the maximum are clamped to it, not rejected.
4. Design filters first - good filters reduce the result set before paging kicks in. Pagination is a safety net, not the front door.
5. Every collection MUST have a stable default sort order (`createdAt` or `id`, ascending) - without deterministic order, offset pagination returns duplicates and gaps.
6. An empty collection returns 200 with an empty `data` array and `totalCount: 0` - NEVER 404. The collection exists; it merely has no items.
7. Do not use cursor or page-number pagination unless requirements demand it.

### Errors:
1. Define all possible error conditions and describe them with the Problem Details format - https://www.rfc-editor.org/rfc/rfc9457.html - using the `application/problem+json` media type.
2. Use the standard RFC 9457 fields: `type` (a URI identifying the error class - this is the machine-readable identifier, so do not add a separate `code` field), `title` (short, stable summary of the error class), `status` (matching the HTTP status code), `detail` (what went wrong in this specific occurrence), and `instance` (a URI reference identifying this specific occurrence - commonly the request path, or a unique error-instance URI).
3. Errors MUST enable one-try recovery: identify the failing field and why. For validation errors, include an `errors` extension array. A bare "400 Bad Request" is not acceptable.
4. The `title` and `detail` text must describe the actual failure precisely. Agents act on what the error says - generic or inaccurate wording sends them down the wrong recovery path.
5. Every error response looks like this:
```
HTTP/1.1 400 Bad Request
Content-Type: application/problem+json

{
  "type": "https://api.example.com/problems/validation-error",
  "title": "Validation error",
  "status": 400,
  "detail": "The request body has 1 invalid field.",
  "instance": "/tasks",
  "errors": [
    { "name": "priority", "reason": "must be a positive integer" }
  ]
}
```

### Status Codes:
1. Use status codes 200, 201, 202 and 204 appropriately for successful responses.
2. Use 400 for malformed or invalid requests - and only for those (see 409).
3. Include a 401 status code for endpoints requiring authentication.
4. Use 403 for insufficient permissions - do not reuse 401.
5. Use 404 for a missing single resource or an unknown path - NOT for an empty collection (see Collections & Pagination).
6. Use 405 when the resource exists but the method is not supported.
7. Use 406 when the client's `Accept` header requests a media type other than JSON.
8. Use 409 for duplicates and resource-state conflicts. Do not collapse conflicts into a generic 400. The distinction matters for recovery: a 400 tells the caller to fix the request; a 409 tells it the request was fine but the state disagrees.
9. Use 412 for failed conditional requests, such as a stale `If-Match` on PUT.
10. Use 415 when the request body is not JSON (wrong or missing media type).
11. Use 429 status codes to indicate rate-limiting issues.
12. Use 500 status codes for server errors.
13. NEVER return an error in a body with a 200 status. The status code is the contract - clients and agents branch on it before they read the body.

### Idempotency:
1. Design for retries - agents retry failed or ambiguous calls.
2. PUT and DELETE are naturally idempotent. Keep them that way.
3. POST creation is the hard case: enforce server-side uniqueness constraints (the real safety net) and define duplicate behavior with a clear error.
4. You MAY support an `Idempotency-Key` header, but never rely on clients sending it. If supported, a duplicate key MUST replay the original response - same status and body - without re-executing side effects.
5. For update safety, SHOULD support optimistic concurrency: return an `ETag` on reads and honor `If-Match` on PUT; a stale write returns 412 Precondition Failed.
6. Conditional GET (`If-None-Match` returning 304 Not Modified) spares clients re-downloading unchanged resources. It MAY be supported - it adds caching complexity, so specify it only when requirements call for it.

### Rate Limiting:
1. Include the de facto rate-limiting headers - `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After` - on ALL responses, 2XX and 4XX alike.
2. Note: the `X-` prefix is formally deprecated (RFC 6648) and the IETF is standardizing `RateLimit` / `RateLimit-Policy` headers (draft-ietf-httpapi-ratelimit-headers - still a draft as of June 2026). Use the de facto X- headers until that publishes, then migrate.
3. 429 and 503 responses MUST include `Retry-After` so clients know exactly how long to back off.
4. Example:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 97
Retry-After: 30
```

### Security:
1. HTTPS only. All endpoints MUST be served over TLS; plain HTTP MUST NOT be supported.
2. Always implement authentication unless requirements explicitly make the API public.
3. Supported schemes - all expressible in OpenAPI so the spec can enumerate them: API Key (sent in the `Authorization` header using the `Bearer` scheme, never in `X-Api-Key`), OAuth 2.0, Bearer/JWT, and mTLS for high-security contexts. Let the requirements choose.
4. Prefer API Key or OAuth 2.0 when requirements do not specify. If the choice is not obvious, ask the user.
5. NEVER use Basic Auth. NEVER pass credentials, keys, or tokens in URLs.
6. Follow best practices as outlined in OWASP API Top-10 - https://owasp.org/www-project-api-security/
7. Define 401 (Unauthorized) responses for all authenticated endpoints, and 403 (Forbidden) where permissions apply.

### Versioning & Deprecation:
1. Only breaking changes justify a new version. Breaking changes include: removing a resource or field, URI changes, changing optional to required, and new or different status codes. Adding optional fields, parameters, or resources is non-breaking.
2. Version format: major version in the path (`/v2`). Date-based version pinning (Stripe, GitHub) is the gold standard but costly. Never use query parameters for versioning.
3. Signal deprecation with machine-readable headers: `Deprecation` (RFC 9745) and `Sunset` (RFC 8594), plus a `Link` header pointing to the successor. Agents do not read changelogs - unsignaled breaking changes fail silently. Example:
```
Deprecation: @1798761600
Sunset: Wed, 30 Jun 2027 23:59:59 GMT
Link: </v2/tasks>; rel="successor-version", <https://api.example.com/docs/deprecations/tasks>; rel="deprecation"
```

## Created by Emmanuel Paraskakis of Level 250, Inc.
