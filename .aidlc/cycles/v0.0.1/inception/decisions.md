# 意思決定記録 - v0.0.1

## DR-001: Rails アプリモード（フルスタック vs API モード）

- **ステップ**: Construction Phase / Unit 001 実装
- **日時**: 2026-04-06

### 背景

Rails アプリを Docker Compose で構築する際、アプリのモードをフルスタック（HTML ビュー）にするか API モードにするかを決定する必要があった。

### 選択肢

| # | 選択肢 | メリット | デメリット |
|---|--------|---------|-----------|
| 1 | フルスタックモード（HTML ビュー + Tailwind CSS） | 検索結果を直接ブラウザで確認できる。フロントエンド分離が不要でサンプルとして完結 | API モードより若干ファイル量が多い |
| 2 | API モード | シンプルな構成。JSON レスポンスのみ | ブラウザでの動作確認に別途フロントエンドが必要 |

### 決定

**フルスタックモード（HTML ビュー + Tailwind CSS）** を採用

### トレードオフと判断根拠

- **得たもの**: ブラウザで検索結果を直接確認できるサンプルアプリとして完結した実装
- **犠牲にしたもの**: API モードに比べてビュー関連ファイルが増える
- **判断根拠**: サンプルプログラムとして動作を視覚的に確認しやすいフルスタック構成が適切。ユーザーが明示的に「フルスタックでお願いします」と要求した

---

## DR-002: テストフレームワーク（Minitest vs RSpec）

- **ステップ**: Construction Phase / Unit 002 実装
- **日時**: 2026-04-07

### 背景

Unit 002 の実装でモデルのユニットテストを作成する際、Rails デフォルトの Minitest（`rails test`）を使うか、RSpec（`rspec-rails`）を使うかを決定する必要があった。

### 選択肢

| # | 選択肢 | メリット | デメリット |
|---|--------|---------|-----------|
| 1 | Minitest（Rails デフォルト） | 追加 gem 不要・Rails 標準 | 記述スタイルが RSpec より冗長になる場合がある |
| 2 | RSpec（rspec-rails） | 可読性の高い DSL・describe/context/it 構造 | rspec-rails gem の追加が必要 |

### 決定

**RSpec（rspec-rails）** を採用

### トレードオフと判断根拠

- **得たもの**: 可読性の高い BDD スタイルのテスト記述
- **犠牲にしたもの**: Rails 標準からの逸脱（rspec-rails gem の追加管理）
- **判断根拠**: ユーザーが「テストは RSpec が良い」と明示的に要求した

---

<!-- 以降、DR-003, DR-004, ... と連番で追記 -->

## DR-003: 検索ロジックの配置（Controller vs Model）

- **ステップ**: Construction Phase / Unit 004 実装
- **日時**: 2026-04-09

### 背景

全文検索の実装において、ElasticSearch クエリ実行・結果マッピング・body_excerpt 生成・日時フォーマットの責務をコントローラーに実装した。

### 選択肢

1. **Controller 直接実装**: 論理設計の当初方針。シンプルだが Controller が肥大化する
2. **Model に集約（`search_by_keyword` メソッド）**: 検索ロジックをモデルに集約。Controller は薄く保つ

### 決定

**選択肢2（Model に集約）** を採用。

### 理由

MVC の原則に従い、ビジネスロジック（検索・変換）はモデルに置くべきとのユーザー指摘を受けて変更。テスト容易性も向上する（コントローラーを通さずモデル単体でテスト可能）。

## DR-004: テスト環境のホスト認証設定

- **ステップ**: Construction Phase / Unit 004 実装
- **日時**: 2026-04-09

### 背景

Docker Compose 環境（`RAILS_ENV=development`）で RSpec を実行すると、`ActionDispatch::HostAuthorization` が `www.example.com` を拒否して全リクエストが 403 になった。

### 選択肢

1. **テストヘルパーで User-Agent を設定**: 根本解決にならない
2. **`config.hosts = :all`**: Rails 8 では Symbol が許可ホストとして機能しない（バグ）
3. **`config.middleware.delete ActionDispatch::HostAuthorization`**: テスト環境でミドルウェア自体を除去

### 決定

**選択肢3（ミドルウェア除去）** を採用。`config/environments/test.rb` に追記。

### 理由

`config.hosts = :all` が Rails 8.1.3 で意図通り動作しないことを確認。テスト環境でのホスト制限は不要なため、ミドルウェア削除が最もシンプルかつ確実。実行時は `RAILS_ENV=test` を明示して実行すること（Docker の環境変数が `development` のため `||=` では上書きされない）。
