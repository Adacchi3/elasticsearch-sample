# 論理設計: ElasticSearch インデックス登録

## 概要
`elasticsearch-model` / `elasticsearch-rails` gem（既にGemfile追加済み）を活用し、Article モデルへのインデックス設定・コールバック・Rake タスクを実装する。

**重要**: この論理設計では**コードは書かず**、コンポーネント構成とインターフェース定義のみを行います。具体的なコードはImplementation Phase（コード生成ステップ）で作成します。

## 前提条件（調査結果）

- `elasticsearch-model ~> 7.2` / `elasticsearch-rails ~> 7.2` は Gemfile に追加済み（bundle install 済みかは実装時確認）
- docker-compose: `xpack.security.enabled=false`（認証不要）
- 接続URL: 環境変数 `ELASTICSEARCH_URL`（docker-compose では `http://elasticsearch:9200`）
- ElasticSearch バージョン: 8.13.4（gem は 7.x 系だが互換動作）

## アーキテクチャパターン

**Active Record + Elasticsearch::Model モジュール**パターン。
Rails の ActiveRecord モデルに `Elasticsearch::Model` と `Elasticsearch::Model::Callbacks` をインクルードし、コールバック経由でインデックスを自動更新する。

## コンポーネント構成

```text
app/
├── models/
│   └── article.rb                      # Elasticsearch::Model インクルード、マッピング、コールバック
config/
└── initializers/
    └── elasticsearch.rb                # クライアント設定（ELASTICSEARCH_URL 読み込み）
lib/
└── tasks/
    └── elasticsearch.rake              # rake elasticsearch:reindex タスク
spec/
└── models/
    └── article_elasticsearch_spec.rb   # インデックス連携テスト
```

### コンポーネント詳細

#### config/initializers/elasticsearch.rb
- **責務**: ElasticSearch クライアントをアプリ起動時に初期化する
- **依存**: 環境変数 `ELASTICSEARCH_URL`（未設定時は `http://localhost:9200` にフォールバック）
- **公開インターフェース**: `Elasticsearch::Model.client` にクライアントを設定
- **エラー処理**: 接続失敗はここでは捕捉しない（起動ブロックしない）

#### app/models/article.rb（拡張）
- **責務**: Article レコードの CRUD に連動してインデックスを更新する
- **依存**: `Elasticsearch::Model`, `Elasticsearch::Model::Callbacks`
- **公開インターフェース**:
  - `Article.__elasticsearch__.create_index!` - インデックス作成
  - `Article.__elasticsearch__.import` - 全件インポート
  - `as_indexed_json` - インデックス対象フィールドの返却

#### lib/tasks/elasticsearch.rake
- **責務**: 全記事の一括 Reindex を提供する Rake タスク
- **依存**: `Article.__elasticsearch__.import`
- **公開インターフェース**: `rake elasticsearch:reindex`

## データモデル概要

### ElasticSearch インデックスマッピング

インデックス名: `articles`（デフォルト: モデル名の複数形）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `title` | `text` | 記事タイトル（全文検索対象） |
| `body` | `text` | 記事本文（全文検索対象） |
| `published_at` | `date` | 投稿日時（範囲検索・ソート対象） |

`created_at` / `updated_at` はインデックス対象外とする。

## 処理フロー概要

### 記事保存時のインデックス更新フロー

**ステップ**:
1. `Article.create` / `article.save` が呼ばれる
2. `Elasticsearch::Model::Callbacks` の `after_commit` フックが発火
3. `article.__elasticsearch__.index_document` が呼ばれ、インデックスを更新
4. ElasticSearch 未起動の場合、`Faraday::ConnectionFailed` 等の例外が発生
5. 例外はコールバック内でキャッチし、Rails.logger.error に記録してサイレントに失敗

### Rake Reindex フロー

**ステップ**:
1. `rake elasticsearch:reindex` を実行
2. `Article.__elasticsearch__.create_index!(force: true)` でインデックスを再作成
3. `Article.__elasticsearch__.import` で全 Article を一括インポート
4. 完了件数をログ出力

## 非機能要件（NFR）への対応

### パフォーマンス
- **要件**: サンプル規模のため特になし
- **対応策**: `import` のバッチサイズはデフォルト（1000件）を使用

### セキュリティ
- **要件**: 特になし（docker-compose で xpack.security 無効）
- **対応策**: `ELASTICSEARCH_URL` を環境変数で管理（ハードコードしない）

### 可用性
- **要件**: ElasticSearch 未起動時にアプリが起動できること
- **対応策**: initializer では接続確認をしない。コールバックの例外はキャッチしてログ記録のみ

## 技術選定
- **言語**: Ruby（Rails 8.1.3）
- **フレームワーク**: Ruby on Rails
- **ライブラリ**: elasticsearch-model ~> 7.2, elasticsearch-rails ~> 7.2
- **ElasticSearch**: 8.13.4（docker-compose）

## 実装上の注意事項
- gem は 7.x 系だが ES 8.x に接続する。`Elasticsearch::Model.client` に明示的に `api_key: nil` を設定しない（xpack.security=false なので不要）
- `seeds.rb` の TODO コメント（Unit 002 で残したもの）は本 Unit での実装時に削除する
- テストは ElasticSearch への実接続をモックする（単体テストのため）。実接続テストはスコープ外

## 不明点と質問

（なし）
