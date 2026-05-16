---
task_id: TASK-0074
artifact_type: handoff
schema_version: 1
status: draft
---

# HANDOFF — TASK-0074 (F3 Design/UI Addendum)

## 1. 要件適合確認結果

| AC | 判定 | 根拠 |
|----|------|------|
| AC-1 条件付きAddendum+削除可 | PASS | init 生成 pbi-input に「UIタスク時のみ・非UIは削除可」明記 |
| AC-2 踏襲元=最優先 | PASS | Addendum 1 番目「踏襲元の明示（★最優先）」 |
| AC-3 各フィールド | PASS | 配置/レスポンシブ/視覚受入基準/回帰ガード/視覚証跡 |
| AC-4 真実源分岐 | PASS | design-ui-addendum.md §3（Figma正/既存正/優先順 Figma>既存） |
| AC-5 判定トリガ+非強制 | PASS | §2 人手宣言基本+自動ヒント補助・非UIは強制しない |
| AC-6 参照なし明示 | PASS | `[参照なし]` フィールド（曖昧進行・ゲート回避防止） |
| AC-7 design.md整合 | PASS | templates/design.md §1-bis 視覚設計セクション |
| AC-8 既存出力非破壊 | PASS | init で Why/What/AC/Estimation 不変、hook 48/0 |

## 2. 既知課題一覧

- docs/ai/design-ui-addendum.md は CI markdownlint スコープ外（docs/ai 非対象）。
  ローカルで MD040 修正済（```text）。
- 自動ヒント（UI 層変更検出）は警告のみ・未実装の検出ロジックは V2 候補
  （現状は spec 上の方針定義。plan メタ連携は別 PBI）。

## 3. V2 候補

- 自動ヒント検出ロジックの実装（変更ファイル傾向→UI タスク示唆）
- Figma MCP 連携での参照自動取得・視覚回帰自動化
- F4（#235 Retro）/ F5（#234）別トラック

## 4. 妥協点

- D-1=人手宣言基本+自動補助（C-3）。自動のみは誤判定で両リスク、人手のみは
  宣言漏れ → 併用が最小リスク
- 強制 Hook を入れず spec/テンプレのソフト誘導（#236 の「一律必須化は
  ゲート回避を生む」要件に従う）

## 5. 引き継ぎ文書（5分サマリ）

#236（UI タスクで追加指示往復）を、pbi-input 条件付き Design/UI Addendum
（踏襲元明示=最優先）+ Figma 有無の真実源分岐 spec + design.md 視覚設計
セクションで恒久対処。非UIは削除可・参照なし明示でゲート回避も防ぐ。
AC-1〜8 PASS。他フィードバック PBI と独立。残: V-3 / C-4。

## 6. テスト結果サマリ

- init 生成回帰: Addendum 条件付き出力 + 既存出力非破壊 PASS
- AC grep: AC-1〜8 全 PASS
- hook 回帰: 48 passed / 0 failed
- lint: design-ui-addendum.md 0 error（CI 非対象だが清潔化）
