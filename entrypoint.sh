#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Install/update gems (keeps in sync with Gemfile changes)
bundle install

# Run database migrations
bundle exec rails db:create 2>/dev/null || true
bundle exec rails db:migrate

exec "$@"
