# Architecture

## 1. Purpose

This document defines how the product is structured technically. It should make
the architecture understandable to future contributors and coding agents without
locking the project to one application domain.

Use this file as the authoritative source for:

- Technology stack decisions
- System boundaries
- Routing, data, state, and rendering responsibilities
- Repository structure
- Testing and validation expectations
- Deployment assumptions
- Architecture decision records

Keep product behavior in `docs/product-spec.md`. Keep execution history in
`.agent/progress.md`. Keep durable agent rules in `AGENTS.md`.

---

## 2. Architecture Summary

Describe the system in one or two paragraphs.

Include:

- Application type and runtime
- Primary framework or platform
- Data source strategy
- Rendering model
- Deployment target
- Major systems intentionally excluded from the initial release

Template:

```text
This project is implemented as a [application type] using [framework],
[language], and [styling approach]. The initial release uses [data source] and
avoids [deferred systems] until product requirements justify them.
```

---

## 3. Architectural Goals

- Keep data and behavior in clear ownership boundaries.
- Preserve one canonical source of truth for domain data.
- Minimize unnecessary client-side JavaScript.
- Make responsive and accessible behavior part of the architecture, not an
  afterthought.
- Keep dependencies justified and limited.
- Make validation repeatable through scripts.
- Leave clear migration paths for future infrastructure.
- Support agent-assisted development with explicit files and task boundaries.

---

## 4. Selected Technology Stack

Document the actual stack for the project. Replace examples with project choices.

### Runtime and Package Management

- Runtime version
- Package manager
- Source control system

### Application

- Framework
- Language
- Rendering strategy
- Routing strategy
- Build tool

### Styling

- Styling system
- Global token location
- Component style conventions
- Theming strategy, if any

### UI Primitives

- Component library or primitive library, if any
- Accessibility primitives
- Icon library
- Rules for adapting library defaults to the product's visual language

### Data and Content

- Local files, API, database, CMS, or generated data
- Canonical data model location
- Schema validation approach
- Ownership and update workflow

### Testing and Validation

- Linting
- Type checking
- Unit tests
- Integration or browser tests
- Build verification
- Visual or accessibility checks

### Hosting and Operations

- Hosting platform
- Preview deployment strategy
- Production deployment strategy
- Required environment variables
- Monitoring or analytics, if any

---

## 5. System Boundaries

### Inside the Application

List responsibilities the application owns, such as:

- User-facing screens
- Domain data presentation
- Search, filtering, sorting, or navigation
- Forms and validation
- Local or remote data access
- Authentication and authorization when required
- SEO metadata
- Accessibility behavior
- Error and empty states

### Outside the Application

List systems intentionally excluded or owned elsewhere, such as:

- External services
- Background jobs
- Payment processing
- Email delivery
- Admin operations
- Data pipelines
- Native mobile apps

Do not add excluded systems without updating this document.

---

## 6. Rendering and Execution Model

Define what runs on the server, client, edge, worker, or external service.

### Server Responsibilities

- Load or prepare canonical data.
- Render non-interactive page structure.
- Generate metadata.
- Protect secrets and privileged operations.
- Handle route-level errors and not-found states.

### Client Responsibilities

- Manage local interaction state.
- Handle browser-only APIs.
- Coordinate focus, keyboard, menu, dialog, or drag behavior.
- Synchronize URL state when required.
- Provide optimistic or pending states for mutations when appropriate.

### Shared Responsibilities

- Pure domain helpers
- Shared types
- Validation schemas
- Formatting utilities

Keep client boundaries narrow. Do not mark broad route trees as client-rendered
only because one nested component is interactive.

---

## 7. Routing Architecture

Document canonical routes, nested layouts, route groups, modals, redirects, and
not-found behavior.

Example:

```text
/
├── [resource]/
│   └── [id]/
└── settings/
```

For each route, define:

- Purpose
- Data requirements
- Loading behavior
- Error behavior
- Metadata behavior
- Whether state should be encoded in the URL

### URL State

Use URL state for shareable or restorable state such as:

- Search query
- Filters
- Sort order
- Pagination cursor
- Selected resource
- Active tab or mode

Avoid URL state for temporary presentation-only state unless browser history
requires it.

---

## 8. Data Architecture

### Canonical Data Sources

List where domain data lives and which layer owns it.

Examples:

```text
src/data/
src/types/
src/lib/
database schema
external API client
```

### Types and Schemas

Define or reference canonical types. Use typed interfaces and structured
validation for structured data.

Example:

```ts
export interface Resource {
  id: string;
  title: string;
  status: "draft" | "published" | "archived";
  createdAt: string;
  updatedAt?: string;
}
```

### Data Invariants

- Identifiers are unique and stable.
- Required fields are always present before rendering.
- Optional fields are handled gracefully.
- Derived lists are generated from canonical data.
- Visual components do not duplicate domain data.
- Parsing and validation happen at API or data boundaries.

### Query and Domain Helpers

Use pure functions for lookup, filtering, sorting, normalization, and derivation.
Keep this logic out of visual components.

---

## 9. Proposed Repository Structure

Adjust this structure to match the selected stack.

```text
project-root/
├── AGENTS.md
├── README.md
├── docs/
│   ├── product-spec.md
│   ├── architecture.md
│   └── visual-rubric.md
├── .agent/
│   ├── prd.json
│   ├── progress.md
│   └── iteration-prompt.md
├── scripts/
│   └── verify.sh
├── src/
│   ├── app/ or pages/
│   ├── components/
│   ├── data/
│   ├── lib/
│   ├── styles/
│   └── types/
├── tests/
├── package.json
└── tsconfig.json
```

The exact file count may change, but ownership boundaries should remain clear.

---

## 10. Component and Module Responsibilities

Document important modules and what they own.

For each major component or module, specify:

- Inputs
- Outputs
- Owned behavior
- Behavior it must not own
- Accessibility responsibilities
- Data dependencies

Example:

### `resource-list`

Responsible for:

- Receiving an ordered collection of resources
- Rendering the collection
- Preserving logical DOM order
- Exposing selection or navigation affordances

It must not own canonical resource data or perform unrelated mutations.

### `resource-detail`

Responsible for:

- Displaying a single resource
- Showing complete relevant metadata
- Handling focused interaction state when applicable
- Providing return or next-step navigation

It should receive data from a route, server component, loader, or API boundary
rather than querying global state directly.

---

## 11. State Architecture

### Server State

Document remote or server-owned data, cache behavior, revalidation, and mutation
flow.

### URL State

Use for state that must survive reloads, sharing, or browser back and forward.

### Local Client State

Use for temporary UI state, including:

- Open or closed controls
- Focus restoration targets
- Draft input before submission
- Presentation-only toggles

### Global Client State

Avoid global state by default. Introduce it only when multiple distant surfaces
need shared mutable state and simpler URL, server, or local state is insufficient.

If a global state library is added, document:

- Why it is required
- Which state it owns
- How it is tested
- How it avoids duplicating server state

---

## 12. Styling Architecture

### Design Tokens

Define global tokens for:

- Backgrounds
- Text colors
- Muted text
- Borders or separators
- Accent colors
- Spacing
- Radius
- Shadows
- Typography
- Motion duration and easing

Components should consume tokens instead of inventing unrelated colors or
spacing values.

### Component Styling

Document whether the project uses utility classes, CSS Modules, CSS-in-JS,
compiled styles, design-system components, or another approach.

### Responsive Rules

- Define stable dimensions for fixed-format controls and grids.
- Prevent text and controls from overflowing containers.
- Avoid layout shifts caused by dynamic content.
- Keep readable content within sensible line lengths.

### Motion Rules

- Motion must support the user's task.
- Non-essential motion must respect reduced-motion preferences.
- Avoid adding animation before the static layout is correct.

---

## 13. Asset and Media Architecture

Document how images, icons, documents, video, audio, generated assets, or uploads
are stored and rendered.

Include:

- Source directories
- Preferred formats
- Ownership and licensing notes
- Required metadata
- Optimization strategy
- Missing-asset behavior

Baseline expectations:

- Known-size media should reserve space to prevent layout shift.
- Non-critical assets should load lazily.
- Decorative assets should not obscure primary content.
- User-provided assets should be validated before use.

---

## 14. Accessibility Architecture

### Semantic Structure

- Use appropriate landmarks and heading hierarchy.
- Preserve logical reading order.
- Prefer native controls before custom controls.

### Interaction Patterns

Document requirements for:

- Dialogs
- Menus
- Tabs
- Forms
- Drag and drop
- Keyboard shortcuts
- Focus restoration

### Feedback

- Loading, success, and error states must be visible and accessible.
- Destructive actions must be clearly labeled.
- Color must not be the only indicator of state.

---

## 15. Performance Architecture

Baseline choices:

- Keep client bundles small.
- Avoid unnecessary dependencies.
- Use server rendering, static generation, caching, or streaming where
  appropriate.
- Prevent layout shift for media and dynamic content.
- Avoid expensive work during render.
- Measure before adding complex optimization.

Document product-specific targets for:

- Initial load
- Interaction latency
- Data volume
- Asset payload
- Runtime memory

---

## 16. SEO and Metadata Architecture

When public pages exist, document:

- Title and description generation
- Canonical URLs
- Social metadata
- Structured data
- Indexing rules
- Private metadata constraints

Each canonical resource route should derive metadata from the canonical data
source when possible.

---

## 17. Testing Architecture

### Verification Script

Create or maintain a single verification script when practical:

```text
scripts/verify.sh
```

It should run the project-required checks, such as:

```bash
pnpm lint
pnpm exec tsc --noEmit
pnpm test
pnpm build
```

Use the package manager and commands that match the project.

### Unit Tests

Cover pure functions, validation, formatting, and domain behavior.

### Integration or Browser Tests

Cover primary workflows, direct routes, keyboard behavior, URL state, and
responsive overflow where relevant.

### Visual Review

Automated tests do not replace review against `docs/visual-rubric.md` when
visual quality is part of the task.

---

## 18. Error and Empty-State Architecture

Document how the product handles:

- Unknown routes
- Missing resources
- Empty datasets
- Invalid query parameters
- Permission failures
- Network failures
- Validation errors
- Partial data

Error states should provide user-facing recovery actions where possible and
avoid exposing raw implementation details.

---

## 19. Deployment Architecture

Document:

- Source control workflow
- Branching expectations
- Preview deployment behavior
- Production deployment behavior
- Environment variables and secrets
- Rollback strategy
- Monitoring or analytics

Agents should not push, merge, deploy, or modify production configuration unless
the user or task explicitly requests it.

---

## 20. Agent-Assisted Development Architecture

### Automatically Discovered Instructions

The root `AGENTS.md` is the primary repository instruction file. It should direct
agents to read:

- `docs/product-spec.md`
- `docs/visual-rubric.md`
- `docs/architecture.md`
- `.agent/prd.json`
- `.agent/progress.md`

### Task Execution

`.agent/iteration-prompt.md` defines the iteration loop:

1. Read required context.
2. Select exactly one pending task unless instructed otherwise.
3. Restate acceptance criteria.
4. Inspect the current implementation.
5. Implement the smallest coherent change.
6. Run validation.
7. Review the diff.
8. Update progress and task state according to the project process.
9. Stop after the selected task.

### Repository Memory

- `AGENTS.md` stores durable rules.
- `docs/product-spec.md` stores product requirements.
- `docs/architecture.md` stores technical decisions.
- `docs/visual-rubric.md` stores visual evaluation criteria.
- `.agent/prd.json` stores task state when the project uses agent-managed tasks.
- `.agent/progress.md` stores chronological execution history.
- `scripts/verify.sh` provides an objective completion gate when present.

### Agent Safety Boundaries

Agents must not:

- Modify unrelated files.
- Add dependencies without justification.
- Introduce major infrastructure without an approved architecture update.
- Mark tasks complete while required validation fails.
- Push, merge, deploy, or change production settings unless explicitly asked.
- Duplicate canonical domain data inside visual components.

---

## 21. Architecture Decision Log

Use this section to record durable decisions. Keep entries short and factual.

### ADR-001: Choose the Application Architecture

**Decision:** Document the selected architecture.

**Reason:** Explain why it fits the product requirements and current constraints.

**Status:** Accepted

### ADR-002: Choose the Data Source Strategy

**Decision:** Document whether the product starts with local data, an API, a
database, a CMS, generated content, or another source.

**Reason:** Explain the tradeoff and migration path.

**Status:** Proposed
