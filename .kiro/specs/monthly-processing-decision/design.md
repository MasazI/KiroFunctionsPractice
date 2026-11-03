# 月次処理の実行基盤を決める：設計

## 進め方

1. 要件と Steering を読む。
2. Skill `technology-selection` の手順で、候補を比べる。
3. AWS の事実は aws-mcp で確かめ、出典の URL と確認日を残す。
4. 下の「調査の結果と人の判断」をもとに、ADR のひな形 `docs/decisions/0002-monthly-processing.md` を埋める。

Spec の task は、会話の内容を引き継がないことがあります。そのため、会話で調べた結果と人の判断は、task を実行する前にこのファイルへ書いておきます。

## 調査の結果と人の判断

（デモ2で記入）

## 出力

- `docs/decisions/0002-monthly-processing.md`（ADR）

## 確かめ方

- task が終わると、Hook が `scripts/validate-adr.sh` で ADR の形式を確かめる。
- 最後に人が `git diff` で中身を確かめる。
