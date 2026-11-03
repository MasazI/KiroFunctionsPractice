# ADR-0002：オンライン API の実行基盤

- **状態**：暫定（技術検証の前）
- **日付**：2026-11-03

## Context（背景）

新しい業務アプリのオンライン API は Java で作ります。業務時間中ずっと使われ、データベースにも接続します。オンライン API をどこで動かすかを決める必要があります。

## Options considered（比較した選択肢）

1. Amazon ECS（AWS Fargate）：コンテナを常に動かしておく
2. AWS Lambda（SnapStart）：リクエストが来たときだけ関数を動かし、SnapStart で起動を速くする

## Verified facts and sources（確認した事実と出典）

確認日：2026-11-03（aws-mcp で確認）

- Lambda SnapStart は Java 11 以降のマネージドランタイムに対応する。公開したバージョン（とそれを指すエイリアス）でだけ使える。プロビジョンドコンカレンシーとは併用できない。
  https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html
- 標準の AWS Lambda 関数のタイムアウトは最大900秒（15分）。
  https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html
- Amazon ECS のサービスは、指定した数のタスクが動き続けるように、失敗したタスクを置き換える。
  https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/task.html
- 東京リージョン（ap-northeast-1）では、AWS Fargate、Amazon ECS、AWS Lambda、Lambda SnapStart が使える（aws-mcp の `get_regional_availability` で確認）。

## Project-specific inference（このプロジェクトへの推論）

- 業務時間中ずっと使われるため、常に動いている ECS（Fargate）のほうが、応答時間とデータベースへの接続数を一定に保ちやすい。
- Lambda は利用の少ない時間帯の費用を抑えやすいが、同時に動く数が増えるとデータベースへの接続も増えるため、接続の管理が別に必要になる。
- チームは Java の経験があるため、どちらでも Java の知識は活かせる。

## Decision（判断）

オンライン API は、次に Amazon ECS（AWS Fargate）で技術検証する。これは最終決定ではない。

## Unknowns and validation（未確認の事項と技術検証）

未確認の事項：

- 1秒あたりのリクエスト数（平均と最大）
- 応答時間の目標
- データベースに許される接続数

技術検証：

1. 業務の一部を API として作り、合成データで負荷をかける。
2. ECS（Fargate）で、応答時間、CPU とメモリの使用量、データベースの接続数を測る。
3. 比較のため、同じ API を Lambda（SnapStart）でも動かし、起動時を含む応答時間を測る。
4. 合格の基準：応答時間の目標を満たし、データベースの接続数が上限の内に収まる。

## Revisit conditions（見直す条件）

- リクエストが少ない時間が長く、Lambda の起動を含めた応答時間が目標を満たし、接続数も管理できるなら、Lambda を比べ直す。
- 利用者の数やリクエスト数の見込みが大きく変わったら、見直す。
