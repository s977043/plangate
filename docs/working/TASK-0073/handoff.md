---
task_id: TASK-0073
artifact_type: handoff
schema_version: 1
status: draft
---

# HANDOFF — TASK-0073 (F2 exec 強制力ギャップ)

## 1. 要件適合確認結果

| AC | 判定 | 根拠 |
|----|------|------|
| AC-1 委譲境界 構造化仕様 | PASS | execute.md「todo.md メタ `delegation_commit_boundary: no-commit`」 |
| AC-2 違反機械検出 | PASS | 新設 EH-9 `check-delegation-commit-boundary.sh`（決定論・テスト6件） |
| AC-3 git 主体プリフライト | PASS | execute.md exec 前プリフライト 1 |
| AC-4 認証三点プリフライト | PASS | execute.md exec 前プリフライト 2（gh auth/git config/remote） |
| AC-5 contract 追記・§5-bis 整合 | PASS | core-contract Decision rule + execute.md（F1 統合方針明記）+ EH-9 登録 |
| AC-6 決定論挙動 | PASS | EH-9 strict=block/default=warn/bypass・未宣言=従来動作 |
| AC-7 回帰なし | PASS | hook 54/0、CI lint 0 |

## 2. 既知課題一覧

- **EH-9 の settings wiring は Claude 適用不可**（TASK-0070 self-mod ガード教訓）。
  PreToolUse 有効化はユーザー手動。手順:
  `.claude/settings*.json` の PreToolUse(Bash) に
  `sh ${CLAUDE_PROJECT_DIR}/scripts/hooks/check-delegation-commit-boundary.sh`
  を追加（env `PLANGATE_DELEGATION_NOCOMMIT` を委譲時に設定）。未適用でも
  exec 後検証ステップ（二段目）で検出可能。
- core-contract §5-bis は F1（PR #245）にのみ存在。本 PBI は §5-bis への
  ダングリング参照を避け自己完結。**#245 マージ後に execute.md プリフライトを
  §5-bis 配下の単一ゲートへ統合**（重複排除）が follow-up。

## 3. V2 候補

- F1+F2 プリフライト統合（#245 マージ後）
- 認証三点プリフライトの CLI 実装（現状は契約定義。doctor 連携候補）
- #234 A-D（F5 別トラック）

## 4. 妥協点

- D-1=todo.md メタ + Hook + 事後検証の二段（C-3 採用）。Hook 単独は wiring 依存で
  未適用リスク、事後検証単独は事後性 → 二段で相互補完
- D-2=high-risk（§5-bis 参照型最小追記、V-4 スキップ）。core-contract 変更は
  Decision rule 1 行に留め独立不変条件新設は回避

## 5. 引き継ぎ文書（5分サマリ）

#239 問題2（委譲先が commit 禁止を破る・NL 依存）/ 問題3（exec 前認証
プリフライト欠如）を、EH-9 決定論 Hook + execute.md プリフライト仕様
（git 主体 + 認証三点 + 委譲境界 + 事後検証）で恒久対処。AC-1〜7 PASS。
F1（#245）と同一プリフライト層、マージ後統合。残: V-3 / C-4 / wiring 手動。

## 6. テスト結果サマリ

- EH-9: hook tests 54 passed / 0 failed（新規 6 件: 未宣言/strict/default/無害/bypass/stdin）
- CI lint: docs/workflows/04 0 error
- AC grep: AC-1〜7 全 PASS
