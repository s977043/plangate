# TASK-0106 EXECUTION PLAN

> Source: pbi-input.md / GitHub issue #289 / Mode: **high-risk**
> Generated: 2026-05-20

## Goal

人間が in-session で EH-3 skip を許可する一級手段（`bin/plangate maintenance` CLI）を新設し、`maintenance.json` 承認ファイルの **one-shot + パススコープ + 短 TTL** で運用性を改善する。AI 自己付与不可は構造的に維持する。

## Constraints / Non-goals

### Constraints
- **承認境界の構造的維持**: AI（hook/CLI）からは承認を自己発行不可。env 経路では有効化させない既存性質を不変条件とする
- **承認境界実行正本（EH-3）を破壊しない**: 既存 30 分窓の動作・strict JSON 抽出（#282/TASK-0105）はそのまま流用
- **Hardening Override（最上位）**: `.claude/rules/*.md`、`.claude/settings*.json`、`scripts/hooks/*.sh` は maintenance 窓内でも常に **block**（重要 infra は別承認ルート必須）

### Non-goals
- docs-only fast path の EH-3 への無条件追加（scope 限定承認で代替）
- 既存 30 分窓そのものの仕様変更（後方互換）
- 承認境界の撤廃・緩和

## Approach Overview

`schemas/maintenance.schema.json` を **additive 拡張**（`allowed_paths`/`one_shot`/`consumed_at` を optional 追加、既存フィールド変更なし）。`bin/plangate maintenance start|stop` で `docs/working/_maintenance/maintenance.json` を生成/削除。EH-3 hook が `consumed_at` を atomic 更新して one-shot 消費・path scope check・TTL check を実行。`bin/plangate doctor` に表示行追加。

## Work Breakdown

| # | Step | Output | Owner | Risk | 🚩 Checkpoint |
|---|------|--------|-------|------|--------------|
| 1 | schema 拡張 (`additionalProperties:false` 維持・新フィールドは optional) | `schemas/maintenance.schema.json` v2 | AI | low | 既存 schema test PASS |
| 2 | `bin/plangate maintenance start/stop` CLI 実装 (--reason/--paths/--minutes、ハード上限 30 分、`--reason` 必須) | `bin/plangate` | AI | medium | start で schema valid な JSON 生成、stop で削除 |
| 3 | EH-3 hook 改修: path scope check (sh glob) + TTL check + one-shot consume (atomic write `consumed_at`) | `scripts/hooks/check-plan-hash.sh` | AI | **high** (承認境界) | 既存 30 分窓テスト PASS + 新動作テスト PASS |
| 4 | Hardening Override 実装: `.claude/rules/*.md` / `.claude/settings*.json` / `scripts/hooks/*.sh` は窓内でも block | EH-3 hook 内 | AI | high | Override 対象パスは scope 内でも block されるテスト PASS |
| 5 | `bin/plangate doctor` 表示行追加: 有効窓があれば「scope/remaining/paths」 | `bin/plangate` | AI | low | doctor 出力テスト PASS |
| 6 | テスト追加: CLI 単体・hook 単体・E2E (start→edit→consume→re-block) | `tests/extras/ta-XX-maintenance.sh`、`tests/hooks/*` | AI | medium | 全テスト + 既存 68/78 PASS 維持 |
| 7 | docs 整備: `docs/ai/maintenance-cli.md`（運用 guide） | docs | AI | low | リンク健全 |
| 8 | handoff.md 作成 + V-1 受け入れ検査 | TASK-0106/handoff.md | AI | low | 全 AC PASS 確認 |

## Files / Components to Touch

| ファイル | 性質 |
|---------|------|
| `schemas/maintenance.schema.json` | 拡張 (additive) |
| `bin/plangate` | サブコマンド追加 (maintenance) + doctor 表示行 |
| `scripts/hooks/check-plan-hash.sh` | path/TTL/one-shot 判定追加・Hardening Override |
| `tests/extras/ta-XX-maintenance.sh` | 新規 |
| `tests/hooks/run-tests.sh` | 既存に maintenance 系追加 |
| `docs/ai/maintenance-cli.md` | 新規（運用 guide） |
| `docs/working/TASK-0106/handoff.md` | WF-05 |

## Testing Strategy

- **Unit (CLI)**: `maintenance start` で schema valid な JSON 生成 / `stop` で削除 / `--minutes` ハード上限拒否 / `--reason` 必須エラー
- **Unit (hook)**: path glob match / TTL 内/外 / one-shot consumed_at が未設定で通過・設定後 block / Hardening Override 対象は窓内でも block
- **Integration (E2E)**: `maintenance start --paths "README.md" --minutes 5` → no-task で README.md Edit 通過 (consumed_at 書込) → 同じ承認で 2 回目 Edit が block → stop で完全失効
- **Backward compat**: 既存 30 分窓・パス無指定 maintenance.json が引き続き動作
- **回帰**: 既存 `tests/run-tests.sh` 68 PASS + `tests/hooks/run-tests.sh` 78 PASS 維持

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| 承認境界の意図せぬ緩和（hook 改修ミスで env 経路で有効化される 等） | **critical** | env 経路での無効化を unit test で固定、Hardening Override をデフォルト ON |
| one-shot consume の race condition (2 並行 Edit) | high | `consumed_at` 書込を atomic に（tmp file + rename）。読み出し時に再検証 |
| path glob の解釈差異 (sh case vs python fnmatch) | medium | EH-3 が sh なので sh case パターンで統一・テストで多パターン検証 |
| 既存 30 分窓との後方互換破壊 | high | 既存テストを必ず維持 + 新フィールド unknown 時のデフォルト動作を「既存挙動と同じ」に固定 |

## Questions / Unknowns

- one-shot の consume granularity: 単一 Edit/Write 操作で 1 回？それとも単一 ツール呼び出しで 1 回？（要決定: **単一 Edit/Write 操作で 1 回** を案）
- doctor 表示の TTL 粒度（秒/分）→ **分:秒表示** 案
- `--paths` 未指定時の動作: (a) 全パス許可（既存 30 分窓互換）/ (b) エラー（明示必須）→ **(a) 後方互換維持** 案
- `bin/plangate maintenance start` を AI 起動可とするか: **可**（生成承認ファイルが env では効かない設計で AI 自己付与不可を担保） — pbi-input 仮定どおり

## Mode 判定

**high-risk**（critical 寄り）

判定根拠:
- 変更ファイル数: 6-8 → high-risk
- セキュリティ関連（承認境界実行 hook 改修）→ 最低でも中、本件は高
- リスク: 高（承認境界破壊の可能性）
- ロールバック: 計画的に必要（schema/hook の互換性保持で対応）
- **最終判定**: high-risk（critical 候補は exec フェーズで再評価）
