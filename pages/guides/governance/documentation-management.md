# Documentation Management

> **Status**: v0
> **Review cadence**: Monthly
> **Reference**: River-Reviewer documentation structure

## 1. 目的

PlanGate のドキュメント管理方針を定義する。

Kiro 前提の配置ではなく、River-Reviewer を参考に、公開説明ドキュメントは `pages/`、開発・運用ドキュメントは `docs/` に分ける。

## 2. Directory policy

| Directory | Role |
| --- | --- |
| `pages/` | 公開サイト・外部説明・プロダクト説明・ガイド・リファレンス |
| `pages/explanation/` | 背景、思想、設計意図、プロダクト説明 |
| `pages/guides/` | 導入手順、運用手順、デモ手順、ドキュメント管理方針 |
| `pages/reference/` | FAQ、仕様、スキーマ、用語集、参照資料 |
| `docs/` | 開発者向け runbook、内部運用、作業ログ、移行メモ、workflow 定義 |
| `docs/working/` | TASK 単位の作業コンテキスト、レビュー記録、handoff |

## 3. Placement rules

### `pages/explanation/` に置くもの

- Product Overview
- Philosophy
- Positioning
- Before / After
- Value Proposition Canvas
- Architecture explanation
- Roadmap narrative

### `pages/guides/` に置くもの

- Quickstart
- Setup guide
- Demo Script
- Workflow usage guide
- Documentation Management
- Governance guide

### `pages/reference/` に置くもの

- FAQ
- Glossary
- Schema reference
- CLI reference
- Known limitations
- Contract definitions

### `docs/` に置くもの

- 開発者向け runbook
- 内部運用メモ
- workflow 定義
- hook / eval / metrics の実装詳細
- release / audit / migration logs
- `docs/working/` 配下の task-specific artifacts

## 4. Current migration

今回のプロダクト説明資料は、以下のように `pages/` へ移動する。

| Old path | New path |
| --- | --- |
| `docs/product/README.md` | `pages/index.md` / `pages/explanation/product/overview.md` |
| `docs/product/product-brief.md` | `pages/explanation/product/overview.md` |
| `docs/product/before-after.md` | `pages/explanation/product/before-after.md` |
| `docs/product/positioning.md` | `pages/explanation/product/positioning.md` |
| `docs/product/value-proposition-canvas.md` | `pages/explanation/product/value-proposition-canvas.md` |
| `docs/product/faq.md` | `pages/reference/product-faq.md` |
| `docs/product/demo-script.md` | `pages/guides/product-demo-script.md` |
| `docs/pm-po-elevator-pitch.md` | `pages/explanation/product/pm-po-elevator-pitch.md` |

## 5. Sidebar policy

River-Reviewer と同様、公開 docs の navigation は `sidebars.js` で管理する。

カテゴリは以下を基本とする。

```text
- index
- ガイド
- リファレンス
- 解説
```

PlanGate では Product narrative を `解説 > プロダクト` に置く。

## 6. Review cadence

月 1 回、以下を見直す。

- `pages/` と `docs/` の役割が混ざっていないか
- 外部向け説明が `pages/` に集約されているか
- `docs/working/` が公開導線に含まれていないか
- Product Overview / Positioning / FAQ が実装状況とズレていないか
- Harness Improvement Roadmap の進捗が反映されているか
- `sidebars.js` の導線が壊れていないか

## 7. Non-goals

この方針は以下を目的にしない。

- すべての既存 `docs/` を即時 `pages/` に移行すること
- Docusaurus 導入をこのPRで完了すること
- `docs/working/` を公開サイトに含めること
- Kiro 前提の運用を継続すること

## 8. Principle

公開説明は `pages/`。
開発・運用・作業ログは `docs/`。
TASK 固有の状態は `docs/working/`。
