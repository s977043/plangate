# opt-in 終端 Retro フェーズ 正本仕様（F4 / TASK-0075）

> [`docs/workflows/06_retro.md`](../workflows/06_retro.md) の opt-in 起動条件と
> improvement-seeds スキーマの正本。起源 #235。

## 1. opt-in 起動正本（既定 OFF）

| 方式 | 形 | 既定 |
|------|----|------|
| 明示コマンド | `/ai-dev-workflow TASK-XXXX retro` | 未実行＝OFF |
| pbi-input メタ | `retro_enabled: true`（未記載＝false） | OFF |

両方式とも明示。env は不使用。**フラグが立たない限り WF-06 は発火しない**＝
既存 run の挙動は完全に不変（純追加・後方互換）。

## 2. improvement-seeds.md スキーマ（append-only / C-3 D-2 最小）

配置: `docs/working/improvement-seeds.md`（リポジトリ単位で累積、run またぎ）。
1 run 1 エントリを **追記のみ**（既存エントリの編集・削除をしない）。

```text
## <date ISO8601> — <task_id>
- 目的達成可否: <text>
- 失敗・手戻り: <text>
- 次回再利用すべき判断: <text>
- 効いた skill / gate / artifact: <text>
- 1 人運用で負荷が高かった箇所: <text>
- confirmed_by: <human>
```

スコアリング・優劣判定は含めない（#231 LLM-judge の責務）。

## 3. 責務分離（重複防止）

| 関連 | 関係 | 本 PBI の扱い |
|------|------|--------------|
| #228 Outcome Review テンプレ | 5 項目テンプレの正本 | **参照のみ**（再定義しない） |
| #231 Dogfooding Eval judge | 機械評価・スコアリング | 本 phase はスコアリングしない |
| #200 Reporting & Retrospective | 期間集計・改善 PBI 抽出 | 本 phase は **入力（seeds）を生む前段**。集計本体は #200 |

## 4. 承認境界（PlanGate 原則維持）

自動なのは**ドラフト生成のみ**。`improvement-seeds.md` への確定追記は
**人間の confirm（1 行）でのみ**実行。skip 選択時は追記せず run 正常終了。
人間判断点を固定する PlanGate 原則を撤廃しない。

## 5. 関連

- workflow: [`docs/workflows/06_retro.md`](../workflows/06_retro.md)
- 起源 issue: #235（関連 #228 / #200 / #231）
- 思想: F2/F3 と同じく「ゲート回避させない／人間判断点を固定」
