# 演習：オンライン API の実行基盤を ADR に残す

Steering、Skill、MCP を使って技術の候補を調べて比べ、判断を ADR（設計判断の記録）に残します。当日は講師が画面で操作します。手元で試せる方は一緒に、あとから試す方はこの手順のとおりに進めてください。

- **所要時間**：約15分
- **必要なもの**：Git、Kiro CLI 2.33 以上。AWS アカウント、Java、Node.js は不要です
- **作るファイル**：`docs/decisions/0002-online-api-runtime.md` だけ

## 題材

新しい業務アプリのオンライン API（Java）を、どこで動かすかを決めます。

| 候補 | 一言で |
|---|---|
| Amazon ECS（AWS Fargate） | コンテナを常に動かしておく |
| AWS Lambda（SnapStart） | リクエストが来たときだけ関数を動かす。SnapStart で起動を速くする |

この演習では、最終決定はしません。「次にどちらを技術検証するか」を決めます。

## 0. 準備

```bash
git clone <共有された URL> sample-project
cd sample-project
git switch workshop-start
kiro-cli --v3
```

「Trust this workspace?」と表示されたら、配布元を確認してから「Trust, continue」を選びます。

## 1. 読み込まれた設定を確かめる

Kiro の入力欄に次を入力します。

```text
/config
```

| 項目 | 期待する表示 |
|---|---|
| Steering | `product`、`technology-selection`、`aws-research` の3件。ほかに Kiro に最初から入っている `architecture-selection`、`quick-spec`、`bug-fix` |
| Skills | `technology-selection` の1件 |
| MCP | `aws-mcp` が `running` |

`Esc` で閉じます。

## 2. 要件と ADR のテンプレートを見る

入力欄で先頭に `!` を付けると、Kiro を通さずにシェルのコマンドを実行できます。

```text
!cat docs/requirements/online-api.md
!cat docs/decisions/template.md
```

1つ目が要件、2つ目が ADR のテンプレートです。判断が出るたびに、このテンプレートをもとに番号付きの ADR を新しく作ります。この演習では `docs/decisions/0002-online-api-runtime.md` を作ります。

## 3. Skill を呼び出す

```text
/technology-selection
```

技術選定の手順書が読み込まれます。中身は `!cat .kiro/skills/technology-selection/SKILL.md` で見られます。Kiro が「何を決めるか」を聞いてきたら、次の手順4の入力で答えます。

## 4. MCP で事実を確かめる

```text
要件 docs/requirements/online-api.md にあるオンライン API の実行基盤を決めます。
aws-mcp を使って次の3点を確認してください。ファイルはまだ変更しないでください。
1. AWS Lambda の SnapStart が対応している Java のバージョン
2. 標準の AWS Lambda 関数のタイムアウトの上限
3. 東京リージョン（ap-northeast-1）で、AWS Fargate と Lambda SnapStart が使えるか
それぞれ出典の URL と確認日を付けてください。
```

ツールを実行してよいか聞かれたら、内容を読んでから1回だけ許可します。「常に許可」は選びません。

## 5. 判断して、ADR を作らせる

括弧の中は、自分の判断と理由に書き換えて構いません。

```text
オンライン API は、次に（Amazon ECS（AWS Fargate））で技術検証することにします。
理由：（業務時間中ずっと使われ、データベースへの接続数を一定に保ちやすいため）。
この判断と、さきほど確認した事実をもとに、テンプレート docs/decisions/template.md から、新しい ADR docs/decisions/0002-online-api-runtime.md を作ってください。
作ってよいのはこのファイルだけです。
```

ファイルを作ってよいか聞かれたら、対象が `docs/decisions/0002-online-api-runtime.md` であることを確かめてから許可します。

## 6. ADR を検証する

```text
ADR の検証スクリプト scripts/validate-adr.sh で docs/decisions/0002-online-api-runtime.md を確かめて、結果を教えてください。
```

コマンドを実行してよいか聞かれたら許可します。`ADR の検証に合格しました` と表示されれば合格です。

検証スクリプトが確かめるのは、次の3つです。内容が正しいかどうかは確かめません。

- 7つの見出しがそろっていて、どの見出しの下にも本文がある
- テンプレートの書きかけ（`NNNN`、`YYYY-MM-DD` など）が残っていない
- 「確認した事実と出典」に出典の URL がある

## 7. 中身を自分の目で確かめる

```text
!git status --short
!cat docs/decisions/0002-online-api-runtime.md
```

新しく作られたファイルは `git diff` に出ないので、`git status` で一覧してから中身を表示します。

確かめること：

- 作られたのは `docs/decisions/0002-online-api-runtime.md` だけ
- 事実に出典の URL と確認日が付いている
- 「確認した事実」と「このプロジェクトへの推論」が分かれている
- 最終決定ではなく、次に技術検証する候補として書かれている

## 8. （任意）commit して共有する

```text
いまの変更を commit してください。メッセージは「ADR-0002 オンライン API の実行基盤を記録」にしてください。push はしないでください。
```

チームで共有するときは、自分のリポジトリ（fork など）に push します。この配布用リポジトリには push できません。

## やり直すとき

```bash
git restore .
git clean -n         # 消えるファイルを先に確認する（作った ADR など）
git clean -f -d      # 確認できたら消す
git status --short   # 何も表示されなければ元どおり
```

commit した後にやり直すときは、`git switch workshop-start` のあと `git reset --hard origin/workshop-start` を実行します。手元の commit は消えるので、残したい場合は先に別のブランチを作ってください。

## うまくいかないとき

| 症状 | 対処 |
|---|---|
| `/config` に Steering や Skill が出ない | workspace を信頼していません。Kiro を終了して起動し直し、「Trust, continue」を選びます |
| `aws-mcp` が `running` にならない | ネットワークの制限が考えられます。手順4の代わりに `docs/evidence/aws-compute-options.md` を読ませます |
| 検証で「見出しがありません」と出る | Kiro が見出しを書き換えています。「見出しは docs/decisions/template.md のとおりに戻してください」と伝えます |
| 検証で「書きかけが残っています」「見出しの下が空です」と出る | 表示された箇所を埋めるよう Kiro に伝えます |
| Kiro が範囲外の作業を始めた | `Esc` で止めます。変更が残ったら「やり直すとき」の手順で戻します |

正解の例は `workshop-complete` ブランチの `docs/decisions/0002-online-api-runtime.md` にあります。
