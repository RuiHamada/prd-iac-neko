# Backlog Webhook CloudRun

Backlogのwebhookからコメントを受信し、Vertex AIで応答を生成してBacklogに投稿するCloudRunアプリケーション。

## 概要

このサービスは以下の要件を満たします：
- Backlogのwebhookからコメントデータを受信
- comment内容に対してVertex AIを使用して応答生成
- メンション対象はcreateUserにメンションとして投稿
- Backlog APIを使用して回答をBacklogに投稿
- Message queueにはPub/Subを利用した非同期処理

## アーキテクチャ

```
Backlog Webhook → CloudRun (Webhook受信) → Pub/Sub → CloudRun (処理) → Vertex AI → Backlog API投稿
```

### フロー詳細

1. **Webhook受信**: BacklogからのwebhookをCloudRunで受信
2. **メッセージ配信**: 受信したデータをPub/Sub (`backlog-chat`) に配信
3. **非同期処理**: Pub/Subトリガーで別のCloudRunインスタンスが処理開始
4. **AI応答生成**: Vertex AIでコメント内容に基づく応答を生成
5. **Backlog投稿**: 生成された応答をBacklog APIでコメントとして投稿

## データ構造

### Webhook入力データ (sample.json)
```json
{
  "content": {
    "comment": {
      "id": 586721933,
      "content": "@濱田 塁 これはテストのコメントです。2"
    }
  },
  "createdUser": {
    "id": 1710649,
    "name": "濱田 塁",
    "userId": "*Wfw2kWJ02g"
  }
}
```

### 処理対象
- `content.comment.content`: AI応答生成の入力
- `createdUser`: メンション対象ユーザー

## 必要な実装

### 現在の状況
✅ 基本Webhook受信機能 (`main.py`)  
✅ Terraform CloudRun設定  
✅ Pub/Sub トピック `backlog-chat` 設定済み  

### 実装予定
- [ ] Vertex AI連携機能
- [ ] Backlog API クライアント
- [ ] Pub/Sub publisher機能  
- [ ] メッセージ処理ロジック
- [ ] 環境変数・シークレット管理強化

## ファイル構成

```
backlog-webhook-cloudrun/
├── README.md              # このファイル
├── main.py               # 既存：Webhook受信サーバー
├── Dockerfile            # 既存：コンテナ設定
├── requirements.txt      # 既存：依存関係
├── sample.json           # Webhookデータサンプル
├── sample.py             # サンプルコード
├── vertex_ai_client.py   # 新規：Vertex AI連携
├── backlog_api_client.py # 新規：Backlog API クライアント
├── message_handler.py    # 新規：メッセージ処理ロジック
└── script/
    ├── build.sh          # 既存：ビルドスクリプト
    └── deploy.sh         # 既存：デプロイスクリプト
```

## 環境変数

| 変数名 | 説明 | 現在の状況 |
|--------|------|-----------|
| `BACKLOG_WEBHOOK_SECRET_TOKEN` | Webhook認証トークン | ✅ 設定済み |
| `BACKLOG_API_KEY` | Backlog API キー | ⚠️ 追加予定 |
| `BACKLOG_SPACE_ID` | Backlog スペースID | ⚠️ 追加予定 |
| `GOOGLE_CLOUD_PROJECT` | GCPプロジェクトID | ⚠️ 追加予定 |
| `PUBSUB_TOPIC` | Pub/Subトピック名 | ⚠️ 追加予定 |

## デプロイ設定

### CloudRun設定 (Terraform)
- **サービス名**: `backlog-webhook-cloudrun-${var.suffix}`
- **リージョン**: `asia-northeast1`
- **Ingress**: `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER`
- **イメージ**: `gcr.io/${var.project_id}/backlog-webhook-cloudrun:${var.tag}`

### Pub/Sub設定
- **トピック**: `backlog-chat` (既存)
- **サブスクリプション**: Push型でCloudRunにトリガー

## 開発・テスト

### ローカル開発
```bash
export BACKLOG_WEBHOOK_SECRET_TOKEN="your-token"
python main.py
```

### ビルド・デプロイ
```bash
./script/build.sh
./script/deploy.sh
```

## セキュリティ

- Webhook認証にHMACトークン検証を使用
- Backlog APIキーはSecret Managerで管理
- CloudRun間通信はサービスアカウント認証

## 参考

- [Backlog Webhook API](https://developer.nulab.com/docs/backlog/webhooks/)
- [Backlog API](https://developer.nulab.com/docs/backlog/api/)
- [Vertex AI API](https://cloud.google.com/vertex-ai/docs)