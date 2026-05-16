# settings wiring 契約（正本 / TASK-0080 S1）

> `.claude/settings.json` が満たすべき PreToolUse hook wiring の**正本**。
> `bin/plangate doctor --check-settings` がこの契約と実体を突合する。
> 適用は `scripts/apply-claude-settings.sh`（**ユーザー実行**。AI は
> self-mod ガードで `.claude/settings.json` を編集できないため）。

## 必須 PreToolUse hooks（matcher: Edit|Write 系）

| Hook | command（必須トークン） |
|------|------------------------|
| EH-1 plan-exists | `scripts/hooks/check-plan-exists.sh` |
| EH-2 c3-approval | `scripts/hooks/check-c3-approval.sh` |
| EH-3 plan-hash | `scripts/hooks/check-plan-hash.sh ${PLANGATE_HOOK_TASK:-} ${PLANGATE_HOOK_FILE:-}` |
| EH-6 forbidden-files | `scripts/hooks/check-forbidden-files.sh` |
| EH-9 delegation-commit-boundary | `scripts/hooks/check-delegation-commit-boundary.sh` |

### 契約ポイント

- **EH-3 は `${PLANGATE_HOOK_FILE:-}` を第2引数に含む**（P4(d) ファイルパス
  感応 SKIP / TASK-0070 AC-8。これが本セッション通底の未適用 wiring）。
- **EH-9 wiring が存在する**（委譲 commit 境界 / TASK-0073）。
- 上記トークンが `.claude/settings.json` の PreToolUse command 群に
  すべて存在すれば `doctor --check-settings` PASS。1 つでも欠落で FAIL。

## 検証・適用

- 検証: `bin/plangate doctor --check-settings`（未適用箇所を列挙し非0）
- 適用: `sh scripts/apply-claude-settings.sh`（冪等。ユーザーが実行）
- CI: settings drift check（required）が契約逸脱を fail させる

## 不変

- `.claude/settings.json` の AI 直接編集は禁止（self-mod ガード・恒久制約）。
  AI は契約定義・検証・適用 script 提供まで。適用は人間。
- 本契約の追加 hook は settings.example.json と整合させること。
