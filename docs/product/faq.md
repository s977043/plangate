# FAQ: PlanGate

> **Status**: v0
> **Review cadence**: Monthly
> **Related**: [`product-brief.md`](./product-brief.md) / [`positioning.md`](./positioning.md)

## 1. 目的

このドキュメントは、PlanGate の導入検討時によく出る質問・反論に答えるための FAQ である。

PM / PO / EM / CTO / Developer に対して、PlanGate の価値、対象範囲、代替手段との差分を説明するために使う。

## 2. 基本理解

### Q. PlanGate は何ですか？

PlanGate は、AI コーディングエージェントをプロダクト開発に安全に組み込むためのゲート型ワークフローハーネスである。

AI が本番コードを書く前に、PBI、計画、TODO、受入条件、人間承認を必須化する。

### Q. 一言で言うと？

```text
No approved plan, no code.
```

AI がコードを書く前に、計画と受入条件を通す仕組みである。

### Q. 誰向けですか？

主な対象は、AI コーディングエージェントをチーム開発で使う以下の人たちである。

- PM
- PO
- EM
- CTO
- Developer
- Scrum team
- OSS adopter

## 3. 価値に関する質問

### Q. AI の速度が落ちませんか？

短期的には、実装前に plan / test-cases / approval を通すため、即時実装より遅く見える。

しかし PlanGate の狙いは、初速だけを最大化することではない。

間違ったものを速く作るリスク、PR レビューでの手戻り、受入条件の後付け、スコープ逸脱を減らすことで、プロダクトデリバリー全体の速度と信頼性を上げる。

また、PlanGate は mode によって軽量化できる。

- ultra-light
- light
- standard
- high-risk
- critical

低リスクでは軽く、高リスクでは厳しくする。

### Q. AI に任せる意味が薄れませんか？

薄れない。

PlanGate は AI を止めるための仕組みではなく、AI が正しい範囲で速く動くための仕組みである。

AI が得意な実装、調査、検証、レビュー補助は活かしつつ、何を作るか、何を Done とするか、人間がどこで判断するかを固定する。

### Q. PM / PO が直接使うものですか？

直接操作しなくても価値がある。

PM / PO にとって重要なのは、AI が作業する前に PBI の意図、受入条件、Done の定義が確認可能になり、実装後に検証結果と handoff が残ることである。

Developer や EM が PlanGate を運用していても、PM / PO の責任範囲である価値、スコープ、受入条件が守られやすくなる。

## 4. 競合・代替手段に関する質問

### Q. Cursor や Claude Code と競合しますか？

競合ではなく補完である。

Cursor、Claude Code、Codex CLI などは、AI エージェントが実際に作業する実行環境である。

PlanGate は、それらの上位で、PBI、計画、承認、検証、handoff を管理するワークフローハーネスである。

### Q. CI/CD で十分では？

十分ではない。

CI/CD は主に実装後の検証を扱う。

PlanGate は実装前に、何を作るか、どう作るか、何を満たせば Done かを固定する。

つまり PlanGate は、post-check だけでなく pre-implementation governance を扱う。

### Q. Issue template や PR template で十分では？

Issue / PR template は有効だが、それだけでは AI の実行を制御できない。

PlanGate は、C-3 承認前に production code を編集させない、scope 外編集を検知する、検証証拠を要求する、といった実行時の統制まで含める。

### Q. ただのプロンプト集ですか？

違う。

PlanGate は prompt だけでなく、以下を含む。

- Gate
- Artifact
- Hook Enforcement
- Eval
- Metrics
- Model Profile
- Prompt Assembly
- Workflow DSL
- Handoff

PlanGate はプロンプトではなく、AI エージェントをチーム開発に組み込むための workflow harness である。

## 5. 運用に関する質問

### Q. C-3 / C-4 とは何ですか？

C-3 は実装前の計画承認である。

AI が作った plan、todo、test-cases を人間が確認し、承認する。承認前は本番コードを書けない。

C-4 は実装後のレビュー承認である。

実装、検証結果、handoff を確認し、PR / merge に進めるか判断する。

### Q. 低リスクな修正でも重くなりませんか？

PlanGate は mode によって軽量化する。

小さな修正は ultra-light / light、高リスクな変更は high-risk / critical として扱う。

重要なのは、すべてを重くすることではなく、リスクに応じて承認と検証の深さを変えることである。

### Q. AI が plan を作るなら、結局人間は何を見るのですか？

人間は以下を見る。

- PBI の意図を正しく理解しているか
- scope が広がっていないか
- 受入条件が適切か
- 実装方針に過不足がないか
- リスクが明記されているか
- そのまま実装に進めてよいか

PlanGate は人間の判断をなくすのではなく、判断しやすい形に整える。

## 6. 品質・測定に関する質問

### Q. PlanGate を入れると何が測れるようになりますか？

代表的には以下を測る。

- C-3 approval / conditional / reject
- C-4 approve / request changes
- V-1 first pass rate
- fix loop count
- hook violation rate
- Code Keep Rate
- Plan Keep Rate
- Acceptance Keep Rate
- Handoff usefulness

### Q. Keep Rate とは何ですか？

AI が作った成果物が、一定時間後も残っているかを見る指標である。

PlanGate では code だけでなく、plan、test-cases、handoff も対象にする。

### Q. LLM による満足度判定は使いますか？

将来の soft metric 候補として扱う。

ただし、誤判定があり得るため、release blocker や hard gate にはしない。

## 7. 導入判断に関する質問

### Q. どんなチームに向いていますか？

以下のチームに向いている。

- AI coding agents をチームで使い始めた
- PR レビューで AI の手戻りが増えている
- PBI と実装のズレが気になる
- AI による scope creep を防ぎたい
- 受入条件を実装前に固定したい
- AI 開発の証跡を残したい
- Scrum / PBI / Done と AI 開発を接続したい

### Q. 向いていないケースは？

以下の場合は、PlanGate は重く感じる可能性がある。

- 個人の一時的な実験
- 使い捨てプロトタイプ
- PBI や受入条件が不要な作業
- 完全自律での試行錯誤を優先したい場合
- 証跡や承認境界が不要な場合

## 8. Short answers

| Question | Short answer |
| --- | --- |
| 何をするもの？ | AI がコードを書く前に計画と受入条件を通す |
| なぜ必要？ | 間違ったものを速く作るリスクを下げるため |
| 誰向け？ | AI coding agents を使うプロダクトチーム |
| 何が違う？ | 承認境界、監査可能性、Scrum-friendly delivery を重視する |
| 競合は？ | Cursor / Claude Code / Codex の代替ではなく補完 |
| 一番の価値は？ | PM / PO が守るべき価値、スコープ、Done を AI 開発でも守ること |
