# AWS実行基盤候補：JavaオンラインAPIと月次大量処理

- **確認日**：2026-11-02
- **対象リージョン**：`ap-northeast-1`
- **用途**：aws-mcp が使えないときの代わりの資料
- **注意**：ライブMCP応答を装った文書ではなく、AWS公式情報を事前確認した要約

## 暫定方向

| Workload | 第一候補 | 判断が変わる条件 |
|---|---|---|
| 業務時間中に継続利用するJava API | ECS Service on Fargate | requestが短く、長い低負荷時間があり、DB connectionとSnapStart restore latencyを制御できるならLambda |
| 月末の多数record処理 | AWS Batch on Fargate | 1～数jobならECS standalone task。標準Lambdaの独立chunkが15分以内、またはLambda Managed Instancesの非同期／対応event source invocationが90分以内ならLambda系も比較 |

この方向は最終決定ではありません。online SLO、最大record数、DB headroom、quotaの実測が必要です。

## Tokyo Region

AWS MCPのRegion Availabilityで、次のserviceまたはCloudFormation resourceが`ap-northeast-1`で利用可能であることを確認しました。

- AWS Lambda
- Amazon ECS
- AWS Fargate
- AWS Batch
- AWS Step Functions
- Amazon SQS
- Amazon RDS
- RDS Proxy support
- `AWS::Lambda::Function`
- `AWS::ECS::Service`
- `AWS::ECS::TaskDefinition`
- `AWS::Batch::ComputeEnvironment`
- `AWS::Batch::JobQueue`
- `AWS::RDS::DBProxy`
- `AWS::StepFunctions::StateMachine`
- `AWS::SQS::Queue`

Region availabilityはaccount quota、subnet IP、Fargate capacity、DB connectionを保証しません。

## JavaオンラインAPI

| 観点 | ECS Service on Fargate | Lambda Java＋SnapStart |
|---|---|---|
| 実行時間 | long-running service向け。Lambdaのinvocation timeout制約なし | 標準のLambda Event Functionと同期invocationは最大15分。Lambda Managed Instancesでは非同期／対応event source mappingが最大90分。front doorのtimeoutも別途確認が必要 |
| 起動 | minimum taskを常時起動できる。scale-outにはtask起動時間がある | SnapStartで起動を短縮できるが、published version／aliasが必要 |
| 同時実行 | task数とtask内request数で管理 | concurrency quotaとreserved concurrencyで管理 |
| DB接続 | taskごとのbounded JDBC poolを持てる | execution environment増加時のconnection急増をRDS Proxy等で制御する |
| Retry | 個別HTTP requestのretryはclient／application設計 | synchronous invokeのfunction errorはcaller側のretry設計が必要 |
| 運用 | image、task definition、service、ALB、autoscaling、health check | version、alias、SnapStart、concurrency、front doorを運用 |
| Cost driver | vCPU、memory、task稼働時間、ALB、logs、network | request、memory×duration、front door、logs、network、RDS Proxy |

### Fargateを第一候補にするproject推論

- 継続利用されるonline API
- relational DB接続の可能性が高い
- 複数endpointと複雑な業務logic
- bounded JDBC poolを管理しやすい
- minimum taskとheadroomで業務時間中のlatencyを安定させやすい

### Lambdaへ変わる条件

- requestが十分短い
- trafficに長い低負荷時間がある
- p99 SnapStart restore latencyがSLO内
- DB connection budgetを守れる
- EFSや大きなtemporary storageが不要

## 月次大量処理

| 観点 | Lambda | ECS standalone task | AWS Batch on Fargate |
|---|---|---|---|
| 実行時間 | 標準Lambdaではchunkを15分以内へ分割。Lambda Managed Instancesの非同期／対応event source invocationは最大90分 | 数時間の単一processも可能 | 長時間container job、queue、複数jobを管理 |
| 並列化 | SQS等でfan-out。concurrency制限が必要 | task数をorchestratorが決定 | queue、compute environment、`maxvCpus`で制御 |
| Retry | duplicateとpartial failureを前提にidempotencyが必要 | standalone taskの再実行は別途制御 | attempt、exit code、reasonに基づくretryを設定可能 |
| 進捗 | 業務進捗はapplication側で保持 | task stateと業務進捗を別途保持 | job statusがある。record単位進捗はapplication側 |
| 運用 | chunk、DLQ、再集計の設計が増える | scheduler、retry、status集約を自前で設計 | queueing、job lifecycle、retry、dependencyをmanaged serviceで扱う |
| Cost driver | request、GB-second、retry、queue | Fargate task稼働時間、logs、network | AWS Batch自体の追加料金なし。Fargate等のresourceを支払う |

### Batchを第一候補にするproject推論

- 多数recordを期限内に処理する
- job queue、retry、dependency、statusが必要
- online処理と別のqueue、role、log、compute上限を持てる
- 数分単位のidempotent chunkへ分割できる可能性がある

### ECS standalone taskへ変わる条件

- jobが1～数個
- array job、priority、job-level retryが不要
- 既存orchestratorで再実行と進捗を管理できる

### Lambdaへ変わる条件

- 標準Lambdaではchunkが独立し、p99でも15分を十分下回る
- Lambda Managed Instancesを使う場合は、非同期／event source条件、90分以内の実行、専用capacityとcost modelを別途検証する
- concurrencyとDB connectionをhard capできる
- duplicate、partial failure、checkpointを実装できる
- 月次起動時のJava startupを事前検証できる

## Online処理を守るための必須確認

computeを分けるだけでは不十分です。共有DBのconnection、CPU、I/O、lockが競合する可能性があります。

- `batch parallelism × connections per worker`をDB budget内にする
- online peak用のconnection／CPU／I/O headroomを残す
- read-only要件を満たせる場合はread replicaまたは月末extractを検討する
- batch並列度をhard capする
- online latencyまたはDB pressureが閾値を超えたら新規chunk投入を止める
- onlineとbatchでIAM role、security group、queue、logsを分離する

## 未確認事項

- online平均／peak RPS、p95／p99 SLO、最大request時間
- DB製品、engine、connection上限、transaction要件
- 月次record数、1件／1chunkの処理時間、CPU／DB／I/O比率
- 月次処理がread-onlyか更新を含むか
- 4時間deadlineの開始点と完了条件
- Lambda concurrency、Fargate vCPU、subnet IP、Batch quota
- Java framework、JDBC driver、APM agentのJava 25／SnapStart互換性

## 必要な計測

### Online API

- ECS warm／scale-out中とLambda warm／restoreのp50／p95／p99
- CPU、memory、GC、thread、最大処理時間
- DB active connection、acquire time、query latency、lock wait
- ALB／API Gateway、RDS Proxy、logs、networkを含むcost

### 月次処理

- 最大record数と成長率
- 1 chunkのp50／p95／p99
- queue投入から開始までの時間
- retry後成功率、checkpoint recovery
- batch並列度を増やした際のonline p99とDB pressure
- queue、startup、retry、帳票保存を含むwall-clock

## 公式情報源

- https://docs.aws.amazon.com/decision-guides/latest/decision-guides/fargate-or-lambda.html
- https://docs.aws.amazon.com/lambda/latest/dg/lambda-java.html
- https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html
- https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
- https://docs.aws.amazon.com/lambda/latest/dg/lambda-managed-instances-best-practices.html
- https://aws.amazon.com/about-aws/whats-new/2026/09/aws-lambda-90-minute-function/
- https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html
- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html
- https://docs.aws.amazon.com/batch/latest/userguide/job_states.html
- https://docs.aws.amazon.com/batch/latest/userguide/job_retries.html
- https://docs.aws.amazon.com/batch/latest/APIReference/API_JobTimeout.html
- https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy-best-practices.usage-scenarios.html
- https://aws.amazon.com/batch/pricing/
- https://aws.amazon.com/ecs/pricing/
- https://aws.amazon.com/lambda/pricing/

公式ページの内容は要約しています。availability、quota、pricing、runtime supportは本番前に再確認します。
