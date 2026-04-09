# elasticsearch-sample

Ruby on Rails + Elasticsearch を使った全文検索のサンプルアプリケーション。

## 機能

- 記事の全文検索（`GET /articles/search?q=キーワード`）
- Elasticsearch の `multi_match` クエリでタイトル・本文を横断検索
- HTML / JSON 両形式でのレスポンス
- Tailwind CSS によるスタイリング

## 技術スタック

| カテゴリ | バージョン |
|---------|-----------|
| Ruby | 3.3.11 |
| Rails | 8.1.3 |
| MySQL | 8.0 |
| Elasticsearch | 8.13.4 |

## 必要環境

- Docker / Docker Compose

## セットアップ

```bash
# コンテナ起動
docker compose up -d

# データベース作成・マイグレーション
docker compose exec rails bin/rails db:create db:migrate

# シードデータ投入
docker compose exec rails bin/rails db:seed

# Elasticsearch インデックス作成・データ投入
docker compose exec rails bin/rails elasticsearch:reindex
```

ブラウザで http://localhost:3000/articles/search にアクセスして動作を確認できます。

## テスト

```bash
docker compose exec -e RAILS_ENV=test rails bundle exec rspec
```
