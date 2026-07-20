# Project Agent Handbook

This file defines the default operating rules for coding agents working in this
repository. Keep it generic so it can be copied into new projects without
carrying product-specific assumptions.

## Required project context

Before planning or modifying code, read the project context files that exist in
this repository. Prefer this order:

1. `docs/product-spec.md`
2. `docs/visual-rubric.md`
3. `docs/architecture.md`
4. `.agent/prd.json`
5. `.agent/progress.md`

When instructed to execute an iteration, also read and follow:

- `.agent/iteration-prompt.md`

Treat these files as authoritative. If they conflict, use this precedence:

1. `AGENTS.md`
2. `docs/product-spec.md`
3. `docs/architecture.md`
4. `.agent/prd.json`
5. `.agent/progress.md`

If a listed file is missing in a new project, continue with the available
context and note the gap before making assumptions that affect implementation.

## Product invariants

- The product requirements in `docs/product-spec.md` define the user experience,
  scope, and non-goals.
- Data and behavior should have one clear source of truth.
- The implementation should scale to the product sizes and workflows described
  in the project specification.
- User-facing behavior should be accessible, responsive, and resilient to empty,
  loading, and error states.
- Do not hard-code domain data inside visual components when a canonical data
  source or API boundary is available.

## Visual conventions

- Follow `docs/visual-rubric.md` when visual quality is part of the task.
- Preserve the visual language already established by the project.
- Prefer clear hierarchy, spacing, contrast, and restrained motion over
  decorative effects.
- Motion must be purposeful and respect reduced-motion preferences.
- Avoid introducing unrelated design trends, decorative gradients,
  glassmorphism, or dashboard styling unless the product explicitly calls for
  them.
- Verify that text, controls, and media do not overlap or overflow at supported
  viewport widths.

## Technical conventions

- Follow the architecture and stack decisions in `docs/architecture.md`.
- Prefer existing project patterns, helpers, components, and conventions before
  adding new abstractions.
- Keep business logic outside purely visual components.
- Keep changes scoped to the task and avoid unrelated refactors.
- Avoid new dependencies unless they materially reduce complexity or are
  required by the task.
- Use typed interfaces and structured parsing for structured data.
- Preserve accessibility semantics, keyboard behavior, and focus management for
  interactive features.

## Required validation

Only apply validation steps when the agent is executing a product or code task.
Do not apply them to prompts that only improve the agent loop, templates, or
agent architecture unless the prompt explicitly asks for validation.

Before reporting a task complete:

1. Run the validation commands specified by the task or project documentation.
2. If a verification script exists, run it unless the task explicitly says not
   to.
3. Check responsive behavior at the smallest supported viewport, including
   horizontal overflow.
4. Verify keyboard navigation and focus behavior where relevant.
5. Review the diff for unrelated changes.
6. Confirm every acceptance criterion explicitly.

If validation cannot run because of an environment limitation, record the exact
command and blocker, and do not mark the task complete unless the project
instructions allow an alternative validation path.

## Iteration workflow

When executing a task from `.agent/prd.json`:

1. Select exactly one pending task unless the user requests otherwise.
2. Restate the task acceptance criteria before editing.
3. Inspect the current implementation and relevant history.
4. Implement the smallest coherent change that satisfies the task.
5. Stay within the task's allowed areas unless a broader change is technically
   necessary.
6. Run the task's validation commands.
7. Review the resulting diff.
8. Update `.agent/progress.md` with a concise result or blocker.
9. Update task status only when all acceptance criteria and validation commands
   pass.
10. Stop after that task.

When blocked:

- Do not claim completion.
- Record the blocker with command output or observable evidence.
- Increment the task attempt count if the project process uses attempts.
- Propose the smallest next corrective action.

## Documentation upkeep

- Keep `README.md` accurate for how to install, run, validate, and use the
  project.
- Update project docs when implementation decisions change documented behavior
  or architecture.
- Do not add task-by-task progress to this file.

## Known gotchas

- Test the shape and edge cases that matter for the current project, including
  unusual data, empty states, long text, narrow screens, and direct links.
- URL-addressable state should remain stable when the product requires sharing
  or browser history support.
- Generated or user-provided assets should have clear ownership, paths, and
  metadata.
- Be careful with dirty worktrees: preserve user changes and avoid reverting
  unrelated files.

## Durable learnings

Add only reusable discoveries here. Do not add task-by-task progress.
