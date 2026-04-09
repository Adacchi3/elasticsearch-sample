# Unit 004 実装計画: 全文検索機能実装

## 概要
キーワードで記事を全文検索し、タイトル・本文抜粋・投稿日時を返す検索機能を Rails で実装する。
`GET /articles/search?q=キーワード` エンドポイントで ElasticSearch の `multi_match` クエリを使用し、
JSON レスポンスを返す。検索フォームと結果表示ページを Tailwind CSS でスタイリングする。

## Phase 1: 設計

### ドメインモデル設計
- 設計対象: 検索クエリの値オブジェクト、検索結果の表現
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/domain-models/full_text_search_domain_model.md`

### 論理設計
- 設計対象: ルーティング・コントローラー設計・ElasticSearch クエリ設計・ビュー構成・本文抜粋処理
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/logical-designs/full_text_search_logical_design.md`

## Phase 2: 実装

### 実装対象ファイル
| ファイル | 内容 |
|---------|------|
| `config/routes.rb` | `get "articles/search", to: "articles#search"` 追加 |
| `app/controllers/articles_controller.rb` | `search` アクション（ElasticSearch multi_match クエリ、JSON レスポンス） |
| `app/views/articles/search.html.erb` | 検索フォーム + 結果表示ビュー（Tailwind CSS スタイリング） |
| `spec/models/article_search_spec.rb` | `Article.search_by_keyword` のモデルスペック |
| `spec/requests/articles_spec.rb` | 検索エンドポイントのリクエストスペック |

### 実装方針
- `GET /articles/search?q=キーワード` エンドポイントを実装
- ElasticSearch の `multi_match` クエリで `title` と `body` を横断検索
- キーワード空の場合は空の結果配列を返す
- マッチなしの場合は空の結果配列を返す（エラーにしない）
- レスポンスは JSON 形式（`render json:`）
- 本文抜粋は最大200文字にトリミング（アプリ側で実装、`truncate` ヘルパー使用）
- キーワードのサニタイズ: Rails の `sanitize` / パラメーター受け取りは `params[:q].to_s.strip` で処理
- ビューは Tailwind CSS を使用してスタイリング（検索フォーム・結果カード）
- ElasticSearch 未起動時は `Elasticsearch::Transport::Transport::Errors::NotFound` 等を rescue してエラーレスポンスを返す

## 完了条件チェックリスト

- [ ] `GET /articles/search?q=キーワード` でJSONレスポンスが返る
- [ ] ElasticSearch の `multi_match` でタイトル・本文を横断検索できる
- [ ] キーワードが空の場合、空の結果配列が返る
- [ ] マッチなしの場合、空の結果配列が返る
- [ ] 本文抜粋が最大200文字にトリミングされる
- [ ] 検索フォームと結果表示ビュー（HTML）が実装される
- [ ] Tailwind CSS でスタイリングされている
- [ ] 検索アクションのテストが通る
