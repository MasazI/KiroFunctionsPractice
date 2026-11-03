# デモの手順（自分で試す人向け）

当日のデモ1～3を、自分の PC で同じように試すための手順です。演習の手順は `LAB.md` にあります。

- **所要時間**：約30分
- **必要なもの**：Git、Kiro CLI 2.33 以上（`kiro-cli --v3` で起動できること）。デモ3だけは JDK 11 以上も使います
- **不要なもの**：AWS アカウント、Node.js

Kiro の答えは毎回少しずつ変わります。表や文の細かな違いは気にせず、流れを確かめてください。

## 0. 準備

```bash
git clone <共有された URL> sample-project
cd sample-project
git switch workshop-start
kiro-cli --v3
```

「Trust this workspace?」と表示されたら、配布元を確認してから「Trust, continue」を選びます。

普段使っている Kiro の個人の設定（ホームの `~/.kiro/` にある Steering、Skill、MCP など）も一緒に読み込まれます。当日と違う動きになったときは、個人の設定を読み込まない別のフォルダを指定して起動してみてください（Kiro の環境変数 `KIRO_HOME`）。

```bash
KIRO_HOME="$HOME/kiro-try" kiro-cli --v3
```

起動したら、読み込まれた設定を確かめます。

```text
/config
```

| 項目 | 期待する表示 |
|---|---|
| Steering | `product`、`technology-selection`、`aws-research`。ほかに Kiro に最初から入っている `architecture-selection`、`quick-spec`、`bug-fix` |
| Skills | `technology-selection` |
| Hooks | `check-estimate-after-spec-task` |
| MCP | `aws-mcp` が `running` |

入力欄で先頭に `!` を付けると、Kiro を通さずにシェルのコマンドを実行できます。以下の `!cat` などはそのための書き方です。

## デモ1：文脈を見て、Plan モードで計画する

### (1) Steering と Skill の中身を見る

```text
!cat .kiro/steering/product.md
!cat .kiro/skills/technology-selection/SKILL.md
```

- **Steering**：毎回読み込まれるルールです。先頭の `inclusion: always` がその指定です
- **Skill**：手順書です。依頼が description と合ったとき、または `/technology-selection` と名前で呼んだときに読み込まれます

### (2) 要件を見る

```text
!cat docs/requirements/monthly-processing.md
```

### (3) Plan モードで計画する

```text
/plan
```

入力欄に `[plan]` が出たら、次を入力します。

```text
月次処理の実行基盤を決めるために、何を調べ、どう比べ、どこに記録するかを計画してください。
要件は docs/requirements/monthly-processing.md にあります。どれを採用するかは決めません。
質問はせず、分からない点は仮定として書いてください。手順の表1つにまとめてください。
```

Plan モードでは、ファイルの書き込み、コマンドの実行、MCP は使えません。そのため、ファイルは変わりません。

### (4) Plan モードを出る

計画が表示されたら、すぐに出ます。

- 計画を承認するか聞かれたら、承認せずに `Esc` で閉じます。承認すると、そのまま実行が始まります
- `Shift+Tab` を押し、入力欄から `[plan]` が消えたことを確かめます

会話はそのまま続けます。

## デモ2：確かめて、決めて、ADR に残す

### (1) MCP で事実を確かめる

```text
計画に沿って進めます。まず aws-mcp を使って次の2点を確かめてください。ファイルはまだ変更しないでください。
1. 標準の AWS Lambda 関数のタイムアウトの上限
2. 東京リージョン（ap-northeast-1）で、AWS Lambda、Amazon ECS、AWS Fargate、AWS Batch が使えるか
それぞれ出典の URL と確認日を付けてください。
```

ツールを実行してよいか聞かれたら、内容を読んでから1回だけ許可します。「常に許可」は選びません。

### (2) ADR のひな形と検証スクリプトを知る

```text
!cat docs/decisions/0001-monthly-processing.md
```

- **ADR のひな形**：ADR（Architecture Decision Record）は設計判断の記録です。見出しが7つあり、その下が「ここに記入」になっています。見出しの意味は `docs/decisions/README.md` にあります
- **ADR の検証スクリプト（`scripts/validate-adr.sh`）**：書き上がった ADR の形式を機械的に確かめる、小さなスクリプトです。確かめるのは、(1) 7つの見出しがそろっているか、(2) 「ここに記入」などの書きかけが残っていないか、(3) 「確認した事実と出典」に出典の URL があるか、の3つです。書いた内容が正しいかどうかは確かめないので、そこは人が `git diff` で見ます
- Skill の手順7に、このスクリプトで確かめることが書いてあります。そのため、Kiro が自分から実行を提案することがあります

### (3) 判断して、ADR に書かせる

括弧の中は、自分の判断と理由に書き換えて構いません。

```text
月次処理は、次に（AWS Batch）で技術検証することにします。
理由：（4時間以内に多数の対象を処理する必要があり、失敗した部分の再実行も必要なため）。
この判断と、さきほど確認した事実をもとに、ADR のひな形 docs/decisions/0001-monthly-processing.md の「ここに記入」を埋めてください。
変更してよいのはこのファイルだけです。
```

ファイルを変更してよいか聞かれたら、対象が `docs/decisions/0001-monthly-processing.md` であることを確かめてから許可します。

### (4) ADR を検証する

```text
ADR の検証スクリプト scripts/validate-adr.sh で docs/decisions/0001-monthly-processing.md を確かめて、結果を教えてください。
```

`ADR の検証に合格しました` と表示されれば合格です。Kiro が手順(3)のあとに自分から実行していたら、この入力は省きます。

### (5) 差分を確かめる

```text
!git status --short
!git diff
```

確かめること：変わったのは ADR だけ。事実に出典の URL と確認日がある。事実と推論が分かれている。最終決定ではなく、次に技術検証する候補として書かれている。

### (6) commit する

```text
いまの変更を commit してください。メッセージは「ADR-0001 月次処理の実行基盤を記録」にしてください。push はしないでください。
```

commit できたら、記録が残ったことを確かめます。

```text
!git log --oneline -3
```

チームで共有するときは、自分のリポジトリ（fork など）に push します。配布用のリポジトリには push できません。

## デモ3：小さなプログラムを Quick Spec で作る

JDK 11 以上が必要です。`java -version` で確かめてください。

このサンプルには Hook（`.kiro/hooks/check-estimate-after-task.json`）が入っています。Spec の task が終わると、Hook が確認用のスクリプト `scripts/check-estimate.sh` を実行します。スクリプトは、できたプログラムをサンプルの引数で動かし、間違った引数ではちゃんと失敗することを確かめます。`/hooks` で一覧を見られます。

### (1) Spec を作る

```text
/spec new monthly-estimate
```

種類を聞かれたら `Quick Spec` を選び、次を伝えます。

```text
ADR-0001 の技術検証の前に、月次処理の所要時間を机上で見積もる Java のプログラムを作ります。
- ファイル：tools/MonthlyEstimate.java の1ファイル。外部ライブラリなし、Java 11 で java tools/MonthlyEstimate.java として実行できる
- 引数：総件数、1チャンクの件数、1チャンクの処理秒数、同時に動かす数
- 表示：チャンクの数、全体の処理時間が4時間に収まるか、1チャンクが標準の Lambda の上限15分に収まるか
- 引数が足りない、または1以上の整数でないときは、使い方を表示して0以外で終了する
- キューでの待ち、起動、再実行の時間は含まないことを表示する
```

### (2) 3つの文書を見る

```text
/spec view monthly-estimate requirements
/spec view monthly-estimate design
/spec view monthly-estimate tasks
```

### (3) 実行する

```text
/spec run monthly-estimate
```

「Choose which tasks to run」では `1. Run required tasks (recommended)` を選びます。ファイルの作成を求められたら、対象を確かめて許可します。途中で止めたいときは `Esc`、実行を取り消すときは `Ctrl+C` です。

### (4) 成功を3つの確認で判断する

| 確認 | 見る場所 | 成功の条件 |
|---|---|---|
| Kiro の報告 | タスク実行画面 | `1/1 complete` |
| 自動の検証 | Hook の結果 | `見積もりプログラムの確認に合格しました` |
| 人の確認 | `!git status --short`、`!cat tools/MonthlyEstimate.java` | 増えたのは `.kiro/specs/monthly-estimate/` と `tools/MonthlyEstimate.java` だけ |

新しく作られたファイルは `git diff` に出ないので、`git status` で一覧します。Hook の確認は、手で `./scripts/check-estimate.sh` を実行しても同じです。

### うまくいかないとき

Quick Spec がうまく作れなかったら、完成例の Spec を使って実行だけ試せます。

```bash
git checkout workshop-complete -- .kiro/specs/monthly-estimate
sed -i '' 's/- \[x\]/- [ ]/' .kiro/specs/monthly-estimate/tasks.md   # Linux では sed -i 's/...'
```

そのあと `/spec run monthly-estimate` を実行します。

## やり直すとき

```bash
git restore .
git clean -n                  # 消えるファイルを先に確認する
git clean -f -d               # 確認できたら消す
git switch workshop-start
git reset --hard origin/workshop-start   # デモ2の commit も取り消す（手元の commit は消える）
```

## 正解の例

`workshop-complete` ブランチに、ADR 0001 の記入例、デモ3の Spec とプログラムがあります。

```bash
git switch workshop-complete
```

続けて演習を試すときは `LAB.md` へ進んでください。
