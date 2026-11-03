# ADR（設計判断の記録）

ADR（Architecture Decision Record）は、設計の判断を1件ずつ文書に残すものです。何を、なぜ、どの条件で決めたかを残しておくと、あとから入った人も判断の理由を追えます。判断を見直すときの基準にもなります。

## 作り方

判断が出るたびに、`template.md` をもとに番号付きのファイルを新しく作ります。

- ファイル名：`NNNN-短い名前.md`（例：`0001-monthly-processing.md`）
- 見出しは変えません。`scripts/validate-adr.sh` が見出しの文字列で確かめるためです
- 要件（`docs/requirements/`）に「記録先」があれば、そのファイル名で作ります。Skill の手順にこの決まりが書いてあるので、Kiro に頼むときにファイル名を伝える必要はありません

## このサンプルで作る ADR

| 番号 | 内容 | 作る場面 |
|---|---|---|
| 0001 | 月次処理の実行基盤 | ステップ2（HANDS-ON.md） |
| 0002 | オンライン API の実行基盤 | 自分で試す（HANDS-ON.md） |

記入例は `workshop-complete` ブランチにあります。

## 見出し

| 見出し | 書くこと |
|---|---|
| Context（背景） | なぜこの判断が必要か |
| Options considered（比較した選択肢） | 比べた候補 |
| Verified facts and sources（確認した事実と出典） | 公式の情報で確かめた事実。出典の URL と確認日を付ける |
| Project-specific inference（このプロジェクトへの推論） | 事実と要件から、このプロジェクトについて考えたこと |
| Decision（判断） | 人が決めたこと。最終決定でなければ、その旨を書く |
| Unknowns and validation（未確認の事項と技術検証） | まだ分からないこと。技術検証で何を測り、どうなれば合格か |
| Revisit conditions（見直す条件） | どうなったら判断を変えるか |

## 形式チェック（validate-adr.sh）が確かめること

`./scripts/validate-adr.sh docs/decisions/0001-monthly-processing.md`

1. 7つの見出しがそろっていて、どの見出しの下にも本文がある
2. テンプレートの書きかけ（`NNNN`、`YYYY-MM-DD` など）が残っていない
3. 「確認した事実と出典」に出典の URL がある

書いた内容が正しいかどうかは確かめません。中身は人が確かめます。
