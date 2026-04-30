# TASK-0039 Status

> exec フェーズの進捗ログ（フェーズ遷移ごとに追記）

## 全体構成

- **対象 Issue**: [#117](https://github.com/s977043/plangate/issues/117)
- **親 PBI**: [PBI-116](../PBI-116/parent-plan.md)
- **子 PBI ID**: PBI-116-01
- **ブランチ**: `feat/PBI-116-01-impl-step1-2`（Step 1+2 のみ）
- **モード**: high-risk
- **状態**: exec 中（Step 1+2 完了、Step 3-6 は次セッション）

## C-3 Gate: APPROVED

- 判定: APPROVED（2026-04-30、s977043）
- 記録: [`approvals/c3.json`](./approvals/c3.json)
- plan_hash: `sha256:6632a42...`

## 現在のフェーズ

✅ Step 1 棚卸し完了 → [`evidence/inventory.md`](./evidence/inventory.md)
✅ Step 2 Core Contract 作成完了 → [`docs/ai/core-contract.md`](../../ai/core-contract.md)
✅ Baseline 記録完了 → [`evidence/baseline.md`](./evidence/baseline.md)

⏳ Step 3-6（既存ファイル薄型化）は次セッションで別 PR に分割

## 完了タスク（本 PR スコープ）

### 準備
- [x] T-1: Scope/受入基準の再確認
- [x] T-2: 既存 Iron Law 6 項目との対応特定（pbi-input.md 対応表で実施済）

### Step 1: 棚卸し
- [x] T-3: 64 ファイル grep 実行 → `evidence/inventory.md`
- [x] T-4: 削減候補を 3 段階分類（必須 7 / 推奨 1 / 保持 14 / 個別 4）

### Step 2: Core Contract 定義
- [x] T-5: skeleton 作成（8 セクション）
- [x] T-6: Hard constraints に Iron Law 7 項目を明示
- [x] T-7: Role / Goal / Success criteria / Decision rules / Available evidence / Stop rules / Output discipline 全セクション記述
- [x] T-8: セルフ検証（8 セクション完備、Iron Law 7 項目漏れなし）

## 未完了タスク（次セッション、別 PR）

### Step 3: CLAUDE.md 薄型化（T-9〜T-11）
### Step 4: AGENTS.md 薄型化（T-12〜T-14）
### Step 5: project-rules.md 整合（T-15）
### Step 6: hard-mandate 削減（T-16〜T-20）
### Step 7: 検証（T-21〜T-24）
### Step 8: handoff + PR（T-25〜T-28）

## 計画からの変更点

- **PR 分割**: T-1〜T-8 を本 PR、T-9〜T-28 を次 PR に分割
- **理由**: high-risk な既存ファイル編集（CLAUDE.md / AGENTS.md / その他）はレビュー粒度を別 PR に分けたほうが安全。本 PR は新規ファイル作成（core-contract.md / inventory.md / baseline.md）のみで影響範囲限定。

## 関連 PR

- PR #126〜#131（計画書 + Parent C-3 + 子 plan + C-2 + Child C-3）
- 本 PR（exec Step 1+2、新規ファイル 3 件）

## 次セッションのタスク

1. ブランチ `feat/PBI-116-01-impl-step3-8` 作成
2. T-9〜T-28 を順次実行（CLAUDE.md / AGENTS.md / project-rules.md / .claude/ / plugin/plangate/ の編集）
3. evidence/verification.md 記録
4. handoff.md 作成
5. 子 PR → Child C-4 ゲート
