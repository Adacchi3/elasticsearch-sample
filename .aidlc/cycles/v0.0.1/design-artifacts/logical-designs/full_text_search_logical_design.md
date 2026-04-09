# 論理設計: 全文検索機能実装

## 概要
`GET /articles/search?q=キーワード` エンドポイントを実装し、ElasticSearch の multi_match クエリで Article の title・body を横断検索する。`respond_to` で HTML・JSON 両形式に対応し、Rails MVC で実装する。

**重要**: この論理設計では**コードは書かず**、コンポーネント構成とインターフェース定義のみを行います。具体的なコード（SQL、JSON、実装コード等）はImplementation Phase（コード生成ステップ）で作成します。

## アーキテクチャパターン

Rails MVC パターン。検索ロジックは Controller に直接実装（サービスオブジェクトは不要な規模）。
ElasticSearch アクセスは `Article.search(...)` メソッド（`elasticsearch-model` gem 提供）を直接使用する。

## コンポーネント構成

### レイヤー / モジュール構成

```text
Web Layer
├── routes.rb（ルーティング）
└── ArticlesController#search（コントローラー）

Model Layer
└── Article（Elasticsearch::Model 経由で .search() を提供）

View Layer
└── articles/search.html.erb（検索フォーム＋結果表示）

Test Layer
└── spec/requests/articles_spec.rb（リクエストスペック）
```

### コンポーネント詳細

#### routes.rb
- **責務**: `GET /articles/search` を `articles#search` にルーティング
- **依存**: なし
- **公開インターフェース**: `search_articles_path` ヘルパー

#### ArticlesController#search
- **責務**: `params[:q]` を受け取り、`Article.search(...)` で ElasticSearch 検索を実行し、`respond_to` で HTML または JSON を返す
- **依存**: Article モデル（Elasticsearch::Model の `.search()` メソッド）
- **公開インターフェース**: `GET /articles/search?q=<keyword>`
- **処理概要**:
  1. `params[:q].to_s.strip` でキーワードを取得・サニタイズ
  2. 空キーワードの場合は `@results = []` を設定し即時レンダリング
  3. `Article.search(...)` で multi_match クエリを実行
  4. 結果を SearchResultItem 形式にマッピング（`body_excerpt` は `truncate(body, length: 200)` を適用）
  5. `respond_to` で `format.html`（`@results`, `@keyword` をビューに渡す）と `format.json`（`{ articles: results }` を返す）に対応
  6. ElasticSearch 接続エラーは `rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Elastic::Transport::Transport::Error` でキャッチし、503 レスポンスを返す

#### Article モデル（検索部分）
- **責務**: 検索ロジックをモデルに集約する。`search_by_keyword(keyword)` クラスメソッドが ES クエリ実行・結果マッピング・body_excerpt 生成・日時フォーマットを担う
- **依存**: `elasticsearch-model` gem（Unit 003 で導入済み）
- **公開インターフェース**: `Article.search_by_keyword(keyword)` → `{ total: Integer, articles: Array[Hash] }`
- **注意**: Controller は `Article.search_by_keyword` のみを呼び出す（内部実装を直接呼ばない）

#### articles/search.html.erb
- **責務**: 検索フォームと検索結果の表示（Tailwind CSS スタイリング）
- **依存**: ArticlesController から渡される `@results`、`@keyword`
- **表示内容**:
  - 検索フォーム（テキスト入力 + 送信ボタン）
  - 検索結果件数
  - 各記事カード（タイトル・本文抜粋・投稿日時）
  - 0件時のメッセージ

## インターフェース設計

### API エンドポイント

#### `GET /articles/search`
- **説明**: キーワードで記事を全文検索する。HTMLまたはJSONでレスポンスを返す
- **リクエストパラメータ**:
  - `q`: String（任意）- 検索キーワード。省略・空の場合は空結果を返す
- **レスポンス形式の切り替え**:
  - `Accept: text/html` または通常ブラウザリクエスト → `search.html.erb` をレンダリング
  - `Accept: application/json` または `.json` 拡張子 → JSON を返す
  - 実装は `respond_to { |format| format.html; format.json }` で制御
- **JSONレスポンス**（成功時 200）:
  ```
  {
    "articles": [
      {
        "id": Integer,
        "title": String,
        "body_excerpt": String（最大200文字）,
        "published_at": String（"YYYY年MM月DD日 HH:MM" 形式）
      },
      ...
    ]
  }
  ```
- **エラーレスポンス**（ElasticSearch 接続失敗時 503）:
  ```
  { "error": "Search service is currently unavailable" }
  ```
  HTML の場合はエラーメッセージをビューに表示

## データモデル概要

新規テーブル・スキーマ変更なし。Unit 002/003 で作成済みの articles テーブル・ElasticSearch インデックスをそのまま使用。

## 処理フロー概要

### 検索リクエストの処理フロー

**ステップ**:
1. ブラウザ / クライアントが `GET /articles/search?q=Rails` を送信
2. Router が `ArticlesController#search` にディスパッチ
3. Controller が `params[:q].to_s.strip` でキーワードを取得・サニタイズ
4. キーワードが空の場合: `@results = []` を設定し、ステップ8へ
5. `Article.search({ query: { multi_match: { query: keyword, fields: ["title", "body"] } } })` を実行
6. ElasticSearch がヒット結果を返す
7. Controller が ES ヒットを SearchResultItem 形式にマッピング（`body_excerpt` は `truncate(body, length: 200)` で生成）
8. `respond_to` で HTML または JSON を返す

**関与するコンポーネント**: Router, ArticlesController, Article モデル（ES）, articles/search.html.erb

### エラー処理フロー

**ステップ**:
1. ElasticSearch への接続に失敗
2. 以下の例外クラスを rescue:
   - `Faraday::ConnectionFailed`（接続失敗）
   - `Faraday::TimeoutError`（タイムアウト）
   - `Elastic::Transport::Transport::Error`（ES トランスポート基底クラス）
3. `Rails.logger.error` にエラーを記録
4. JSON: `render json: { error: "Search service is currently unavailable" }, status: :service_unavailable`
   HTML: `@error_message` をセットしてビューに表示

## テスト戦略

- **実行前提**: Docker Compose 環境（ElasticSearch 起動済み）が必要。実接続テストを採用する
- **モック戦略**: サンプル規模のため VCR/WebMock 等は使用しない
- **テスト範囲**:
  - 正常系: キーワードあり → 結果が返る
  - 正常系: キーワード空 → 空配列が返る
  - 正常系: マッチなし → 空配列が返る
  - 異常系: ES 接続失敗 → 503 レスポンス

## 非機能要件（NFR）への対応

### パフォーマンス
- **要件**: 特になし（サンプル規模）
- **対応策**: 追加のキャッシュ・最適化は不要

### セキュリティ
- **要件**: キーワードのサニタイズ
- **対応策**: `params[:q].to_s.strip` でパラメーターを文字列化。ElasticSearch の Query DSL を使用するため SQL インジェクション相当のリスクなし。XSS 対策は Rails デフォルト ERB エスケープに委ねる

### スケーラビリティ
- **要件**: 特になし（サンプル用途）
- **対応策**: なし

### 可用性
- **要件**: 特になし
- **対応策**: ElasticSearch 未起動時は 503 エラーレスポンスを返し、アプリは継続動作

## 技術選定
- **言語**: Ruby（Rails のバージョンに準拠）
- **フレームワーク**: Ruby on Rails（MVC）
- **ライブラリ**: elasticsearch-model（Unit 003 で導入済み）、tailwindcss-rails（既存）
- **データベース**: MySQL（Article テーブル）、ElasticSearch 8.x（全文検索インデックス）

## 実装上の注意事項
- `Article.search_by_keyword(keyword)` がクエリ実行・結果マッピング・body_excerpt 生成・日時フォーマットを担う
- ES ヒットから title/body/published_at を取り出すには `hit._source` を使用
- `body_excerpt` は 200文字超えの場合に末尾3文字を `...` に置換（モデル内で処理、XSS 対策は Rails ERB の自動エスケープに委ねる）
- `published_at` は `"YYYY年MM月DD日 HH:MM"` 形式に変換（HTML/JSON 共通）
- rescue 対象は `Faraday::ConnectionFailed`、`Faraday::TimeoutError`、`Elastic::Transport::Transport::Error` の3クラス
