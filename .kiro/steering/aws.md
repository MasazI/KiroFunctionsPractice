---
inclusion: auto
name: aws-research
description: AWS のサービス、制限値、リージョンでの提供状況を調べるときに使う
---

# AWS を調べるときのルール

- aws-mcp の文書検索（`aws___search_documentation`、`aws___read_documentation`）と、リージョン確認（`aws___get_regional_availability`）を使います。
- リージョンは東京（ap-northeast-1）を前提にします。
- 制限値や提供状況は変わることがあるので、出典の URL と確認日を残します。
- AWS の API を実行するツールや、リソースを作る・変えるコマンドは使いません。
- aws-mcp が使えないときは `docs/evidence/aws-compute-options.md` を使い、その旨を書きます。
