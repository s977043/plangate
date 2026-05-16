---
task_id: TASK-0072
artifact_type: plan
schema_version: 1
status: draft
---

# EXECUTION PLAN — TASK-0072 exec 委譲デッドロック恒久対処

## Goal

exec フェーズの実行者を実行環境のケイパビリティで分岐し、サブエージェント
委譲不能環境では人間介入なしで直接実行へ自動フォールバックする正規フローを
確立する。2段委譲を暗黙の前提にしない。

## Constraints / Non-goals

- conductor は廃止しない（委譲可能環境の並列性・責務分離は維持）
- 承認境界（C-3 等）は変更しない（本 PBI は exec 実行モデルのみ）
- #239 問題2（commit 禁止のツール強制）/ 認証プリフライト全般は F2 別 PBI
- #234 A/B/C/D は F5 別トラック

## Approach Overview

ドキュメント/定義レイヤ中心の変更（コード強制は最小）。
1. ケイパビリティ・プリフライトの正規手順を定義（Task 可否検出）
2. exec フロー定義を「委譲可→conductor / 不可→直接実行」の分岐に書き換え、
   フォールバックを既定の正規パスに格上げ
3. core-contract に「exec は任意環境で完遂可能」不変条件を追加し、
   2段委譲必須定義を禁止と明文化
4. error taxonomy に `delegation_unavailable` + recovery=自動降格を定義
5. workflow-conductor agent 定義を整合（衝突時は降格 or 正しいエスカレーション）

## Work Breakdown

| Step | 内容 | Output | Owner | Risk | 🚩 |
|------|------|--------|-------|------|----|
| S1 | 現状調査: exec 系 workflow 定義 / core-contract / conductor agent / 既存 error 分類の所在特定 | 調査メモ | agent | low | - |
| S2 | ケイパビリティ判定方式の意思決定（環境変数 / ツール存在検査 / プリフライト探索）→ C-3 上申 | design note | agent | high | 🚩C-3判断 |
| S3 | exec フロー定義を分岐+フォールバック既定へ改訂 | workflow 差分 | agent | high | 🚩AC-2/AC-3 |
| S4 | core-contract 不変条件追加（2段委譲必須禁止） | contract 差分 | agent | crit | 🚩AC-4 |
| S5 | error taxonomy に delegation_unavailable + recovery 定義 | taxonomy 差分 | agent | med | 🚩AC-5 |
| S6 | workflow-conductor agent 定義の整合反映 | agent 差分 | agent | med | 🚩AC-6 |
| S7 | ドキュメント整合性・hook テスト回帰確認 | テスト結果 | agent | med | 🚩AC-7 |
| V | V-1 受け入れ / V-3 外部レビュー(Codex+Gemini) / V-4(critical) | レビュー | agent | high | - |

## Files / Components to Touch（plan 段階の想定・S1 で確定）

- `docs/ai/core-contract.md`（不変条件追加）
- `docs/workflows/04_*.md`（exec フェーズ定義）+ 関連 README
- `.claude/agents/workflow-conductor.md`（責務整合）
- `docs/ai/contracts/execute.md`（実行契約）
- error taxonomy 文書（#203 関連・所在 S1 で特定）
- `.claude/skills/ai-dev-workflow`（exec 記述）

## Testing Strategy

- 定義整合: 「conductor 委譲が前提」表現の不在を grep で機械検証
- 不変条件: core-contract に exec 完遂可能条項が存在することを検証
- error taxonomy: delegation_unavailable エントリ + recovery=自動降格の存在検証
- 回帰: 既存ドキュメント整合性チェック / hook テスト 60 件 green
- シナリオ: 委譲不可環境を模した手順で「直接実行フォールバックが既定」を文書上トレース

## Risks & Mitigations

- R1: core-contract 変更が他フェーズ定義と矛盾 → S1 で依存洗い出し、S4 を最後に
- R2: ケイパビリティ判定が新たな分岐バグ源 → 判定失敗時は「直接実行（安全側）」に倒す
- R3: スコープがガバナンス全体に波及 → F2/F5 を明示的に切り離し済み
- R4: conductor 定義変更が Iron Law を弱める誤読 → 「降格は環境制約時のみ・原則は不変」を明記

## Questions / Unknowns

- ケイパビリティ判定の正規手段（S2 / C-3 判断）
- error taxonomy の正本配置（#203 未着手なら本 PBI で最小定義を新設するか）→ C-3

## Mode判定

**モード**: critical

**判定根拠**:
- 変更ファイル数: 6+（contract/workflow/agent/skill/taxonomy） → 高〜超高
- 受入基準数: 7 → 高
- 変更種別: core-contract（実行契約の不変条件）+ ワークフロー定義変更 → アーキ変更
- リスク: 極高（exec 実行モデルの中核・全 PBI に波及）
- 例外: ワークフロー定義変更は mode-classification 上 critical 相当
- **最終判定**: critical（C-2/V-3/V-4 必須。S2 は C-3 追加判断）
