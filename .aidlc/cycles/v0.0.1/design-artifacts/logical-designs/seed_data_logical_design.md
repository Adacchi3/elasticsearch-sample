# 論理設計: シードデータ作成（Article）

## 概要
Article モデル・マイグレーション・RSpec テスト・シードデータスクリプトの構成と実装方針を定義する。

**重要**: この論理設計では**コードは書かず**、コンポーネント構成とインターフェース定義のみを行います。具体的なコード（SQL、JSON、実装コード等）はImplementation Phase（コード生成ステップ）で作成します。

## アーキテクチャパターン

Rails MVC（Active Record パターン）。シードデータ投入は `db/seeds.rb` で完結させる。

## コンポーネント構成

### ファイル構成

```text
elasticsearch-sample/
├── Gemfile                              # rspec-rails gem 追加
├── app/
│   └── models/
│       └── article.rb                   # Article モデル（バリデーション）
├── db/
│   ├── migrate/
│   │   └── YYYYMMDDHHMMSS_create_articles.rb  # マイグレーション
│   └── seeds.rb                         # サンプルデータ定義（冪等）
└── spec/
    ├── rails_helper.rb                  # rspec-rails セットアップ
    ├── spec_helper.rb                   # RSpec 基本設定
    └── models/
        └── article_spec.rb              # Article モデルのユニットテスト
```

### コンポーネント詳細

#### Article モデル（`app/models/article.rb`）
- **責務**: 記事データの属性定義とバリデーション
- **依存**: ApplicationRecord（Active Record）
- **公開インターフェース**:
  - 属性: `title`, `body`, `published_at`
  - バリデーション: `title`, `body`, `published_at` の必須チェック

#### マイグレーション（`db/migrate/…_create_articles.rb`）
- **責務**: articles テーブルの DDL 定義
- **依存**: なし
- **公開インターフェース**: `change` メソッド（`create_table :articles`）

#### シードスクリプト（`db/seeds.rb`）
- **責務**: 開発環境向けサンプル記事の冪等生成（ドメインモデルの `ArticleRepository#find_by_identifier` に相当する操作を Active Record の `find_or_create_by!(title:)` で実現）
- **依存**: Article モデル
- **公開インターフェース**: `rails db:seed` コマンドで実行
- **実装パターン**: 記事データ配列をイテレートし、各記事を `Article.find_or_create_by!(title:)` で冪等に挿入する（手続き的なスクリプトとして実装。クラス化は不要）

#### RSpec セットアップ（`spec/rails_helper.rb`, `spec/spec_helper.rb`）
- **責務**: テスト実行環境の設定
- **依存**: rspec-rails gem

#### Article スペック（`spec/models/article_spec.rb`）
- **責務**: Article モデルのバリデーション・属性のユニットテスト
- **依存**: Article モデル、RSpec、FactoryBot（必要に応じて）

## データモデル概要

### データベーススキーマ

#### テーブル: `articles`
- **主キー**: `id` (bigint, auto-increment)
- **カラム**:
  - `title`: string - NOT NULL - 記事タイトル
  - `body`: text - NOT NULL - 記事本文
  - `published_at`: datetime - NOT NULL - 投稿日時
  - `created_at`: datetime - NOT NULL - Rails 自動管理
  - `updated_at`: datetime - NOT NULL - Rails 自動管理
- **インデックス**: `title`（UNIQUE）— `find_or_create_by!(title:)` による冪等性を DB レベルで保証するため
- **外部キー**: なし

**注**: 実際の CREATE TABLE 文は `rails db:migrate` 実行時に生成します。

## 処理フロー概要

### シードデータ投入の処理フロー

**ステップ**:
1. `rails db:seed` 実行
2. seeds.rb 内の記事データ配列をイテレート
3. 各記事について `Article.find_or_create_by!(title: ...)` を実行
   - これはドメインモデルの `ArticleRepository#find_by_identifier(title)` + `save(article)` を Active Record で実現したもの
4. タイトルが存在しなければ `body`, `published_at` を含めて新規作成
5. タイトルが既存であればスキップ（冪等性担保）

**関与するコンポーネント**: seeds.rb、Article モデル、MySQL

### RSpec セットアップの処理フロー

**ステップ**:
1. Gemfile に `rspec-rails` を追加
2. `bundle install` 実行
3. `rails generate rspec:install` で `spec/` ディレクトリと設定ファイルを生成

## 非機能要件（NFR）への対応

### パフォーマンス
- **要件**: 特になし（開発環境のみ）
- **制約**: データ件数は10件程度のため、バルク処理等の最適化は不要

### セキュリティ
- **要件**: seeds.rb にはテストデータのみを含める。環境変数からの機密情報読み込みは行わない
- **制約**: 本 Unit のシードスクリプトは開発環境専用であり、本番環境では実行されない構成とする

### スケーラビリティ
- **要件**: 特になし（サンプル規模）
- **制約**: 本 Unit のシードデータは開発環境専用。本番環境での使用を前提としない

### 可用性
- **要件**: 特になし（ローカル開発環境）
- **制約**: Unit 003 完了まで ElasticSearch へのインデックス処理は実行しない。seeds.rb には TODO コメントを残す

## 技術選定
- **言語**: Ruby（Railsデフォルト）
- **フレームワーク**: Ruby on Rails
- **テストライブラリ**: rspec-rails（ユーザー指定）
- **データベース**: MySQL 8.x（Unit 001 で構築済み）

## 実装上の注意事項
- seeds.rb の冪等性は `find_or_create_by!(title:)` で担保する（`title` をキーとして使用）
- ElasticSearch へのインデックス処理は Unit 003 完了後に有効化するため、seeds.rb に `# TODO: Unit 003 完了後にインデックス処理を追加` コメントを残す
- RSpec の `spec/rails_helper.rb` は `rails generate rspec:install` で生成するため手動編集は最小限にとどめる

## 不明点と質問（設計中に記録）

特になし（Unit 定義・計画ファイルから実装方針が明確に定まったため）
