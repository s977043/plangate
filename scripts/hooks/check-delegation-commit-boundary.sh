#!/bin/sh
# check-delegation-commit-boundary.sh — Hook EH-9: 委譲 commit/push 境界検知
#
# Claude Code PreToolUse hook（Bash の前に呼ばれる想定）または CLI。
# 委譲先サブエージェントが「commit/push しない」境界を破って git commit /
# git push を実行しようとした場合に決定論的に検出する（#239 問題2 / F2）。
#
# 入力:
#   PLANGATE_DELEGATION_NOCOMMIT  "1" のとき現コンテキストは commit/push 禁止
#                                 （親が委譲時に宣言。todo.md メタ
#                                  delegation_commit_boundary: no-commit に対応）
#   PLANGATE_HOOK_CMD             検査対象コマンド文字列（env）
#   （未指定時は stdin JSON tool_input.command を読む）
#
# Modes:
#   default                       warning（continue:true）
#   PLANGATE_HOOK_STRICT=1        違反時 continue:false（block）
#   PLANGATE_BYPASS_HOOK=1        常時 continue:true
#
# 監査: docs/working/_audit/hook-events.log
#
# F2 / TASK-0073 / 関連: core-contract §5-bis, contracts/execute.md

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
WORKING_DIR="$REPO_ROOT/docs/working"
AUDIT_LOG="$WORKING_DIR/_audit/hook-events.log"

emit_judgment() {
  decision=$1
  reason=${2:-}
  if [ "$decision" = "block" ]; then
    printf '{"continue":false,"stopReason":"%s"}\n' "$reason"
  else
    printf '{"continue":true}\n'
  fi
}

log_event() {
  level=$1
  msg=$2
  mkdir -p "$(dirname "$AUDIT_LOG")"
  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  printf '%s\t%s\tcheck-delegation-commit-boundary\t%s\t%s\n' \
    "$ts" "$level" "${PLANGATE_HOOK_TASK:--}" "$msg" >>"$AUDIT_LOG"
}

# bypass（既存 hook 慣行: bypass > strict > 通常）
if [ "${PLANGATE_BYPASS_HOOK:-0}" = "1" ]; then
  log_event "BYPASS" "PLANGATE_BYPASS_HOOK=1 set"
  emit_judgment "allow"
  exit 0
fi

# 境界宣言が無ければ従来動作（誤検出ゼロ・未宣言は介入しない）
if [ "${PLANGATE_DELEGATION_NOCOMMIT:-0}" != "1" ]; then
  emit_judgment "allow"
  exit 0
fi

# 対象コマンド解決: env > stdin JSON tool_input.command
cmd=${PLANGATE_HOOK_CMD:-}
if [ -z "$cmd" ] && [ ! -t 0 ]; then
  _stdin=$(cat 2>/dev/null || true)
  if [ -n "$_stdin" ]; then
    if command -v jq >/dev/null 2>&1; then
      cmd=$(printf '%s' "$_stdin" | jq -r '.tool_input.command // .command // empty' 2>/dev/null | head -1)
    fi
    if [ -z "$cmd" ]; then
      cmd=$(printf '%s' "$_stdin" \
        | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' \
        | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
    fi
  fi
fi

# git commit / git push を検出（決定論。委譲境界 no-commit 下のみ到達）
case "$cmd" in
  *"git commit"*|*"git push"*|*"git "*"commit"*|*"git "*"push"*)
    reason="delegated context declared no-commit but attempts git commit/push: $cmd"
    log_event "VIOLATION" "$reason"
    if [ "${PLANGATE_HOOK_STRICT:-0}" = "1" ]; then
      emit_judgment "block" "EH-9: 委譲境界違反 — 委譲先は commit/push しない（完了フェーズは親が実施）"
      exit 0
    fi
    printf '[Hook EH-9 WARNING] 委譲境界違反の可能性: %s\n' "$cmd" >&2
    emit_judgment "allow"
    exit 0
    ;;
esac

emit_judgment "allow"
exit 0
