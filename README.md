# 新規プロジェクトの技術検討サンプル

Kiro の機能を使って、新しいアプリの技術検討を進める練習用のリポジトリです。アプリのコードはまだありません。技術を調べて比べ、判断を ADR（設計判断の記録）に残し、Git で共有するところまでを扱います。

データはすべて合成データです。実在の個人情報、顧客名、資格情報、AWS アカウント ID、社内の URL は含みません。AWS へのデプロイは行いません。

## 必要なもの

- Git
- Kiro CLI 2.33 以上（`kiro-cli --v3` で起動できること）

AWS アカウント、Java、Node.js は不要です。ステップ3のツールだけは JDK 11 以上を使います。

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
| Spec | `.kiro/specs/`（ステップ3で作る） | 作るものの要件・設計・タスク。`/spec new` で作り、`/spec run` で実行する |
| Hook | `.kiro/hooks/check-estimate-after-task.json` | Spec の task が終わったら、見積もりプログラムを自動で実行して確かめる |

## 資料の置き場所

| 資料 | 置き場所 |
|---|---|
| 要件 | `docs/requirements/`（月次処理、見積もりツール、オンライン API） |
| 決めることの一覧 | `docs/technology-decision-map.md` |
| ADR（設計判断の記録） | `docs/decisions/`。判断ごとに `template.md` から番号付きのファイルを作る |
| aws-mcp が使えないときの資料 | `docs/evidence/aws-compute-options.md` |

## 当日の流れ

講師が画面で操作します。手元で試せる方は一緒に、あとから試す方は `HANDS-ON.md` の手順で進めてください。

| ステップ | 使う機能 | 内容 |
|---|---|---|
| 1 | Steering、Skill、Plan モード | リポジトリに置いた文脈を見る。月次処理の実行基盤をどう検討するかを、Plan モードで計画する |
| 2 | MCP、ADR、Git | 計画に沿って AWS の事実を確かめ、人が決め、ADR 0001 を作る。確かめて commit する |
| 3 | Quick Spec、Hook | 見積もりツールを Quick Spec で作り、Hook が動くことを確かめる |
| 自分で試す | 同じ流れ | オンライン API の実行基盤を決め、ADR 0002 を作る |

依頼は短く書きます。ルール（Steering）、手順（Skill）、確かめる仕組み（検証スクリプト、Hook）はリポジトリに置いてあります。

## ブランチ

| ブランチ | 内容 |
|---|---|
| `workshop-start` | 開始時の状態。ADR はテンプレート（`docs/decisions/template.md`）だけ |
| `workshop-complete` | 記入例。ADR 0001 と 0002、ステップ3の Spec（`.kiro/specs/monthly-estimate/`）とツール（`tools/MonthlyEstimate.java`） |

## ADR を確かめる

```bash
./scripts/validate-adr.sh docs/decisions/0001-monthly-processing.md
```

見出しがそろっていて本文があるか、テンプレートの書きかけが残っていないか、事実に出典の URL があるかを確かめます。内容が正しいかどうかは確かめません。中身は人が確かめます。

## 見積もりツールを確かめる（ステップ3のあと）

```bash
./scripts/check-estimate.sh
```

サンプルの引数で実行できるか、不正な引数で失敗するかを確かめます。

## ライセンス

MIT License。詳しくは `LICENSE` を見てください。
