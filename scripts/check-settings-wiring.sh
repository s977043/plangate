#!/bin/sh
# check-settings-wiring.sh — settings wiring 契約 検証（TASK-0080 S1b）
#
# 正本: docs/ai/settings-wiring-contract.md
# 必須トークン（PreToolUse command 群に全て存在で PASS）:
#   - check-plan-exists.sh / check-c3-approval.sh / check-forbidden-files.sh
#   - check-plan-hash.sh ... ${PLANGATE_HOOK_FILE:-}   (P4(d)/AC-8)
#   - check-delegation-commit-boundary.sh              (EH-9/TASK-0073)
#
# 使い方:
#   sh scripts/check-settings-wiring.sh [--target user|example]
#     user(default): .claude/settings.json を検証（doctor / task-lock 用）
#     example:        .claude/settings.example.json を検証（CI drift 用）
#
# exit 0 = 契約準拠 / exit 1 = 逸脱（不足を列挙）/ exit 2 = 対象不在
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=user
case "${1:-}" in
  --target) target=${2:-user} ;;
  --target=*) target=${1#--target=} ;;
esac
case "$target" in
  user)    F="$ROOT/.claude/settings.json" ;;
  example) F="$ROOT/.claude/settings.example.json" ;;
  *) printf 'error: --target must be user|example\n' >&2; exit 2 ;;
esac

if [ ! -f "$F" ]; then
  if [ "$target" = user ]; then
    printf '[check-settings] FAIL: %s 不在（settings 未適用）\n' "$F" >&2
    printf '  → sh scripts/apply-claude-settings.sh を実行してください\n' >&2
    exit 1
  fi
  printf '[check-settings] FAIL: %s 不在\n' "$F" >&2; exit 2
fi

miss=0
need() {
  if ! grep -q -- "$1" "$F"; then
    printf '[check-settings] 不足: %s\n' "$2" >&2
    miss=1
  fi
}
need 'check-plan-exists.sh' 'EH-1 plan-exists'
need 'check-c3-approval.sh' 'EH-2 c3-approval'
need 'check-forbidden-files.sh' 'EH-6 forbidden-files'
need 'check-plan-hash.sh' 'EH-3 plan-hash'
need '${PLANGATE_HOOK_FILE:-}' 'EH-3 の PLANGATE_HOOK_FILE 引数（P4(d)/AC-8）'
need 'check-delegation-commit-boundary.sh' 'EH-9 delegation-commit-boundary（TASK-0073）'

if [ "$miss" -eq 1 ]; then
  printf '[check-settings] FAIL: settings wiring 契約 逸脱（target=%s）\n' "$target" >&2
  printf '  契約: docs/ai/settings-wiring-contract.md / 適用: scripts/apply-claude-settings.sh\n' >&2
  exit 1
fi
printf '[check-settings] PASS: settings wiring 契約準拠（target=%s）\n' "$target"
exit 0
