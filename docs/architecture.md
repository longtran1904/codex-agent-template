# Manga Panel Gallery — Architecture

## 1. Architecture summary

Manga Panel Gallery will be implemented as a single Next.js application using the App Router, TypeScript, Tailwind CSS, local image assets, and a typed local content source.

The initial architecture deliberately avoids a separate backend, database, CMS, global state library, and authentication system. The product is primarily static content with lightweight client-side interaction. This keeps the first release simple, fast, deployable, and easy for coding agents to reason about.

The system must support a six-panel vertical slice immediately and scale to at least 100 panels without changing its fundamental structure.

---

## 2. Architectural goals

- Keep panel content in one canonical source.
- Generate stable, shareable panel routes.
- Minimize client-side JavaScript.
- Preserve strong image performance.
- Support search and filtering without a backend.
- Maintain accessible keyboard and focus behavior.
- Keep visual components independent from content storage.
- Allow a future migration to MDX, a CMS, or a database without rewriting the presentation layer.
- Make repository rules and validation clear for agent-assisted development.

---

## 3. Selected technology stack

### Runtime and package management

- Node.js 20.9 or newer
- pnpm
- Git

### Application

- Next.js App Router
- React
- TypeScript
- Server Components by default
- Client Components only for interactive behavior

### Styling

- Tailwind CSS
- CSS custom properties for design tokens
- `globals.css` for global design foundations
- CSS Modules only for isolated styles that are difficult to express clearly with Tailwind

### UI primitives

- shadcn/ui components added selectively
- Radix-based Dialog behavior through shadcn/ui
- Sheet for mobile filter controls
- Button and visually hidden primitives as required

The project must not inherit generic shadcn dashboard styling. Primitives provide interaction behavior; the gallery owns the visual language.

### Images

- Local image files under `public/panels/`
- `next/image`
- WebP or AVIF preferred
- Explicit width and height metadata
- Natural aspect-ratio rendering

### Content

- Typed TypeScript records in `src/data/panels.ts`
- No database in the initial release
- No CMS in the initial release

### Testing and validation

- ESLint
- TypeScript compiler with `--noEmit`
- Next.js production build
- Playwright for browser-level interaction and responsive checks
- A repository verification script

### Hosting

- GitHub
- Vercel
- Preview deployment for pull requests or feature branches

---

## 4. System boundaries

### Inside the application

- Exhibition introduction
- Gallery composition
- Panel detail routes
- Search and filtering
- Local content model
- Image optimization
- SEO metadata
- Accessibility behavior
- Browser history and URL state

### Outside the application

The initial release will not contain:

- Authentication
- Database
- CMS
- User-generated content
- Comments
- Likes
- Payments
- Email service
- External search service
- Image-processing service
- Analytics pipeline beyond optional lightweight page analytics

---

## 5. High-level rendering model

### Server-rendered responsibilities

Use Server Components for:

- Root layout
- Homepage shell
- Exhibition introduction
- Loading panel data
- Static gallery markup where possible
- Individual panel route generation
- Metadata generation
- Structural navigation
- Non-interactive panel information

### Client-rendered responsibilities

Use Client Components only for:

- Search input
- Filter controls
- Dialog or overlay state
- Keyboard navigation inside the focused-detail experience
- Focus restoration
- URL synchronization that requires browser APIs
- Optional gallery transition behavior

Interactive components should receive serializable panel data or derived values from Server Components.

---

## 6. Routing architecture

### Canonical routes

```text
/
└── panels/
    └── [slug]/
        └── page.tsx
```

- `/` is the canonical exhibition and gallery route.
- `/panels/[slug]` is the canonical route for an individual panel.

### Gallery state

Search and filters are encoded in query parameters:

```text
/?q=ace
/?series=one-piece
/?theme=brotherhood
/?series=one-piece&theme=sacrifice
```

### Detail-overlay strategy

The initial implementation may use one of two approaches:

#### Phase 1: simple route plus client dialog

- The homepage opens a client-side detail overlay.
- The selected panel is reflected in the URL.
- Direct navigation to `/panels/[slug]` renders the standalone detail page.

#### Phase 2: optional intercepted route

If the interaction becomes difficult to maintain, Next.js intercepted and parallel routes may be introduced so that:

- Navigation from the gallery opens a modal.
- Direct navigation renders a full page.
- Browser back and forward behavior remains natural.

Do not introduce intercepted routes until the simpler implementation proves insufficient.

---

## 7. Content architecture

### Canonical data location

```text
src/data/panels.ts
```

### Types

```text
src/types/panel.ts
```

Recommended type:

```ts
export type PanelOrientation =
  | "portrait"
  | "landscape"
  | "square"
  | "spread";

export interface MangaPanel {
  id: string;
  slug: string;
  rank: number;

  title: string;
  series: string;
  creator: string;

  chapter: number | null;
  chapterTitle?: string;
  publicationYear?: number;
  arc?: string;

  characters: string[];
  themes: string[];

  commentary: string;
  featured?: boolean;

  image: {
    src: string;
    alt: string;
    width: number;
    height: number;
  };

  orientation: PanelOrientation;
}
```

### Data invariants

- `id` is unique.
- `slug` is unique and stable.
- `rank` is unique within the primary exhibition.
- Image width and height are positive integers.
- Every image has alt text.
- Every orientation is one of the supported values.
- UI components never duplicate panel metadata.
- Derived lists such as series, themes, and characters are generated from the canonical data.

### Query helpers

Use pure functions in:

```text
src/lib/panel-query.ts
```

Responsibilities:

- Find panel by slug
- Find panel index by slug
- Get previous and next panel
- Normalize search terms
- Filter panels
- Extract unique series
- Extract unique themes
- Validate query parameters

Pure query functions make behavior easy to test and keep filtering logic out of components.

---

## 8. Proposed repository structure

```text
manga-panel-gallery/
├── AGENTS.md
├── docs/
│   ├── product-spec.md
│   ├── architecture.md
│   └── visual-rubric.md
├── .agent/
│   ├── prd.json
│   ├── progress.md
│   └── iteration-prompt.md
├── public/
│   └── panels/
│       ├── one-piece-001.webp
│       ├── one-piece-002.webp
│       └── ...
├── scripts/
│   ├── verify.sh
│   └── agent-iteration.sh
├── src/
│   ├── app/
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── panels/
│   │       └── [slug]/
│   │           ├── page.tsx
│   │           ├── loading.tsx
│   │           └── not-found.tsx
│   ├── components/
│   │   ├── gallery/
│   │   │   ├── collection-progress.tsx
│   │   │   ├── exhibition-intro.tsx
│   │   │   ├── gallery-filters.tsx
│   │   │   ├── panel-detail.tsx
│   │   │   ├── panel-gallery.tsx
│   │   │   ├── panel-item.tsx
│   │   │   └── panel-navigation.tsx
│   │   └── ui/
│   ├── data/
│   │   └── panels.ts
│   ├── lib/
│   │   ├── panel-query.ts
│   │   └── utils.ts
│   └── types/
│       └── panel.ts
├── tests/
│   └── gallery.spec.ts
├── next.config.ts
├── package.json
├── playwright.config.ts
└── tsconfig.json
```

The exact file count may change, but responsibilities must remain separated.

---

## 9. Component responsibilities

### `exhibition-intro.tsx`

Responsible for:

- Exhibition title
- Curatorial statement
- Featured artwork
- Entry transition into the collection

It must not contain gallery filtering logic.

### `panel-gallery.tsx`

Responsible for:

- Receiving an ordered panel collection
- Rendering the editorial gallery composition
- Preserving logical DOM order
- Coordinating layout spans based on orientation or explicit layout metadata

It must not own the canonical panel data.

### `panel-item.tsx`

Responsible for:

- One panel’s image
- Restrained metadata
- Focus and hover states
- Link or trigger behavior
- Correct aspect-ratio handling

It must not add arbitrary outer margins that conflict with the parent composition.

### `panel-detail.tsx`

Responsible for:

- Focused artwork
- Complete metadata
- Commentary
- Close behavior
- Keyboard behavior
- Previous and next controls

It must accept data and callbacks rather than querying global state directly.

### `gallery-filters.tsx`

Responsible for:

- Search input
- Series filter
- Theme filter
- Clear action
- URL synchronization
- Mobile sheet presentation

It must not contain panel rendering markup.

### `collection-progress.tsx`

Responsible for:

- Displaying the selected panel position
- Formatting values such as `07 / 20`

### Route page components

Responsible for:

- Loading panel data
- Handling missing slugs
- Generating metadata
- Composing server and client components

---

## 10. Gallery layout architecture

The gallery must avoid a uniform card grid.

### Layout inputs

Layout may be derived from:

- Panel orientation
- Rank
- Featured status
- Optional explicit layout role

A future optional field may be added:

```ts
layout?: {
  columnSpan?: 1 | 2 | 3;
  emphasis?: "standard" | "featured" | "quiet";
  alignment?: "start" | "center" | "end";
}
```

Do not add this field until orientation-based layout is insufficient.

### DOM and CSS rules

- DOM order follows the intended reading sequence.
- CSS Grid may vary visual spans without changing semantic order.
- Avoid CSS reordering that produces confusing keyboard or screen-reader behavior.
- The parent gallery controls spacing.
- Panel items preserve their own image ratio.
- Spreads receive sufficient width to remain legible.
- Mobile defaults to sequential reading rather than complex masonry.

---

## 11. State architecture

### Server state

There is no remote mutable server state in the initial release.

### URL state

Use query parameters for:

- Search query
- Series filter
- Theme filter
- Optional selected panel when using an overlay

URL state must be shareable and compatible with browser history.

### Local client state

Use React state for:

- Open or closed overlay state
- Temporary input state when needed
- Focus restoration target
- Small presentation-only state

### Explicitly excluded

Do not install:

- Redux
- Zustand
- MobX
- TanStack Query
- Apollo
- SWR

These libraries may be reconsidered only if future requirements introduce complex remote or cross-page mutable state.

---

## 12. Image architecture

### Source files

```text
public/panels/
```

### Format

Preferred order:

1. AVIF when quality and tooling are acceptable
2. WebP
3. High-quality JPEG when necessary

### Rendering requirements

- Use `next/image`.
- Store intrinsic width and height in panel metadata.
- Use responsive `sizes`.
- Preserve natural aspect ratio.
- Do not apply global `object-cover`.
- Prioritize only the featured or initially visible image.
- Lazy-load non-critical images.
- Keep full-resolution source files reasonable.

Example:

```tsx
<Image
  src={panel.image.src}
  alt={panel.image.alt}
  width={panel.image.width}
  height={panel.image.height}
  sizes="(max-width: 768px) 100vw, (max-width: 1280px) 66vw, 50vw"
  className="h-auto w-full"
/>
```

### Missing-image behavior

During development:

- Render a stable aspect-ratio placeholder.
- Show enough identifying text to recognize the record.
- Do not allow a missing asset to collapse the gallery layout.

---

## 13. Styling architecture

### Global tokens

Define in `src/app/globals.css`:

- Paper background
- Deep paper background
- Primary ink
- Muted ink
- Border or rule color
- Accent color
- Content width
- Spacing scale where needed
- Motion duration and easing
- Typography variables

Example:

```css
:root {
  --paper: #f2efe7;
  --paper-deep: #e5dfd2;
  --ink: #151515;
  --ink-muted: #68645d;
  --rule: rgb(21 21 21 / 18%);
  --accent: #7a241f;
  --content-width: 92rem;
  --motion-fast: 160ms;
  --motion-standard: 280ms;
}
```

Exact values may evolve during visual development, but components must consume tokens instead of inventing unrelated colors.

### Tailwind responsibilities

Use Tailwind for:

- Grid and flex layout
- Responsive behavior
- Spacing
- Typography sizing
- Borders
- Visibility
- Basic transitions

### Custom CSS responsibilities

Use custom CSS for:

- Complex editorial grid rules
- Carefully tuned image reveals
- Decorative registration marks
- Motion that cannot be expressed clearly with utility classes

Avoid mixing multiple styling systems.

---

## 14. Accessibility architecture

### Semantic structure

- Use `header`, `main`, `section`, `nav`, `figure`, and `figcaption` appropriately.
- Use one page-level `h1`.
- Maintain logical heading hierarchy.

### Dialog behavior

The focused overlay must:

- Trap focus
- Have an accessible name
- Close with Escape
- Restore focus
- Prevent background interaction
- Expose close, previous, and next controls to assistive technology

### Keyboard behavior

- Tab order follows DOM order.
- Enter or Space opens a panel where appropriate.
- Left and right arrows navigate panels in the focused experience.
- Escape closes the overlay.
- Browser back returns to the previous state naturally.

### Motion

All non-essential animation must be disabled or simplified when the user prefers reduced motion.

---

## 15. Performance architecture

### Baseline choices

- Static or server-rendered content
- Server Components by default
- Minimal client boundaries
- Local images
- No remote data fetching
- No global state library
- No animation framework initially
- No heavy gallery dependency

### Static generation

Generate static panel routes from the canonical data:

```ts
export function generateStaticParams() {
  return panels.map((panel) => ({
    slug: panel.slug,
  }));
}
```

### Client bundle discipline

Client Components should be small and isolated. Do not mark the page or entire gallery as `"use client"` merely because one nested control is interactive.

### Scaling to 100 panels

One hundred metadata records can be loaded directly. Performance attention should focus on:

- Image loading
- Initial viewport prioritization
- DOM size
- Search and filter rendering
- Avoiding unnecessary re-renders

Virtualization is not required for 100 items unless real measurements indicate a problem.

---

## 16. SEO architecture

Each panel route uses `generateMetadata` based on the canonical record.

Metadata should include:

- Title
- Description
- Canonical route
- Open Graph fields
- Twitter card fields when appropriate
- Social preview image when legally and technically suitable

The homepage metadata describes the collection as a curated manga-panel exhibition.

---

## 17. Testing architecture

### Verification script

Create:

```text
scripts/verify.sh
```

It must run:

```bash
pnpm lint
pnpm exec tsc --noEmit
pnpm build
```

When Playwright is configured, it also runs:

```bash
pnpm exec playwright test
```

### Pure-function tests

Test query helpers for:

- Search normalization
- Series filtering
- Theme filtering
- Combined filters
- Unknown filter values
- Panel lookup
- Previous and next calculation
- First and last panel behavior

### Browser tests

Initial Playwright coverage:

- Homepage loads.
- Gallery renders expected records.
- Panel opens.
- Escape closes the overlay.
- Focus returns to the trigger.
- Left and right arrows navigate.
- Direct panel route loads.
- Search changes visible panels.
- Filter state is reflected in the URL.
- Browser back restores prior state.
- Mobile viewport has no horizontal overflow.
- Reduced-motion mode remains usable.

### Visual review

Automated testing does not replace manual review against `docs/visual-rubric.md`.

Required manual viewports:

- 320px
- 768px
- 1440px

---

## 18. Error and empty-state architecture

### Unknown panel route

Render a not-found page with:

- Clear message
- Return-to-gallery action
- No raw stack or implementation detail

### Empty search or filter result

Render:

- The active search or filters
- A clear message
- A clear-filters action
- No broken gallery shell

### Invalid query parameters

Ignore or normalize unsupported values rather than throwing.

### Missing metadata

Optional fields such as chapter title, arc, and publication year must be conditionally rendered.

---

## 19. Deployment architecture

### Source control

- Use feature branches.
- Commit one coherent task at a time.
- Do not let an agent push or merge automatically during early development.

### Vercel

- Connect the GitHub repository.
- Use preview deployments for visual review.
- Deploy the main branch to production.
- Keep environment configuration minimal because the MVP has no secrets or external services.

### Future migration

If a CMS or database is introduced later, environment variables and server-only data access must be added without exposing secrets to the client.

---

## 20. Agent-assisted development architecture

### Automatically discovered instructions

The root `AGENTS.md` is the primary repository instruction file.

It should direct agents to read:

- `docs/product-spec.md`
- `docs/architecture.md`
- `docs/visual-rubric.md`
- `.agent/prd.json`
- `.agent/progress.md`

### Task execution

`.agent/iteration-prompt.md` defines one iteration:

1. Read required context.
2. Select exactly one pending task.
3. Restate acceptance criteria.
4. Implement the smallest coherent change.
5. Run validation.
6. Review the diff.
7. Update task state.
8. Append progress.
9. Record only durable lessons in `AGENTS.md`.
10. Stop.

### Repository memory

- `AGENTS.md` stores durable rules.
- `.agent/prd.json` stores task state.
- `.agent/progress.md` stores chronological execution history.
- Git stores verified checkpoints.
- `scripts/verify.sh` provides an objective completion gate.

### Agent safety boundaries

Agents must not:

- Modify unrelated files.
- Add dependencies without justification.
- Introduce a backend, CMS, or global state library without an approved architecture change.
- Mark tasks complete while validation fails.
- Push, merge, or deploy automatically during early development.
- Add animation before the static composition is approved.
- Duplicate panel metadata inside components.

---

## 21. Architecture decision log

### ADR-001: Use a single Next.js application

**Decision:** Use one Next.js App Router repository.

**Reason:** The product benefits from static generation, routes, image optimization, SEO, and lightweight interactivity without needing separate services.

### ADR-002: Use typed local data initially

**Decision:** Store panel records in TypeScript.

**Reason:** The initial collection is small, content changes are owner-controlled, and this avoids unnecessary infrastructure.

### ADR-003: Avoid global state management

**Decision:** Use URL state and local React state.

**Reason:** There is no complex remote or shared mutable state in the MVP.

### ADR-004: Preserve artwork instead of cropping

**Decision:** Render natural aspect ratios by default.

**Reason:** Cropping can remove meaningful manga composition, dialogue, and character expressions.

### ADR-005: Use selective UI primitives

**Decision:** Use shadcn/ui only for accessible interaction primitives.

**Reason:** The project needs robust dialog and sheet behavior but must avoid generic dashboard visuals.

### ADR-006: Delay complex routing overlays

**Decision:** Begin with a simple detail route and client overlay.

**Reason:** Intercepted routes add complexity and should be introduced only if required for correct browser behavior.

### ADR-007: Keep the client boundary narrow

**Decision:** Use Server Components by default.

**Reason:** The site is content-heavy and interaction-light, so large client bundles are unnecessary.

---

## 22. Architecture change criteria

A proposed architecture change should be accepted only when:

- A documented product requirement cannot be met cleanly with the existing architecture.
- The current solution has a measured performance or maintenance problem.
- The new dependency or service has a clear owner and purpose.
- Migration and rollback costs are understood.
- Tests and documentation are updated.
- The change does not compromise artwork priority, accessibility, or content portability.

Examples that may justify future changes:

- A non-technical editor must manage hundreds of records.
- Multiple curators require drafts and permissions.
- User accounts and saved collections become core requirements.
- Search grows beyond what local filtering can support.
- Image processing becomes too burdensome to perform manually.
