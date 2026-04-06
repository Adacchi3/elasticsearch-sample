# 論理設計: Docker Compose 開発環境構築

## 概要
Rails 8.x・MySQL 8.x・ElasticSearch 8.x を Docker Compose で起動する開発環境のファイル構成・設定値・起動フローを定義する。Tailwind CSS を CSS フレームワークとして採用する。

**重要**: この論理設計では**コードは書かず**、構成とインターフェース定義のみを行います。

---

## アーキテクチャパターン
**マルチコンテナ構成（Docker Compose）**
- 各サービスを独立したコンテナとして分離
- `healthcheck` + `depends_on: condition: service_healthy` で起動順序を保証

---

## ファイル構成

```text
elasticsearch-sample/
├── Dockerfile                        # Rails アプリ用イメージ
├── docker-compose.yml                # サービス定義
├── .env.example                      # 環境変数サンプル（.env を gitignore）
├── .gitignore
├── Gemfile                           # gem 定義
├── Gemfile.lock
├── config/
│   ├── database.yml                  # MySQL 接続設定（環境変数参照）
│   └── initializers/
│       └── elasticsearch.rb          # ElasticSearch クライアント設定
└── （その他 Rails 標準ファイル）
```

---

## コンポーネント詳細

### Dockerfile（Rails アプリ）
- **ベースイメージ**: `ruby:3.x-slim`
- **主要ステップ**:
  1. 必要システムパッケージのインストール（build-essential, default-mysql-client, Node.js 等）
  2. Bundler によるGem インストール
  3. アプリコードをコピー
  4. エントリポイント: `entrypoint.sh`（db:migrate 実行後にサーバー起動）
- **公開ポート**: 3000

### docker-compose.yml
- **サービス**:

| サービス名 | イメージ | ポート | ヘルスチェック |
|-----------|---------|--------|--------------|
| rails | ./Dockerfile ビルド | 3000:3000 | curl http://localhost:3000 |
| mysql | mysql:8.0 | （内部のみ） | mysqladmin ping |
| elasticsearch | elasticsearch:8.13 | （内部のみ） | curl http://localhost:9200 |

- **depends_on**:
  - rails → mysql (service_healthy)
  - rails → elasticsearch (service_healthy)

### .env.example
- MYSQL_ROOT_PASSWORD
- MYSQL_DATABASE
- MYSQL_USER
- MYSQL_PASSWORD
- ELASTICSEARCH_URL（デフォルト: `http://elasticsearch:9200`）

### config/database.yml
- adapter: mysql2
- host: 環境変数 `MYSQL_HOST`（デフォルト: `mysql`）
- username / password: 環境変数参照

### config/initializers/elasticsearch.rb
- `Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])`

---

## フロントエンド: Tailwind CSS

- **導入方法**: `rails new` 時に `--css tailwind` オプションを指定
- **ビルド**: Rails 8.x 標準の `tailwindcss-rails` gem を使用
- **対象**: 検索結果表示ページ（Unit 004 で実装）

---

## 処理フロー: `docker compose up` 後の起動シーケンス

1. mysql コンテナ起動 → ヘルスチェック通過待機
2. elasticsearch コンテナ起動 → ヘルスチェック通過待機
3. rails コンテナ起動（mysql + elasticsearch が healthy になったら）
4. entrypoint.sh: `bundle exec rails db:create db:migrate` を実行
5. `bundle exec rails server -b 0.0.0.0` を起動
6. `http://localhost:3000` でアクセス可能

---

## 非機能要件への対応

### セキュリティ
- 要件: DB パスワード等は環境変数で管理
- 対応: `.env` を `.gitignore` に追加、`.env.example` のみコミット

### 可用性（開発環境）
- 要件: 特になし
- 対応: ヘルスチェックで依存サービスの起動完了を確認してから Rails を起動

---

## 技術選定
- **言語**: Ruby 3.x
- **フレームワーク**: Ruby on Rails 8.x
- **CSS**: Tailwind CSS（tailwindcss-rails gem）
- **DB**: MySQL 8.0
- **検索エンジン**: ElasticSearch 8.13
- **コンテナ**: Docker Compose v2

---

## 実装上の注意事項
- ElasticSearch 8.x はデフォルトで xpack.security が有効なため、開発環境では `xpack.security.enabled=false` に設定する
- `entrypoint.sh` で db:migrate を実行することで、コンテナ再起動時にも自動でマイグレーションが適用される
- Tailwind CSS のビルドは `tailwindcss-rails` gem が `rails server` 起動時に自動で行う

---

## 不明点と質問

特になし
