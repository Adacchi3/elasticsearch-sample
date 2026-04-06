# PRFAQ: elasticsearch-sample

## Press Release（プレスリリース）

**見出し**: Rails × ElasticSearch 全文検索サンプル — Docker で即起動、すぐ試せる

**副見出し**: Ruby on Rails と ElasticSearch を組み合わせた全文検索の実装パターンをシンプルに示すリファレンス実装

**発表日**: 2026-04-06

**本文**:

[背景] Rails アプリケーションに ElasticSearch を組み込む際、環境構築から検索実装までの一連のパターンを手軽に確認できるサンプルが少ない。

[プロダクト] `docker compose up` の一コマンドで Rails・MySQL・ElasticSearch が起動し、`db:seed` でサンプル記事が投入される。その後すぐにキーワード検索 API を叩いて動作確認できる。

[顧客の声] 「ElasticSearch を Rails に組み込んでみたいが、まず動く状態で試したかった。このサンプルで全体像をつかめた。」

[今後の展開] ページネーション、オートコンプリート、ファセット検索など発展的な実装パターンへの拡張が可能。

## FAQ（よくある質問）

### Q1: どの Ruby / Rails / ElasticSearch バージョンを使っていますか？
A: Rails 8.x、Ruby 3.x、ElasticSearch 8.x を使用しています。Docker イメージのバージョンで調整可能です。

### Q2: データベースは変更できますか？
A: このサンプルは MySQL を前提としていますが、`database.yml` と Docker Compose を変更することで PostgreSQL 等に切り替えることもできます。

### Q3: 本番環境への適用は想定していますか？
A: このサンプルは学習・検証用途を目的としており、本番環境への直接適用は想定していません。
