---
task_id: TASK-0077
artifact_type: pbi-input
schema_version: 1
status: draft
---

# PBI INPUT PACKAGE — TASK-0077

> F5-AD: 規模ベース Lite ゲート分岐 + C-3 条件付き降格（承認境界に触れる）
> 起源（field feedback）: #234-A / #234-D（関連: #213 / #226 / TASK-0071）
> **本 PBI は計画のみ先行。実装は C-3 で承認境界変更の是非を人間判断後**

## Context / Why

#234 field report の A/D:

- **A**: 小規模・既存パターン踏襲・新規設計ゼロの PBI に full ゲート
  （C-1 17項目 + C-2 三者 + C-3）が一律適用 → リードタイム/トークン浪費、
  ゲート運用が敬遠される（ガバナンス自己崩壊リスク）
- **D**: 小規模かつ C-1 PASS・C-2 critical/major=0 でも C-3 人間 APPROVE
  待ちで exec 完全ブロック → 人間がボトルネック、ゲート省略の動機を生む

両者とも **PlanGate の中核「承認境界」に直接触れる**。安易な緩和は統制
崩壊リスク。慎重に「強度を規模で選ぶ／承認の同期非同期を選ぶ」を opt-in で
設計する（承認境界の撤廃ではなく強度の選択肢化）。TASK-0071（Governance
Hardening）と責務が交差するため境界整理も必要。

## What — Scope（計画のみ先行）

### In scope（本 PBI = 計画策定まで）

- **A: 規模ベース Lite/Standard 分岐の設計**
  - 判定軸（変更ファイル数 / 新規設計有無 / 既存パターン踏襲）と #213 Plan
    Health 内訳での自動推定 + 人間 override
  - Lite ゲート構成（C-1 + 外部レビュー 1 本 + C-3）の定義
  - mode-classification.md との関係整理（Lite は mode の直交軸か内包か）
- **D: C-3 条件付き降格の設計**
  - 降格条件（C-1 PASS かつ C-2 critical/major=0 かつ Lite 判定）
  - 「事前ブロッカー → 事後確認（exec 並行・reject で巻き戻し）」の opt-in
    設計（承認境界は撤廃せず同期/非同期を選択可能に）
  - TASK-0071（承認境界 / 責務4分類 / Shadow Config）との重複排除・境界定義
- 上記の plan / C-1 / C-3 ゲート提示まで（**実装は C-3 承認後・別 phase**）

### Out of scope

- 本 PBI での A/D の実装（C-3 で承認境界変更の是非を人間判断 → 別途）
- B/C（TASK-0076・F5-BC）
- #213/#226 の実装本体（接続のみ）

## Acceptance Criteria（計画成果物に対する AC）

- [ ] AC-1: Lite/Standard 判定軸と自動推定 + 人間 override 方式が設計定義される
- [ ] AC-2: Lite ゲート構成（C-1+外部1本+C-3）と mode-classification との関係が整理される
- [ ] AC-3: C-3 降格条件と「同期/非同期」opt-in 設計が承認境界を撤廃しない形で定義される
- [ ] AC-4: TASK-0071 との責務重複（承認境界/ガバナンス）が切り分け定義される
- [ ] AC-5: 承認境界後退リスクと緩和（reject 巻き戻し・監査・opt-in 既定 OFF）が明記される
- [ ] AC-6: #213 Plan Health / #226 段階導入ガイドとの接続点が定義される
- [ ] AC-7: 実装は C-3 承認後の別 phase とすることが明記され、計画段階で停止する

## Notes from Refinement

- #234-A/D は PlanGate 設計思想（承認境界固定）と緊張 → **opt-in 設定**前提
- D は #213 Plan Health Score を降格可否の判定根拠に使う想定
- TASK-0071 と交差: 本 PBI は「ゲート強度の選択」、TASK-0071 は「不可侵領域の
  責務分界」。両者の境界を AC-4 で明文化
- ユーザー C-3 方針: 「計画のみ先行・実装は C-3 後」（承認境界変更のため最慎重）

## Estimation Evidence

**Risks**: PlanGate 中核（承認境界）変更。緩和を誤るとガバナンス崩壊 →
opt-in 既定 OFF・reject 巻き戻し・監査を不変条件化。計画のみ先行で実装前に
人間判断を挟む
**Unknowns**: Lite が mode-classification の直交軸か内包か / 降格の既定値 →
C-3 判断
**Assumptions**: 本 PBI は計画策定で完了扱い（実装は承認後別 PBI/phase）。
Mode 想定: critical（承認境界・横断・計画のみでも慎重）
