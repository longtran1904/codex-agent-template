#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRD_FILE="$ROOT_DIR/.agent/prd.json"
PROMPT_FILE="$ROOT_DIR/.agent/iteration-prompt.md"
RUNS_DIR="$ROOT_DIR/.agent/runs"
LOCK_DIR="$ROOT_DIR/.agent/.loop.lock"

MAX_ITERATIONS="${AGENT_LOOP_MAX_ITERATIONS:-10}"
MAX_TASK_ATTEMPTS="${AGENT_TASK_MAX_ATTEMPTS:-3}"
CODEX_BIN="${CODEX_BIN:-codex}"
EXTRA_CODEX_ARGS=()
DRY_RUN=0

is_loop_option() {
  case "$1" in
    --max-iterations|--max-task-attempts|--model|--search|--dry-run|-h|--help)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

usage() {
  printf '%s\n' \
    "Usage: scripts/agent-loop.sh [options] [-- extra-codex-args]" \
    "" \
    "Runs a serial Codex orchestration loop. Each pass starts one fresh" \
    "$CODEX_BIN exec session and asks it to complete exactly one pending task." \
    "" \
    "Options:" \
    "  --max-iterations N      Stop after N spawned agents. Default: 10" \
    "  --max-task-attempts N   Treat pending tasks with N attempts as blocked. Default: 3" \
    "  --model MODEL           Pass a model selection through to Codex" \
    "  --search                Enable Codex web search for spawned agents" \
    "  --dry-run               Print the next task and exit without spawning Codex" \
    "  -h, --help              Show this help" \
    "" \
    "Environment:" \
    "  AGENT_LOOP_MAX_ITERATIONS" \
    "  AGENT_TASK_MAX_ATTEMPTS" \
    "  CODEX_BIN                 Codex-compatible binary to run. Default: codex"
}

if [ "${1:-}" = "--" ] && [ "$#" -gt 1 ] && is_loop_option "$2"; then
  shift
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --max-iterations)
      MAX_ITERATIONS="${2:-}"
      shift 2
      ;;
    --max-task-attempts)
      MAX_TASK_ATTEMPTS="${2:-}"
      shift 2
      ;;
    --model)
      if [ -z "${2:-}" ]; then
        printf '%s\n' '--model requires a value.' >&2
        exit 64
      fi
      EXTRA_CODEX_ARGS+=("--model" "$2")
      shift 2
      ;;
    --search)
      EXTRA_CODEX_ARGS+=("--search")
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      EXTRA_CODEX_ARGS+=("$@")
      break
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

case "$MAX_ITERATIONS" in
  ''|*[!0-9]*)
    printf 'MAX_ITERATIONS must be a positive integer.\n' >&2
    exit 64
    ;;
esac

case "$MAX_TASK_ATTEMPTS" in
  ''|*[!0-9]*)
    printf 'MAX_TASK_ATTEMPTS must be a positive integer.\n' >&2
    exit 64
    ;;
esac

if [ "$MAX_ITERATIONS" -lt 1 ]; then
  printf 'MAX_ITERATIONS must be at least 1.\n' >&2
  exit 64
fi

if [ "$MAX_TASK_ATTEMPTS" -lt 1 ]; then
  printf 'MAX_TASK_ATTEMPTS must be at least 1.\n' >&2
  exit 64
fi

if ! command -v "$CODEX_BIN" >/dev/null 2>&1; then
  printf '%s was not found on PATH. Set CODEX_BIN to an executable Codex-compatible binary.\n' "$CODEX_BIN" >&2
  exit 127
fi

if [ ! -f "$PRD_FILE" ]; then
  printf 'Missing task state: %s\n' "$PRD_FILE" >&2
  exit 66
fi

if [ ! -f "$PROMPT_FILE" ]; then
  printf 'Missing iteration prompt: %s\n' "$PROMPT_FILE" >&2
  exit 66
fi

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  printf 'Another agent loop appears to be running: %s\n' "$LOCK_DIR" >&2
  exit 75
fi

cleanup() {
  rm -f "$LOCK_DIR/pid"
  rmdir "$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

printf '%s\n' "$$" > "$LOCK_DIR/pid"
mkdir -p "$RUNS_DIR"
cd "$ROOT_DIR"

actionable_count() {
  node -e '
const fs = require("fs");
const maxAttempts = Number(process.argv[1]);
const prd = JSON.parse(fs.readFileSync(".agent/prd.json", "utf8"));
const count = prd.tasks.filter((task) =>
  task.status === "pending" && Number(task.attempts || 0) < maxAttempts
).length;
console.log(count);
' "$MAX_TASK_ATTEMPTS"
}

next_task_summary() {
  node -e '
const fs = require("fs");
const maxAttempts = Number(process.argv[1]);
const prd = JSON.parse(fs.readFileSync(".agent/prd.json", "utf8"));
const task = prd.tasks.find((candidate) =>
  candidate.status === "pending" && Number(candidate.attempts || 0) < maxAttempts
);
if (!task) process.exit(1);
console.log(`${task.id}: ${task.title} (attempts ${Number(task.attempts || 0)}/${maxAttempts})`);
' "$MAX_TASK_ATTEMPTS"
}

task_state_signature() {
  node -e '
const fs = require("fs");
const prd = JSON.parse(fs.readFileSync(".agent/prd.json", "utf8"));
console.log(JSON.stringify(prd.tasks.map((task) => ({
  id: task.id,
  status: task.status,
  attempts: Number(task.attempts || 0)
}))));
'
}

task_status_summary() {
  node -e '
const fs = require("fs");
const maxAttempts = Number(process.argv[1]);
const prd = JSON.parse(fs.readFileSync(".agent/prd.json", "utf8"));
const summary = prd.tasks.reduce((acc, task) => {
  if (task.status === "complete") acc.complete += 1;
  else if (task.status === "pending" && Number(task.attempts || 0) >= maxAttempts) acc.attemptLimited += 1;
  else if (task.status === "pending") acc.pending += 1;
  else acc.other += 1;
  return acc;
}, { complete: 0, pending: 0, attemptLimited: 0, other: 0 });
console.log(`${summary.complete} complete, ${summary.pending} actionable pending, ${summary.attemptLimited} at attempt limit, ${summary.other} other`);
' "$MAX_TASK_ATTEMPTS"
}

iteration=1

if [ "$DRY_RUN" -eq 1 ]; then
  pending="$(actionable_count)"

  if [ "$pending" -eq 0 ]; then
    printf 'No actionable pending tasks remain (%s).\n' "$(task_status_summary)"
  else
    printf 'Next task: %s\n' "$(next_task_summary)"
    printf 'Current task state: %s\n' "$(task_status_summary)"
  fi

  exit 0
fi

while [ "$iteration" -le "$MAX_ITERATIONS" ]; do
  pending="$(actionable_count)"

  if [ "$pending" -eq 0 ]; then
    printf 'No actionable pending tasks remain (%s).\n' "$(task_status_summary)"
    exit 0
  fi

  task_summary="$(next_task_summary)"
  run_id="$(date -u '+%Y%m%dT%H%M%SZ')-$(printf '%03d' "$iteration")"
  transcript="$RUNS_DIR/$run_id.log"
  final_message="$RUNS_DIR/$run_id.final.md"
  before_signature="$(task_state_signature)"

  printf '==> Iteration %d/%d: %s\n' "$iteration" "$MAX_ITERATIONS" "$task_summary"
  printf '==> Codex binary: %s\n' "$CODEX_BIN"
  printf '==> Transcript: %s\n' "$transcript"

  prompt="You are a fresh Codex agent spawned by scripts/agent-loop.sh.

Execute exactly one project iteration for this repository.

Follow AGENTS.md and .agent/iteration-prompt.md exactly. Select one pending task from .agent/prd.json, restate its acceptance criteria, implement only that task, run the required validation, update .agent/prd.json and .agent/progress.md only according to the iteration rules, update project documentation only when the task changes documented setup, usage, behavior, or architecture, review the diff, and stop after that single task.

Do not continue to a second task in this session."

  set +e
  "$CODEX_BIN" exec \
    -C "$ROOT_DIR" \
    --sandbox workspace-write \
    ${EXTRA_CODEX_ARGS[@]+"${EXTRA_CODEX_ARGS[@]}"} \
    -o "$final_message" \
    "$prompt" 2>&1 | tee "$transcript"
  codex_status="${PIPESTATUS[0]}"
  set -e

  if [ "$codex_status" -ne 0 ]; then
    printf 'Codex iteration failed with exit code %d. See %s\n' "$codex_status" "$transcript" >&2
    exit "$codex_status"
  fi

  after_signature="$(task_state_signature)"
  if [ "$before_signature" = "$after_signature" ]; then
    printf 'Task state did not change after the agent run; stopping to avoid a stalled loop.\n' >&2
    printf 'See %s\n' "$transcript" >&2
    exit 70
  fi

  printf '==> Iteration %d complete (%s).\n' "$iteration" "$(task_status_summary)"
  iteration=$((iteration + 1))
done

printf 'Reached max iterations (%d). Current task state: %s\n' "$MAX_ITERATIONS" "$(task_status_summary)"
