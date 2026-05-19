#!/bin/sh
# cursor-adapter.sh — Bridge PlanGate Claude hooks to Cursor preToolUse JSON
#
# Usage: cursor-adapter.sh <check-script-basename>
#   Example: cursor-adapter.sh check-c3-approval.sh
#
# Reads Cursor hook event JSON from stdin, sets PLANGATE_HOOK_FILE when detectable,
# runs the PlanGate hook under scripts/hooks/, translates continue/stopReason to permission.

set -eu

HOOK_NAME=${1:-}
if [ -z "$HOOK_NAME" ]; then
  printf '{"permission":"allow","agent_message":"cursor-adapter: missing hook name"}\n'
  exit 0
fi

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
HOOK_SCRIPT="$REPO_ROOT/scripts/hooks/$HOOK_NAME"

if [ ! -f "$HOOK_SCRIPT" ]; then
  printf '{"permission":"deny","user_message":"PlanGate hook not found","agent_message":"missing %s"}\n' "$HOOK_NAME"
  exit 2
fi

INPUT=$(cat)

# Extract file path from common Cursor / tool payload shapes
extract_path() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '
      .file_path // .path //
      .tool_input.file_path // .tool_input.path //
      .tool_input.filePath // .toolInput.filePath //
      .arguments.file_path // .arguments.path //
      empty
    ' 2>/dev/null <<EOF
$INPUT
EOF
    return
  fi
  printf '%s' "$INPUT" | python3 -c '
import json, sys
raw = sys.stdin.read()
try:
    d = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    sys.exit(0)
for key in ("file_path", "path"):
    v = d.get(key)
    if v:
        print(v); sys.exit(0)
ti = d.get("tool_input") or d.get("toolInput") or {}
for key in ("file_path", "path", "filePath"):
    v = ti.get(key)
    if v:
        print(v); sys.exit(0)
args = d.get("arguments") or {}
for key in ("file_path", "path"):
    v = args.get(key)
    if v:
        print(v); sys.exit(0)
'
}

FILE_PATH=$(extract_path || true)

if [ -n "$FILE_PATH" ]; then
  export PLANGATE_HOOK_FILE=$FILE_PATH
  case "$FILE_PATH" in
    *docs/working/TASK-*/*)
      _task=$(printf '%s\n' "$FILE_PATH" | sed -n 's|.*docs/working/\(TASK-[^/]*\)/.*|\1|p')
      if [ -n "$_task" ] && [ -z "${PLANGATE_HOOK_TASK:-}" ]; then
        export PLANGATE_HOOK_TASK=$_task
      fi
      ;;
  esac
fi

# Run Claude-format hook; capture last JSON line on stdout
HOOK_OUT=$(sh "$HOOK_SCRIPT" 2>/dev/null | tail -n 1) || HOOK_OUT='{"continue":true}'

CONTINUE=$(printf '%s\n' "$HOOK_OUT" | sed -n 's/.*"continue"[[:space:]]*:[[:space:]]*\([^,}]*\).*/\1/p' | tr -d ' ')
STOP=$(printf '%s\n' "$HOOK_OUT" | sed -n 's/.*"stopReason"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

case "$CONTINUE" in
  false)
    REASON=${STOP:-PlanGate hook blocked this edit}
    printf '{"permission":"deny","user_message":"%s","agent_message":"%s (via %s)"}\n' \
      "$REASON" "$REASON" "$HOOK_NAME"
    exit 0
    ;;
  *)
    printf '{"permission":"allow"}\n'
    exit 0
    ;;
esac
