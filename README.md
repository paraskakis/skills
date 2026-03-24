# Skills

Skills used with agents, by Emmanuel Paraskakis.

## API Design

- **design-api** — End-to-end: requirements → stories → review → OpenAPI spec → lint → iterate. One skill, one flow. Defaults to OpenAPI 3.1.0 for maximum tool compatibility — override by specifying a version in your input. If you already have stories, provide them as input and the skill skips straight to spec generation.
- **design-api-stories** — Stories only. Use if you just need the stories step.
- **design-api-spec** — Spec only. Use if you already have stories and want to go straight to a spec.

### Input files

The skills require four separate input files. They're separate because each has a different owner, changes at a different pace, and can be reused across projects:

1. **Requirements** — Who the API consumers are, what they need, why they need it. Pain points, use cases, benefits. This is the product perspective.
2. **Domain model** — The data objects, properties, enums, and relationships. The nouns of your system. This is the source of truth for schemas.
3. **API standards** — Your organization's style guide: naming conventions, path rules, pagination, error handling, security. Reusable across all your APIs.
4. **OpenAPI best practices** — How to write a good OpenAPI document: DRY principles, component extraction, description rules, SDK compatibility. Also reusable across projects.

Each skill includes a working example of these files in `references/examples/` (conference scheduling API).

### Optional dependencies

For the full experience (automated linting + local preview):

- **RateMyOpenAPI API key** (free) — [api.ratemyopenapi.com/docs](https://api.ratemyopenapi.com/docs). Set as `RMOA_API_KEY` env var.
- **Node.js** — for Swagger UI preview via `npx http-server`.
- **curl + python3** — for the RMOA API call (usually pre-installed).

Without these, the skills still generate a complete OpenAPI spec.

## Install

### All skills

```bash
npx skills add paraskakis/skills
```

### All API skills

```bash
npx skills add paraskakis/skills/api
```

### Just the combined API design skill

```bash
npx skills add paraskakis/skills --skill design-api
```

### Agent-specific install

```bash
npx skills add paraskakis/skills/api -a claude-code
npx skills add paraskakis/skills/api -a cursor
npx skills add paraskakis/skills/api -a codex
```

Add `-g` for global (user-level, available in all projects):

```bash
npx skills add paraskakis/skills/api -a claude-code -g
```

## Manual install (Claude Code)

**Project-scoped** (committed with your code):

```bash
git clone https://github.com/paraskakis/skills.git /tmp/paraskakis-skills
mkdir -p .claude/skills
cp -R /tmp/paraskakis-skills/api/design-api .claude/skills/design-api
```

**User-global** (available in all projects):

```bash
git clone https://github.com/paraskakis/skills.git /tmp/paraskakis-skills
mkdir -p ~/.claude/skills
cp -R /tmp/paraskakis-skills/api/design-api ~/.claude/skills/design-api
```
