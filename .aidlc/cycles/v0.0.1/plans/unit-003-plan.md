# Unit 003 実装計画: ElasticSearch インデックス登録

## 概要
Article モデルと ElasticSearch を連携し、記事の保存時に自動でインデックスが更新される仕組みを実装する。
`elasticsearch-model` / `elasticsearch-rails` gem を導入し、マッピング定義・コールバック・Rake タスクを整備する。

## Phase 1: 設計

### ドメインモデル設計
- 設計対象: Article エンティティへのインデックス設定（マッピング定義・コールバック責務）
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/domain-models/elasticsearch_indexing_domain_model.md`

### 論理設計
- 設計対象: gem 設定・マッピング構造・コールバック実装方針・Rake タスク設計・ElasticSearch 8.x 認証対応
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/logical-designs/elasticsearch_indexing_logical_design.md`

## Phase 2: 実装

### 実装対象ファイル
| ファイル | 内容 |
|---------|------|
| `Gemfile` | `elasticsearch-model`, `elasticsearch-rails` gem 追加 |
| `config/initializers/elasticsearch.rb` | ElasticSearch クライアント設定（接続先・認証） |
| `app/models/article.rb` | `Elasticsearch::Model` インクルード、マッピング定義、コールバック設定 |
| `lib/tasks/elasticsearch.rake` | `rake elasticsearch:reindex` タスク |
| `spec/models/article_elasticsearch_spec.rb` | インデックス連携のユニットテスト |

### 実装方針
- `elasticsearch-model` と `elasticsearch-rails` を Gemfile に追加
- ElasticSearch 8.x の xpack.security（TLS・認証）に対応するため、initializer でクライアントを設定（`ELASTICSEARCH_URL` 環境変数対応）
- `Article` モデルに `include Elasticsearch::Model` および `include Elasticsearch::Model::Callbacks` を追加
- マッピングは `title`, `body` を `text` 型、`published_at` を `date` 型で定義
- `rake elasticsearch:reindex` タスクで全記事のインデックス再構築を実行
- ElasticSearch 未起動時は接続エラーをキャッチしてログに記録（アプリ起動を妨げない）

## 完了条件チェックリスト

- [ ] `elasticsearch-model` / `elasticsearch-rails` gem が導入され、`bundle install` が成功する
- [ ] `Article.create_index!` でインデックスが作成できる
- [ ] 記事保存時（`Article.create` / `save`）に自動でインデックスが更新される
- [ ] `rake elasticsearch:reindex` が成功し、全記事がインデックスに登録される
- [ ] ElasticSearch 未起動時にアプリが起動できる（接続エラーを適切に処理する）
- [ ] インデックス連携のユニットテストが通る
