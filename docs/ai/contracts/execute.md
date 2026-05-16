# Phase Contract: execute

> [`prompt-assembly.md`](../prompt-assembly.md) の phase_contract / 7 phase の 1 つ

## Goal

承認済 plan / todo / test-cases に従って実装する。todo の各タスクを 2-5 分粒度で順次実行。

## Success criteria

- todo の全 🤖 Agent タスクが完了
- 各タスクで test 実行（TDD: RED → GREEN → REFACTOR）
- scope 外ファイルへの編集ゼロ（[`tool-policy.md`](../tool-policy.md) allowed_files 準拠）
- Iron Law: `NO SCOPE CHANGE WITHOUT USER APPROVAL`

## exec 前プリフライト（F2 / TASK-0073）

exec 開始前に以下を決定論的に検証する（自然言語依存にしない）。
不整合は exec 前に停止 or 明示降格する:

1. **git 操作主体**: 委譲タスクは todo.md のメタフィールド
   `delegation_commit_boundary: no-commit` で commit/push 境界を宣言できる。
   宣言時、委譲先サブエージェントは commit/push しない（完了フェーズは親が実施）。
2. **認証整合（三点）**: `gh auth`（active account）/ `git config user` /
   `git remote`（push 先）が期待と一致するか。不一致は exec 前に検出。
3. **委譲 commit 境界の機械検出**: 上記宣言下の git commit/push は
   **EH-9**（[`hook-enforcement.md`](../hook-enforcement.md)）が PreToolUse で
   決定論検出（strict=block / default=warn / bypass・未宣言=従来動作）。
4. **exec 後検証（二段の保険）**: exec 完了時、委譲境界宣言タスクで
   予期しない commit が無いことを検証ステップで再確認する。

> F1（TASK-0072 / PR #245）の capability preflight（`Agent`/`Task` 可否）と
> 同一プリフライト層に属する。#245 マージ後、core-contract §5-bis 配下の
> 単一プリフライト・ゲートへ統合する（重複定義を排除。handoff 参照）。

## Stop rules

- scope 外作業が必要と判明 → 即停止、ユーザー確認
- test FAIL の root cause が不明 → 停止（Iron Law #6: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION）
- plan_hash 改竄検知 → block（[`hook-enforcement.md`](../hook-enforcement.md) EH-3）
- 承認なし production code 編集要求 → block（EH-1）
- 委譲境界 `no-commit` 宣言下で commit/push 試行 → block（EH-9, strict 時）
- 認証三点（gh auth / git config / remote）不整合 → exec 前停止

## Output discipline

- 実装コード（`allowed_files` glob 内のみ）
- コミット履歴（チェックポイント単位）
- status.md にリアルタイム進捗

## 関連

- [`tool-policy.md`](../tool-policy.md) — exec phase の allowed tools
- [`hook-enforcement.md`](../hook-enforcement.md) EH-1 / EH-3 / EH-6 / **EH-9**（委譲 commit 境界）
