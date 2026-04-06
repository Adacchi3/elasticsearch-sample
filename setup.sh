#!/bin/bash
set -e

echo "=== elasticsearch-sample セットアップ ==="

# 1. .env を作成
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✓ .env を作成しました（必要に応じて編集してください）"
else
  echo "ℹ .env は既に存在します"
fi

# 2. Dockerfile を開発用に確保（rails new で上書きされた場合に備えて後で再適用）
cp Dockerfile Dockerfile.dev.bak

# 3. Gemfile を最小構成にリセット（rails new 用）
echo ""
echo "→ Gemfile を最小構成にリセット..."
cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "rails", "~> 8.0"
EOF
# Gemfile.lock もクリア
> Gemfile.lock

# 4. Docker イメージをビルド（最小構成）
echo ""
echo "→ Docker イメージをビルド中..."
docker compose build rails

# 5. 前回の rails new で生成された bin/ を削除（bootsnap 参照の競合を防ぐ）
echo ""
echo "→ 前回生成のファイルをクリア..."
rm -rf bin/ config/boot.rb config/application.rb

# 6. rails new を実行（既存ファイルは保持しつつ Rails 構造を生成）
echo ""
echo "→ Rails アプリを生成中..."
docker compose run --no-deps --rm rails bundle exec rails new . \
  --force \
  --database=mysql \
  --css=tailwind \
  --skip-git \
  --skip-bundle

# 7. 開発用 Dockerfile を復元（rails new が上書きするため）
echo ""
echo "→ 開発用 Dockerfile を復元..."
cp Dockerfile.dev.bak Dockerfile
rm Dockerfile.dev.bak

# 8. config/database.yml を上書き（Docker 用設定）
echo ""
echo "→ config/database.yml を Docker 用設定に上書き..."
cat > config/database.yml << 'EOF'
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: <%= ENV.fetch("MYSQL_HOST") { "mysql" } %>
  username: root
  password: <%= ENV["MYSQL_ROOT_PASSWORD"] %>

development:
  <<: *default
  database: <%= ENV.fetch("MYSQL_DATABASE") { "elasticsearch_sample_development" } %>

test:
  <<: *default
  database: elasticsearch_sample_test
EOF

# 9. elasticsearch gems を Gemfile に追加
echo ""
echo "→ Gemfile に elasticsearch gems を追加..."
if ! grep -q "elasticsearch-model" Gemfile; then
  cat >> Gemfile << 'EOF'

# ElasticSearch
gem "elasticsearch-model", "~> 7.2"
gem "elasticsearch-rails", "~> 7.2"
EOF
fi

# 10. Gemfile.lock をクリア（bundle install で再解決させる）
> Gemfile.lock

# 11. 再ビルド（bundle install で全 gem を解決・インストール）
echo ""
echo "→ Docker イメージを再ビルド中..."
docker compose build

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "次のコマンドで起動してください:"
echo "  docker compose up"
echo ""
echo "起動後、別ターミナルでシードデータを投入:"
echo "  docker compose exec rails bundle exec rails db:seed"
