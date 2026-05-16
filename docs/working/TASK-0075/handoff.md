---
task_id: TASK-0075
artifact_type: handoff
schema_version: 1
status: draft
---

# HANDOFF — TASK-0075 (F4 opt-in 終端 Retro フェーズ)

## 1. 要件適合確認結果

| AC | 判定 | 根拠 |
|----|------|------|
| AC-1 R定義+execution-sequence/README | PASS | 06_retro.md 必須5セクション + README 目次/artifact/シーケンス反映 |
| AC-2 opt-in既定OFF | PASS | 06_retro.md「既定で発火しない」+ retro-phase.md opt-in正本（明示コマンド/メタ・env不使用） |
| AC-3 #228 5項目/スコアリングなし | PASS | スコアリング含まない明記・#231 責務非重複明記 |
| AC-4 seeds append-only | PASS | retro-phase.md §2 配置/スキーマ/append-only/run またぎ |
| AC-5 承認境界維持 | PASS | confirm/skip 1行・自動はドラフトのみ明記 |
| AC-6 #200 接続点 | PASS | 06_retro.md「#200 期間集計 CLI を入力源」+ retro-phase §3 |
| AC-7 #228 参照のみ | PASS | 「#228 を再定義せず参照」明記 |
| AC-8 既定OFFで既存不変 | PASS | R は純追加・01〜05 不変・hook 48/0・doc 整合 lint 0 |

## 2. 既知課題一覧

- 06_retro.md / retro-phase.md は CI markdownlint スコープ外を含む
  （docs/workflows は対象・lint 0 確認済、docs/ai は非対象）。
- opt-in 起動の*実装*（コマンド `retro` サブコマンド・メタ読取）は本 PBI で
  仕様正本化。CLI 実装は後続（spec 準拠で別 PBI / V2）。

## 3. V2 候補

- `/ai-dev-workflow TASK-X retro` サブコマンド + メタ読取の CLI 実装
- #200 期間集計 CLI 本体（improvement-seeds.md 吸い上げ）
- F5（#234）別トラック

## 4. 妥協点

- D-1=明示コマンド+メタ併用（C-3）。env は TASK-0071 自己付与リスク教訓で不採用
- D-3=high-risk（opt-in/既定OFF/handoff後純追加で影響限定。critical 格上げ回避）
- 正式 Level 体系が未実装のため opt-in フラグ方式を本 PBI で正本化

## 5. 引き継ぎ文書（5分サマリ）

#235（振り返り実行漏れ＝知見死蔵）を、opt-in 終端フェーズ WF-06 として
定義。既定 OFF・明示フラグのみ発火・ドラフトのみ自動・人間 confirm 確定で
承認境界維持。#228 参照（再定義せず）/ #231 と責務非重複 / #200 へ給餌。
既存 run 挙動は完全不変（純追加）。AC-1〜8 PASS。残: V-3 / C-4。

## 6. テスト結果サマリ

- AC grep: AC-1〜8 全 PASS
- hook 回帰: 48 passed / 0 failed（既存挙動不変）
- lint: 06_retro.md / README.md 0 error
