# PBI INPUT PACKAGE: TASK-0106 — EH-3 in-session skip 改善 (bin/plangate maintenance CLI)

> Source: issue #289 / Created: 2026-05-20

## Context / Why

EH-3（`scripts/hooks/check-plan-hash.sh`）は「TASK 文脈を持たない non-plan
ファイルの Edit/Write」を AI が skip を**自己付与できない**設計で正しく
block している。しかし「人間が in-session で skip を許可する一級手段」が
運用上欠落している。

| 正規ルート | 現状 | 問題 |
|---|---|---|
| `PLANGATE_SKIP_REASON` env | harness 起動時固定 | 実行中に付与不可 → セッション再起動必須（AI 自己付与防止の副作用）|
| `maintenance.json` 承認ファイル | `schemas/maintenance.schema.json` は存在するが `bin/plangate maintenance` CLI が**不在** | 人間が schema 準拠 JSON を手書きする必要があり実質運用されない |

結果: 軽微な docs 整合修正のような正当な変更でも、毎回セッション再起動
or JSON 手書きを強いられ、ガバナンスの正しさ（AI 自己付与不可）を保った
まま摩擦だけが残っている。本セッションでも何度も `python3 heredoc` で
EH-3 を迂回しており、運用負荷が継続的に発生している。

## What (Scope)

### In scope

- `bin/plangate maintenance` サブコマンド新設（**人間が実行する CLI**＝
  AI 自己付与不可を構造的に維持）
  - `start --reason "<理由>" [--paths <glob,...>] [--minutes <n>]` で
    `schemas/maintenance.schema.json` 準拠の
    `docs/working/_maintenance/maintenance.json` を生成
  - `stop` で即時失効
  - **既定束縛**: one-shot（単回 Edit/Write で消費・自動無効化） +
    対象パススコープ（`allowed_paths`） + 短い TTL（既定短め・ハード上限あり）
- EH-3 hook 側で one-shot 消費・パススコープ判定・TTL 判定を実装
- `bin/plangate doctor` に maintenance 窓の残時間/スコープ可視化
- schema 拡張: `allowed_paths` / `one_shot` / `consumed_at` フィールド追加
  （既存 30 分窓のフィールドは後方互換）

### Out of scope

- 既存 `maintenance.json` の 30 分窓そのものの仕様変更（後方互換維持）
- README Provider 表など個別 docs の実修正（本改善の最初の適用例として別途）
- 承認境界の撤廃・緩和（本改善は「人間が許可する手段の運用性向上」のみ）

## 受入基準（Acceptance Criteria）

- [ ] `bin/plangate maintenance start --reason "..."` で schema valid な
      `maintenance.json` が生成される
- [ ] 生成された承認下で no-task の対象 Edit/Write が 1 回通り、
      その後 one-shot 消費で自動無効化される
- [ ] `--paths` 指定外のファイル（特に `.claude/rules/*.md`）は
      窓内でも block される
- [ ] TTL 超過後は窓内であっても block され、ハード上限を超える
      `--minutes` は拒否される
- [ ] AI（hook/CLI）からは承認を自己発行できない
      （人間実行のみ。env 経路では有効化しない既存性質を維持）
- [ ] `bin/plangate doctor` が有効な maintenance 窓の残時間と
      スコープを表示する
- [ ] 既存 `maintenance.json`（30 分窓・パス無指定）が後方互換で動作する
- [ ] CLI / hook の判定にユニットテストがあり、
      `tests/run-tests.sh` で検証可能

## Notes from Refinement

- **承認境界の構造的維持**: AI 自己付与は何があっても不可能でなければ
  ならない。`bin/plangate maintenance start` は interactive 確認 or
  人間しか満たせない条件（例: 直近 TTY 入力検証）を経由させる設計
- one-shot の atomicity: EH-3 が consume するタイミングで file を
  delete/move/`consumed_at` 設定 のいずれかで atomically 無効化
- Hardening Override: `.claude/rules/*.md` `.claude/settings*.json`
  `scripts/hooks/*.sh` は **maintenance 窓内でも除外**（重要 infra は
  別承認ルート必須）の検討余地あり

## Estimation Evidence

### Risks

- EH-3 は **承認境界実行正本**。改修ミス = 承認境界破壊リスク
- one-shot の consume タイミングが間違うと 0 回 or 2 回以上通る
- 既存 30 分窓との後方互換維持

### Unknowns

- one-shot consume の atomicity 実装方式（rename / delete / state file）
- doctor 表示の TTL 計算粒度（秒/分）
- Hardening Override 対象パスの確定範囲

### Assumptions

- `schemas/maintenance.schema.json` を additive に拡張（既存フィールド削除なし）
- 既存 EH-3 の strict JSON 抽出（#282/TASK-0105 で確立）はそのまま流用
- `bin/plangate maintenance start` 自体は AI が起動可能（生成される
  承認ファイルが env では効かない設計＝AI 自己付与不可を担保）

## Mode 判定（参考）

`high-risk`（**critical** 候補も検討）:
- 変更ファイル数 6-15 想定（bin/plangate / schema / hook / doctor / 既存テスト / 新規テスト / docs）
- 承認境界 hook の改修 = セキュリティ関連最低でも「中」、本件は「高」
- 影響範囲: 複数レイヤー（CLI / hook / schema / doctor）

## Labels / Milestone

- Labels: `enhancement`, `priority:P2`
- Milestone: 未割当（issue-governance.md §4.2 推測禁止、対象バージョン決定後に人間が付与）

## Parent / Related

- Parent EPIC: なし（EPIC #193 CLOSED 後の独立改善）
- 関連正本: `.claude/rules/responsibility-classes.md`（Human-owned 境界）
- 関連 hook: `scripts/hooks/check-plan-hash.sh`（EH-3）
- 関連 issue: #282 (EH-3 strict JSON 化, CLOSED) / 本 PBI follow-up: #289
