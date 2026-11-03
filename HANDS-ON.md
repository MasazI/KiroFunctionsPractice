# ハンズオン：新規プロジェクトの技術検討を Kiro で進める

当日、講師が画面で見せる流れと同じ手順です。手元で試せる方は一緒に、あとから試す方はこの手順で進めてください。

- **所要時間**：約30分（最後の「自分で試す」を除く）
- **必要なもの**：Git、Kiro CLI 2.33 以上（`kiro-cli --v3` で起動できること）。ステップ3だけは JDK 11 以上も使います
- **不要なもの**：AWS アカウント、Node.js

## このハンズオンの考え方

依頼は短く書きます。守ってほしいルール、作業の手順、確かめる仕組みは、リポジトリに置いてあります。

| 毎回の依頼に書かなくてよいこと | 置いてある場所 |
|---|---|
| 事実には出典の URL と確認日を付ける。どれを選ぶかは人が決める | Steering（`.kiro/steering/technology-selection.md`） |
| 依頼に関係のないファイルは変えない。commit と push は人が指示したときだけ | Steering（`.kiro/steering/product.md`）と許可の画面 |
| 調べる → 比べる → 人に聞く → ADR を作る → 確かめる、の手順 | Skill（`.kiro/skills/technology-selection/SKILL.md`） |
| ADR の書き方とファイル名 | テンプレート（`docs/decisions/template.md`）と、要件の「記録先」 |
| ADR とツールの確認 | ADR の形式チェック（`scripts/validate-adr.sh`）と、ツールの受け入れテスト（`scripts/check-estimate.sh`。Hook が Kiro に実行を頼む） |

Kiro の答えや質問は、毎回少しずつ変わります。質問されたら、自分の考えで短く答えてください。そこが人が判断を足す場面です。

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
| Hooks | `check-estimate-on-save` |
| MCP | `aws-mcp` が `running` |

入力欄で先頭に `!` を付けると、Kiro を通さずにシェルのコマンドを実行できます。

## 許可の仕方

Kiro は、ファイルを作る・変える前や、コマンドやツールを実行する前に、許可を求めます。

- 内容を読み、頼んだ範囲の中なら1回だけ許可します。「常に許可」は選びません
- 範囲の外なら拒否し、理由を伝えます
- 途中で止めたいときは `Esc` を押します

## ステップ1：文脈を見て、Plan モードで計画する

### (1) リポジトリに置いてあるものを見る

```text
!cat .kiro/steering/product.md
!cat .kiro/skills/technology-selection/SKILL.md
!cat docs/requirements/monthly-processing.md
```

- **Steering**：毎回読み込まれるルールです。先頭の `inclusion: always` がその指定です
- **Skill**：手順書です。依頼が description と合ったとき、または `/technology-selection` と名前で呼んだときに読み込まれます
- **要件**：今回決めることと、満たすべき条件です。ADR の「記録先」も書いてあります

### (2) Plan モードで計画を頼む

```text
/plan 月次処理をどの実行基盤で動かすか検討したいです。進め方を計画してください。
```

Plan モードでは、ファイルの書き込み、コマンドの実行、MCP は使えません。Kiro は読んで考えるだけです。

Kiro が質問してきたら、短く答えます。分からないことは「まだ分からない」と答えて構いません。Kiro はそれを未確認の事項として扱います。

### (3) 計画を確かめて、承認する

計画を読み、手順に納得できたら承認します。承認すると Plan モードが終わり、Kiro が計画に沿って作業を始めます。直したいところがあれば、承認する前に伝えます。

## ステップ2：確かめて、決めて、ADR に残す

承認したあと、Kiro は Skill の手順に沿って進みます。人がするのは、許可と、質問への答えと、最後の確認です。

### (1) AWS の事実を確かめる（MCP）

Kiro が aws-mcp のツールを実行してよいか聞いてきます。内容を読んで許可します。AWS アカウントは要りません（文書検索とリージョン確認だけを使う設定です）。

### (2) どれにするかを決める

Kiro が候補を比べ、どれにするかを聞いてきます。自分で決めて答えます。

答えの例：

```text
次は AWS Batch で技術検証します。4時間以内に多数の対象を処理し、失敗した部分だけを再実行する必要があるためです。
```

### (3) ADR を作らせる

Kiro がテンプレート（`docs/decisions/template.md`）から、要件の記録先 `docs/decisions/0001-monthly-processing.md` を作ってよいか聞いてきます。対象のファイルを確かめて許可します。

**ADR**（Architecture Decision Record）は設計判断の記録です。判断が出るたびに、テンプレートから番号付きのファイルを作ります。見出しの意味は `docs/decisions/README.md` にあります。

### (4) ADR の形式チェックで確かめる

Kiro が `scripts/validate-adr.sh` の実行を求めてきたら許可します。このスクリプトは、ADR の形式を機械的に確かめます。

1. 7つの見出しがそろっていて、どの見出しの下にも本文がある
2. テンプレートの書きかけ（`NNNN` など）が残っていない
3. 「確認した事実と出典」に出典の URL がある

ADR は判断の記録なので、書いた内容がよいかどうかは確かめません。そこは人が見ます。

### (5) 中身を自分の目で確かめる

```text
!git status --short
!cat docs/decisions/0001-monthly-processing.md
```

新しく作られたファイルは `git diff` に出ないので、`git status` で一覧してから中身を表示します。

確かめること：作られたのは ADR だけ。事実に出典の URL と確認日がある。事実と推論が分かれている。最終決定ではなく、次に技術検証する候補として書かれている。

直したいところがあれば、そのまま Kiro に頼みます。

### (6) 記録を残す

```text
commit してください。
```

```text
!git log --oneline -3
```

チームで共有するときは、自分のリポジトリ（fork など）に push します。配布用のリポジトリには push できません。

## ステップ3：テストを先に置き、小さなツールをチャットで作る

JDK 11 以上が必要です。`java -version` で確かめてください。

このサンプルには、ツールより先に受け入れテスト（`scripts/check-estimate.sh`）が置いてあります。期待する値は、要件から決めてあります。たとえば、100万件を1000件ずつ20並列、1チャンク120秒で処理すると「1時間40分00秒 → 収まる」、ちょうど4時間は「収まる」、などです。

もう1つ、Hook（`.kiro/hooks/check-estimate-on-save.json`）が入っています。Kiro が `tools/` の Java ファイルを作ったり変えたりするたびに、Hook が Kiro にテストの実行を頼みます。失敗したら、Kiro はテストを変えずに、要件に沿ってツールを直します。

### (1) 要件を見る

```text
!cat docs/requirements/monthly-estimate.md
```

作るのは、件数と処理時間を渡すと、月次処理が4時間に収まりそうかを表示する小さなツールです。要件と出力の形が決まっていて小さいので、Spec は使わずにチャットで頼みます。

### (2) テストを先に動かして、失敗を確かめる

```text
!./scripts/check-estimate.sh
```

まだツールがないので、`NG：tools/MonthlyEstimate.java がありません` と出て失敗します。先に失敗を確かめ、作ったあとに合格させる、テスト駆動の進め方です。

### (3) チャットで頼む

```text
月次処理が4時間で終わりそうかを、件数と処理時間から計算する小さなツールを作りたいです。要件は docs/requirements/monthly-estimate.md にあります。
```

Kiro が質問してきたら、自分の考えで短く答えます。ファイルの作成を求められたら、対象が `tools/MonthlyEstimate.java` であることを確かめて許可します。

ファイルが保存されると Hook が動き、Kiro が `./scripts/check-estimate.sh` の実行を求めてきます。許可します。

### (4) 成功を3つの確認で判断する

| 確認 | 見る場所 | 成功の条件 |
|---|---|---|
| Kiro の報告 | チャットの返答 | 作ったファイルと、テストの結果が書かれている |
| 自動の検証 | 受け入れテストの出力 | `試算ツールのテストに合格しました` |
| 人の確認 | `!git status --short`、`!cat tools/MonthlyEstimate.java`、下のコマンド | 増えたのは `tools/MonthlyEstimate.java` だけ。結果が手で計算した値と合う |

自分の数字で動かし、テストの期待値が要件どおりかを手で確かめます。

```text
!java tools/MonthlyEstimate.java 1000000 1000 120 20
```

1000000件 ÷ 1000件 ＝ 1000チャンク、1000 ÷ 20 ＝ 50回、50回 × 120秒 ＝ 6000秒 ＝ 1時間40分です。テストが確かめるのは、テストに書いた例だけです。足りない例に気付いたら、テストに足します。

### うまくいかないとき

完成例のツールに差し替えて、テストだけ試せます。

```bash
git checkout workshop-complete -- tools/MonthlyEstimate.java
./scripts/check-estimate.sh
```

### このあと、ふつうはどう進めるか

1. ツールを commit します
2. 試算の結果を ADR-0001 の「未確認の事項と技術検証」に足すよう、Kiro に頼みます。4時間に余裕がなければ、「見直す条件」に照らして候補を比べ直します
3. 「AWS Batch で技術検証する計画を立てて」と、Plan モードで頼みます
4. 検証用や本番のコードを作る段階では、要件と ADR を参照して Feature Spec を作ります。不具合は Bugfix Spec で直します
5. テストの方針（テストのフレームワークとコマンド、先に失敗するテストを書くこと、テストの量の目安）を Steering に書きます。Kiro はそれに沿ってテストを作ります
6. Kiro が同じ間違いをしたら Steering に1行足します。同じ確認を毎回頼んでいたら Hook にします。チームでは CI にも同じテストを置きます

## 自分で試す：オンライン API の実行基盤

同じ流れを、別の論点で試します。要件は `docs/requirements/online-api.md`、記録先は `docs/decisions/0002-online-api-runtime.md` です。

```text
/technology-selection オンライン API の実行基盤を決めたいです。
```

Skill を名前で呼ぶと、その手順が読み込まれます。あとはステップ2と同じように、許可し、質問に答え、最後に中身を確かめます。

## やり直すとき

```bash
git restore .
git clean -n                  # 消えるファイルを先に確認する
git clean -f -d               # 確認できたら消す
git switch workshop-start
git reset --hard origin/workshop-start   # commit も取り消す（手元の commit は消える）
```

## うまくいかないとき

| 症状 | 対処 |
|---|---|
| `/config` に Steering や Skill が出ない | workspace を信頼していません。Kiro を終了して起動し直し、「Trust, continue」を選びます |
| `aws-mcp` が `running` にならない | ネットワークの制限が考えられます。「docs/evidence/aws-compute-options.md を使ってください」と伝えます |
| 計画を承認しても、Kiro が人に聞かずに ADR を作ろうとする | 許可を拒否し、「どれにするかは私が決めます。候補を比べて聞いてください」と伝えます |
| 検証で「見出しがありません」と出る | 「見出しは docs/decisions/template.md のとおりに戻してください」と伝えます |
| 検証で「書きかけが残っています」「見出しの下が空です」と出る | 表示された箇所を埋めるよう Kiro に伝えます |
| Kiro が範囲外の作業を始めた | `Esc` で止めるか、許可を拒否します。変更が残ったら「やり直すとき」の手順で戻します |

## 正解の例

`workshop-complete` ブランチに、ADR 0001 と 0002 の記入例と、ステップ3のツールがあります。

```bash
git switch workshop-complete
```
