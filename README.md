# 新規プロジェクトの技術検討サンプル

Kiro の機能を使って、新しいアプリの技術検討を進める練習用のリポジトリです。アプリのコードはまだありません。技術を調べて比べ、判断を ADR（設計判断の記録）に残し、Git で共有するところまでを扱います。

データはすべて合成データです。実在の個人情報、顧客名、資格情報、AWS アカウント ID、社内の URL は含みません。AWS へのデプロイは行いません。

## 必要なもの

- Git
- Kiro CLI 2.33 以上（`kiro-cli --v3` で起動できること）

AWS アカウント、Java、Node.js は不要です。デモ4の小さなプログラムだけは JDK 11 以上を使います（講師が実行します）。

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
| Skill | `.kiro/skills/technology-selection/` | 技術選定の手順書。`/technology-selection` で呼び出す |
| MCP | `.kiro/settings/mcp.json` | 外の情報を調べる道具。AWS MCP Server の文書検索とリージョン確認だけを使う（認証不要） |
| Spec | `.kiro/specs/monthly-processing-decision/` | 1件の作業の要件・設計・タスク。`/spec run` で実行する |
| Hook | `.kiro/hooks/validate-adr-after-task.json` | Spec の task が終わったら、ADR の形式を自動で確かめる |
| ADR | `docs/decisions/` | 設計判断の記録。判断・理由・見直す条件を残す |

## 当日の流れ

| 場面 | 使う機能 | 内容 |
|---|---|---|
| デモ1 | Plan モード、Steering | 技術検討で決めることと、決める順番を計画する。ファイルは変えない |
| デモ2 | Skill、MCP | 月次処理の実行基盤を比べ、人が判断する。判断を Spec に書き足す |
| デモ3 | Spec、Hook | Spec の task で ADR 0002 を書く。Hook が ADR を確かめ、人が `git diff` で確かめる。commit して共有する |
| デモ4 | 小さなプログラム | ADR の見積もりを、Java の1ファイルのプログラムで計算する |
| 演習 | Steering、Skill、MCP | オンライン API の実行基盤を比べ、ADR 0003 を書く。手順は `LAB.md` |

## ブランチ

| ブランチ | 内容 |
|---|---|
| `workshop-start` | 開始時の状態。ADR はひな形のまま |
| `workshop-complete` | 記入例。ADR 0002 と 0003、デモ4のプログラムが入っている |

## ADR を確かめる

```bash
./scripts/validate-adr.sh docs/decisions/0002-monthly-processing.md
```

見出しがそろっているか、「ここに記入」などの書きかけが残っていないか、事実に出典の URL があるかを確かめます。内容が正しいかどうかは確かめません。中身は人が `git diff` で確かめます。
