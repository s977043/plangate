#!/bin/sh
# apply-claude-settings.sh — settings wiring 契約適用（TASK-0080 S1a）
#
# `.claude/settings.json` を settings wiring 契約
# （docs/ai/settings-wiring-contract.md / .claude/settings.example.json）に
# 整合させる。**ユーザーが実行**する（AI は self-mod ガードで
# .claude/settings.json を編集できないため）。冪等（複数回実行安全）。
#
# 使い方:  sh scripts/apply-claude-settings.sh [--dry-run]
#
# 動作: .claude/settings.json が無ければ settings.example.json をコピー。
#       あれば EH-3 の PLANGATE_HOOK_FILE と EH-9 wiring の不足のみ補う。
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SJ="$ROOT/.claude/settings.json"
EX="$ROOT/.claude/settings.example.json"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1

[ -f "$EX" ] || { printf 'error: %s not found\n' "$EX" >&2; exit 2; }

if [ ! -f "$SJ" ]; then
  printf '[apply] .claude/settings.json 不在 → settings.example.json をコピー\n'
  [ "$DRY" -eq 1 ] || cp "$EX" "$SJ"
  printf '[apply] done (copied)\n'; exit 0
fi

need_file=0; need_eh9=0
grep -q 'check-plan-hash.sh ${PLANGATE_HOOK_TASK:-} ${PLANGATE_HOOK_FILE:-}' "$SJ" || need_file=1
grep -q 'check-delegation-commit-boundary.sh' "$SJ" || need_eh9=1

if [ "$need_file" -eq 0 ] && [ "$need_eh9" -eq 0 ]; then
  printf '[apply] 既に契約準拠（変更なし）\n'; exit 0
fi

printf '[apply] 不足: EH-3 PLANGATE_HOOK_FILE=%s / EH-9=%s\n' "$need_file" "$need_eh9"
if [ "$DRY" -eq 1 ]; then printf '[apply] --dry-run: 変更なし\n'; exit 0; fi

# EH-3 に PLANGATE_HOOK_FILE 追加（idempotent: 既適用ならスキップ済）
if [ "$need_file" -eq 1 ]; then
  tmp=$(mktemp)
  sed 's#check-plan-hash.sh ${PLANGATE_HOOK_TASK:-}\(\\?\)"#check-plan-hash.sh ${PLANGATE_HOOK_TASK:-} ${PLANGATE_HOOK_FILE:-}\1"#' "$SJ" >"$tmp" && mv "$tmp" "$SJ"
fi
# EH-9 不足時は settings.example.json の EH-9 ブロックを案内（構造マージは
# ユーザー判断が安全。自動 JSON マージは破壊リスクのため手動を促す）
if [ "$need_eh9" -eq 1 ]; then
  printf '[apply] EH-9 wiring 不足。settings.example.json の EH-9 ブロックを\n'
  printf '        .claude/settings.json の PreToolUse 配列へ手動追加してください\n'
  printf '        （構造マージは破壊回避のため手動。doctor --check-settings で再検証）\n'
fi
python3 -c "import json,sys; json.load(open('$SJ'))" && printf '[apply] JSON valid\n'
printf '[apply] done\n'
