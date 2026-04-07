# Unit 002 実装計画: シードデータ作成

## 概要
開発環境で全文検索をすぐに試せるよう、内容の異なる複数の記事サンプルデータを `db/seeds.rb` で定義する。
Article モデル（タイトル・本文・投稿日時）とマイグレーションを作成し、冪等な seed スクリプトを実装する。

## Phase 1: 設計

### ドメインモデル設計
- 設計対象: Article エンティティ（属性・バリデーション・責務）
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/domain-models/seed_data_domain_model.md`

### 論理設計
- 設計対象: マイグレーション構造・seeds.rb 実装方針・冪等性担保方法
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/logical-designs/seed_data_logical_design.md`

## Phase 2: 実装

### 実装対象ファイル
| ファイル | 内容 |
|---------|------|
| `app/models/article.rb` | Article モデル（バリデーション含む） |
| `db/migrate/YYYYMMDDHHMMSS_create_articles.rb` | articles テーブルマイグレーション |
| `db/seeds.rb` | 10件の記事サンプルデータ定義（冪等） |
| `spec/models/article_spec.rb` | Article モデルのユニットテスト（RSpec） |
| `Gemfile` | rspec-rails gem の追加 |

### 実装方針
- `rspec-rails` gem を Gemfile に追加し、`rails generate rspec:install` でセットアップ
- `rails generate model Article title:string body:text published_at:datetime` でモデル・マイグレーションを生成
- `find_or_create_by!(title: ...)` で冪等性を担保（複数回 seed 実行しても重複しない）
- 記事内容は技術・料理・旅行・スポーツ等カテゴリを分散させ、検索結果の差が出やすいようにする
- ElasticSearch へのインデックス処理は Unit 003 完了後に有効化（本 Unit では seeds.rb に TODO コメントを残す）

## 完了条件チェックリスト

- [ ] `Article` モデルが存在し、`title`, `body`, `published_at` の属性を持つ
- [ ] `rails db:migrate` が成功する（articles テーブルが作成される）
- [ ] `rails db:seed` が成功し、10件程度の記事データが作成される
- [ ] `rails db:seed` を複数回実行しても重複レコードが作成されない（冪等性）
- [ ] モデルのユニットテストが通る（`bundle exec rspec spec/models/article_spec.rb`）
