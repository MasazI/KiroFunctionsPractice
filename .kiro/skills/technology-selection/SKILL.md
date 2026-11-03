---
name: technology-selection
description: 新規プロジェクトで、1つの論点について2～3個の技術の候補を比べ、判断を ADR に残すときに使う手順。決める順番を計画するだけのときは使わない。
---

# 技術選定の手順

## 使う場面

フレームワーク、実行基盤、AWS のサービスなど、技術の候補を比べて決めるとき。

## 手順

1. 決めること、要件、制約を確認する。`.kiro/steering/`、`docs/technology-decision-map.md`、関係する Spec を読む。
2. 候補を2～3個に絞り、比べる観点を決める。
3. 事実を公式の情報で確かめる。AWS のことは aws-mcp を使う。出典の URL と確認日を残す。
4. 「確認した事実」「このプロジェクトへの推論」「未確認の事項」を分けて、比べた結果をまとめる。
5. どれを選ぶかは人に聞く。Kiro は判断が変わる条件を示し、1つに決めつけない。
6. 人の判断をもとに、`docs/decisions/` の ADR のひな形を埋める。見出しは変えない。
7. `scripts/validate-adr.sh <ADR のパス>` で、ADR の形式を確かめる。
8. 人に `git diff` で中身を確かめてもらう。

## ADR の見出し（変えない）

- `## Context（背景）`
- `## Options considered（比較した選択肢）`
- `## Verified facts and sources（確認した事実と出典）`
- `## Project-specific inference（このプロジェクトへの推論）`
- `## Decision（判断）`
- `## Unknowns and validation（未確認の事項と技術検証）`
- `## Revisit conditions（見直す条件）`
