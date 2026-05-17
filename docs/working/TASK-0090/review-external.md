# V-3 外部レビュー（Codex）— TASK-0090 / #224

## 結果サマリ
critical: 0 / major: 3 / minor: 3 / info: 1（初回 NOT APPROVE → 全反映）

## 指摘と対応
| ID | severity | 指摘 | 対応 |
|----|----------|------|------|
| MJ-1 | major | strip-components=2 だと .plangate-plugin/plangate/<kind> に展開され §3/§4 の .plangate-plugin/<kind> 前提と不整合 | strip-components=3 に修正（plangate-<ver>/plugin/plangate の 3 段除去）+ 説明追記 |
| MJ-2 | major | versioning-stability-policy.md が本ブランチに未存在で中核仕様が壊れリンク依存 | 「予定正本（#225/#263・マージ順依存）」明記 + §1 に安定性レベル定義を自己完結内挿 + §4-bis マージ順記録（推奨 #263→本PR） |
| MJ-3 | major | 表は hooks 不可だが注記は rules/hooks を C-3 承認で許容と読め矛盾 | hooks は C-3 承認があっても overlay 不可（settings 適用プロセスで扱う）と分離、C-3 例外は rules のみに限定 |
| mn-1 | minor | §2.3 検証パスが plugin/plangate/.claude-plugin/...（消費側は .plangate-plugin/...）| 検証パスを .plangate-plugin/.claude-plugin/plugin.json に修正 |
| mn-2 | minor | curl|tar の安全性説明不足 | 固定タグ必須 + tar -tz 事前確認 + signature/commit 確認の安全性注記追加 |
| mn-3 | minor | .plangate-version(vX.Y.Z) と plugin.json(0.5.0) の突合ルール未定義 | バージョン 2 軸表を追加（リリースタグ=固定単位/真、plugin 内部版=情報用、CI はタグを真に突合）|
| info | info | archive 内パス自体は整合（strip 値のみ問題）| MJ-1 で解消 |

## 判定
major 3 / minor 3 を全反映。critical 0。回帰 V-1 全 PASS（T1-T6+E1/E2、MJ-1 strip/mn-1 path 確認）。
