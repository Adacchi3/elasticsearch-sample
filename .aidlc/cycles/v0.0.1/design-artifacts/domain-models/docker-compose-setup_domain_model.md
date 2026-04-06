# ドメインモデル: Docker Compose 開発環境構築

## 概要
Rails 8.x・MySQL 8.x・ElasticSearch 8.x の3サービスを Docker Compose で管理する開発環境の構成モデル。サービス間の依存関係・ネットワーク・ボリュームを定義する。

**重要**: このドメインモデル設計では**コードは書かず**、構造と責務の定義のみを行います。

---

## サービス構成（エンティティに相当）

### RailsService
- **役割**: Web アプリケーションサーバー
- **属性**:
  - image: ローカルビルド（Dockerfile）
  - port: 3000（ホスト公開）
  - 環境変数: DATABASE_URL, ELASTICSEARCH_URL, RAILS_ENV
- **依存**: MySQLService（healthy）、ElasticSearchService（healthy）
- **振る舞い**: DB マイグレーション実行後にサーバー起動

### MySQLService
- **役割**: リレーショナルデータベース
- **属性**:
  - image: mysql:8.x
  - port: 3306（内部のみ）
  - 環境変数: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD
  - volume: mysql_data（データ永続化）
- **ヘルスチェック**: `mysqladmin ping`

### ElasticSearchService
- **役割**: 全文検索エンジン
- **属性**:
  - image: elasticsearch:8.x
  - port: 9200（内部のみ）
  - 環境変数: discovery.type=single-node, xpack.security.enabled=false
  - volume: es_data（インデックス永続化）
- **ヘルスチェック**: `curl -s http://localhost:9200/_cluster/health`

---

## ネットワーク

### app_network
- **種別**: bridge
- **参加サービス**: rails, mysql, elasticsearch
- **目的**: サービス間の名前解決（サービス名でアクセス可能）

---

## ボリューム

| ボリューム名 | 用途 |
|------------|------|
| mysql_data | MySQL データの永続化 |
| es_data | ElasticSearch インデックスの永続化 |

---

## 依存関係

```
RailsService
  └─ depends_on (healthy) → MySQLService
  └─ depends_on (healthy) → ElasticSearchService
```

---

## ユビキタス言語

- **コンテナ**: Docker が起動・管理する独立した実行環境
- **サービス**: docker-compose.yml で定義される1つのコンテナ設定
- **ヘルスチェック**: サービスが正常に応答できる状態かを確認する仕組み
- **depends_on**: サービスの起動順序と健全性依存を定義する設定

---

## 不明点と質問

特になし
