# Unit 001 実装計画: Docker Compose 開発環境構築

## 概要
Rails 8.x アプリ・MySQL 8.x・ElasticSearch 8.x を Docker Compose で起動できる開発環境を構築する。

## Phase 1: 設計

### ドメインモデル設計
- 設計対象: インフラ構成（サービス構成・ネットワーク・ボリューム）
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/domain-models/docker-compose-setup_domain_model.md`

### 論理設計
- 設計対象: 各サービスの設定値・依存関係・環境変数
- 成果物: `.aidlc/cycles/v0.0.1/design-artifacts/logical-designs/docker-compose-setup_logical_design.md`

## Phase 2: 実装

### 実装対象ファイル
| ファイル | 内容 |
|---------|------|
| `Dockerfile` | Rails アプリ用イメージ定義 |
| `docker-compose.yml` | 3サービス（rails, mysql, elasticsearch）定義 |
| `.env.example` | 環境変数のサンプル |
| `config/database.yml` | MySQL 接続設定 |
| `config/initializers/elasticsearch.rb` | ElasticSearch 接続設定 |
| `Gemfile` | 必要 gem（mysql2 等）の追加 |

### 実装方針
- `rails new` で Rails 8.x アプリを新規作成（MySQL 指定）
- Docker Compose の `depends_on` + `healthcheck` で起動順序を制御
- 環境変数で DB・ElasticSearch の接続先を設定

## 完了条件チェックリスト

- [ ] `docker compose up` で rails・mysql・elasticsearch の3サービスが起動する
- [ ] Rails アプリが MySQL に接続できる（`rails db:create` が成功する）
- [ ] Rails アプリが ElasticSearch に接続できる（接続確認コマンドが成功する）
- [ ] `docker compose up` 後にブラウザ または curl でアプリにアクセスできる
- [ ] DB パスワード等の機密情報は環境変数で管理されている
