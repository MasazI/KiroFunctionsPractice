# 新規プロジェクトの技術検討サンプル

Kiro の機能を使って、新しいアプリの技術検討を進める練習用のリポジトリです。アプリのコードはまだありません。技術を調べて比べ、判断を ADR（設計判断の記録）に残し、Git で共有するところまでを扱います。

データはすべて合成データです。実在の個人情報、顧客名、資格情報、AWS アカウント ID、社内の URL は含みません。AWS へのデプロイは行いません。

## 必要なもの

- Git
- Kiro CLI 2.33 以上（`kiro-cli --v3` で起動できること）

AWS アカウント、Java、Node.js は不要です。デモ3のプログラムだけは JDK 11 以上を使います（講師が実行します）。

## 始め方

```bash
git clone <共有された URL> sample-project
cd sample-project
git switch workshop-start
kiro-cli --v3
```

最初に「Trust this workspace?」と表示されたら、配布元を確認してから「Trust, continue」を選びます。信頼するまで、Steering、Skill、Hook、MCP は読み込まれません。

## Kiro の機能とファイルの置き場所

| 機能 | 置き場所 | 役割 |
|---|---|---|
| Steering | `.kiro/steering/` | いつも守るルール。毎回自動で読み込まれる |
| Skill | `.kiro/skills/technology-selection/` | 技術選定の手順書。依頼が説明と合うと読み込まれる。`/technology-selection` で呼び出すこともできる |
| MCP | `.kiro/settings/mcp.json` | 外の情報を調べる道具。AWS MCP Server の文書検索とリージョン確認だけを使う（認証不要） |
| Spec | `.kiro/specs/`（デモ3で作る） | 作るものの要件・設計・タスク。`/spec new` で作り、`/spec run` で実行する |
| Hook | `.kiro/hooks/check-estimate-after-task.json` | Spec の task が終わったら、見積もりプログラムを自動で実行して確かめる |

## 資料の置き場所

| 資料 | 置き場所 |
|---|---|
| 要件 | `docs/requirements/`（月次処理、オンライン API） |
| 決めることの一覧 | `docs/technology-decision-map.md` |
| ADR（設計判断の記録） | `docs/decisions/`。判断・理由・見直す条件を残す |
| aws-mcp が使えないときの資料 | `docs/evidence/aws-compute-options.md` |

## 当日の流れ

| 場面 | 使う機能 | 内容 |
|---|---|---|
| デモ1 | Steering、Skill、Plan モード | Steering と Skill の中身を見る。月次処理の実行基盤をどう検討するかを、Plan モードで計画する。ファイルは変わらない |
| デモ2 | MCP、ADR、Git | 計画に沿って AWS の事実を確かめ、人が判断し、ADR 0001 を書く。検証して commit する（共有するときは push） |
| デモ3 | Spec、Hook | ADR の技術検証の前に、所要時間を机上で見積もるプログラムを Spec で作る。Hook がプログラムを実行して確かめる |
| 演習 | Steering、Skill、MCP | オンライン API の実行基盤を比べ、ADR 0002 を書く。手順は `LAB.md` |

デモ1～3を自分で試す手順は `DEMO.md`、演習の手順は `LAB.md` にあります。

## ブランチ

| ブランチ | 内容 |
|---|---|
| `workshop-start` | 開始時の状態。ADR はひな形のまま |
| `workshop-complete` | 記入例。ADR 0001 と 0002、デモ3の Spec（`.kiro/specs/monthly-estimate/`）とプログラム（`tools/MonthlyEstimate.java`） |

## ADR を確かめる

```bash
./scripts/validate-adr.sh docs/decisions/0001-monthly-processing.md
```

見出しがそろっているか、「ここに記入」などの書きかけが残っていないか、事実に出典の URL があるかを確かめます。内容が正しいかどうかは確かめません。中身は人が `git diff` で確かめます。

## 見積もりプログラムを確かめる（デモ3のあと）

```bash
./scripts/check-estimate.sh
```

サンプルの引数で実行できるか、不正な引数で失敗するかを確かめます。

## ライセンス

MIT License。詳しくは `LICENSE` を見てください。
