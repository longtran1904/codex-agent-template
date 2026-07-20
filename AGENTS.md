# Manga Panel Gallery Agent Handbook

## Required project context

Before planning or modifying code, read:

1. `docs/product-spec.md`
2. `docs/visual-rubric.md`
3. `docs/architecture.md`
4. `.agent/prd.json`
5. `.agent/progress.md`

When instructed to execute an iteration, also read and follow:

- `.agent/iteration-prompt.md`

Treat these files as authoritative. If they conflict:

1. `AGENTS.md`
2. `docs/product-spec.md`
3. `.agent/prd.json`
4. `.agent/progress.md`

Do not mark a task complete unless its acceptance criteria and validation
commands pass.

## Product invariants

- The panel artwork is always the dominant visual element.
- The experience should resemble a curated exhibition, not a dashboard.
- The collection must scale from 20 to at least 100 entries.
- Panel metadata must come from one canonical data source.
- Mobile should feel like reading a carefully typeset manga volume.

## Visual conventions

- Use a warm paper background and near-black ink.
- Prefer asymmetric editorial composition.
- Do not create a uniform grid of identical cards.
- Use thin rules, understated labels, and generous negative space.
- Motion must be restrained and respect reduced-motion preferences.
- Do not introduce decorative gradients, glassmorphism, or SaaS styling.

## Technical conventions

- Next.js App Router and TypeScript.
- Server Components by default.
- Client Components only for genuine interaction.
- Use next/image for local panel artwork.
- Keep filtering logic outside visual components.
- Avoid new dependencies unless they materially reduce complexity.

## Required validation (Only required when agent is in task execution mode)

Don't apply validation steps when the prompt involves improving agent loop, agent architecture
Before reporting a task complete:

1. Run `./scripts/verify.sh`.
2. Check for horizontal overflow at 320px.
3. Verify keyboard navigation where relevant.
4. Review the diff for unrelated changes.
5. Confirm every acceptance criterion explicitly.

## Known gotchas

- Portrait, landscape, square, and double-page spreads must be tested.
- Do not hard-code panel metadata inside UI components.
- The selected panel and active filters should eventually be URL-addressable.
- After every agent run, update README.md on how to run the webapp

## Durable learnings

Add only reusable discoveries here. Do not add task-by-task progress.