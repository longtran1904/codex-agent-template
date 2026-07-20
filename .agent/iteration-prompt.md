You are executing one iteration of the Manga Panel Gallery project.

Read these files first:

- docs/product-spec.md
- docs/visual-rubric.md
- docs/architecture.md
- .agent/prd.json
- The final 80 lines of .agent/progress.md

Then:

1. Select exactly one pending task from prd.json.
2. Restate its acceptance criteria before editing.
3. Inspect the existing implementation and Git history relevant to that task.
4. Implement the smallest coherent change that satisfies the task.
5. Do not modify files outside allowedAreas unless technically necessary.
6. Do not install dependencies unless the task requires one.
7. Run every validation command specified by the task.
8. Review the resulting diff for unrelated changes.
9. Evaluate visual tasks using docs/visual-rubric.md.
10. Mark the task complete only if every acceptance criterion passes.
11. Append a concise entry to .agent/progress.md.
12. Add something to AGENTS.md only when it is a durable, reusable discovery.
13. Stop after this single task.

When blocked:

- Do not claim completion.
- Increment the task's attempts count.
- Record the exact blocker and command output in progress.md.
- Propose the smallest next corrective action.