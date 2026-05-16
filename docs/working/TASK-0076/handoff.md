---
task_id: TASK-0076
artifact_type: handoff
schema_version: 1
status: draft
---

# HANDOFF — TASK-0076 (F5-BC C-2 責務分離 + 反映差分管理)

## 1. 要件適合確認結果

| AC | 判定 | 根拠 |
|----|------|------|
| AC-1 2レーン定義 | PASS | review-principles §7-bis（設計妥当性 / コードベース整合）|
| AC-2 読む/読まない/V-3移譲 | PASS | §7-bis 表 + 「実装詳細は V-3 へ」明記 |
| AC-3 5観点・承認境界 不変 | PASS | §7-bis 冒頭「§2〜4 は不変」明記、diff は §7-bis 追加のみ（§2〜4 無改変） |
| AC-4 追記専用集約 | PASS | working-context「review-external.md に追記専用で集約」 |
| AC-5 exec開始時1回確定 | PASS | working-context 反映フロー + CONDITIONAL 節更新 |
| AC-6 差分追跡+接続点 | PASS | 指摘ID R-NNN + `Refs: R-NNN`、#230/#200 additive 連携明記 |
| AC-7 working-context反映 | PASS | 「C-2 指摘の差分管理」節 + CONDITIONAL/FAIL フロー更新 |
| AC-8 回帰なし | PASS | hook 48/0、§2〜4 無改変、doc 整合 |

## 2. 既知課題一覧

- #227 river-reviewer 標準 IF 本体 / #230 events / #200 集計の*実装*は本 PBI 外
  （責務契約・接続点の定義のみ。実装は各 issue）。
- 2 レーン運用の Agent 割当（どの Agent がどのレーンか）は運用判断（本 PBI は
  責務契約まで。Agent 定義への割付は V2 / 別 PBI）。

## 3. V2 候補

- 2 レーンの Agent 割付（C-2 実行 Agent 定義への反映）
- #230 events `review-finding→plan-revision` 連携実装
- F5-AD（TASK-0077）/ F5 残

## 4. 妥協点

- D-1=指摘ID+コミット Refs（C-3）。events 連携は #230 待ちで additive（恒常
  運用を待たせない最小実装）
- 承認境界・5観点・Severity は不変（#234「ゲート価値は残す」前提を厳守）

## 5. 引き継ぎ文書（5分サマリ）

#234-B/C を、C-2 の 2 レーン責務契約（設計妥当性=実コード読まない/
コードベース整合=1集約、実装詳細は V-3）+ 指摘の review-external 追記専用
集約・exec 開始時 1 回確定反映・指摘ID→Refs 差分追跡で対処。承認境界・
5観点不変。AC-1〜8 PASS。TASK-0077(F5-AD)と独立。残: V-3 / C-4。

## 6. テスト結果サマリ

- AC grep: AC-1〜8 全 PASS
- hook 回帰: 48 passed / 0 failed
- review-principles §2〜4 無改変（承認境界・観点不変）
