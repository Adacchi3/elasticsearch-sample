# ユーザーストーリー

## Epic: Rails × ElasticSearch 全文検索サンプル

### ストーリー 1: 開発環境構築
**優先順位**: Must-have

As a 開発者
I want to Docker Compose で Rails・MySQL・ElasticSearch をまとめて起動できる
So that ローカル環境をすぐに構築して動作確認できる

**受け入れ基準**:
- [ ] `docker compose up` で Rails アプリ・MySQL・ElasticSearch の3サービスが起動する
- [ ] Rails アプリが MySQL に接続できる
- [ ] Rails アプリが ElasticSearch に接続できる
- [ ] `docker compose up` 後にブラウザでアプリにアクセスできる

**技術的考慮事項**:
- Docker Compose で各サービスのポートを適切に設定する
- 環境変数で DB・ElasticSearch の接続先を設定する

---

### ストーリー 2: シードデータ作成
**優先順位**: Must-have

As a 開発者
I want to `db:seed` を実行するだけで記事のサンプルデータが登録される
So that すぐに検索機能を試せる

**受け入れ基準**:
- [ ] `rails db:seed` を実行すると記事データ（タイトル・本文・投稿日時）が MySQL に登録される
- [ ] seed 実行後に ElasticSearch にも同じ記事データがインデックスされる
- [ ] seed は冪等（複数回実行しても重複しない）

**技術的考慮事項**:
- 検索結果の差がわかるよう、内容の異なる記事を複数件用意する

---

### ストーリー 3: 記事のインデックス登録
**優先順位**: Must-have

As a 開発者
I want to 記事データが ElasticSearch に自動でインデックスされる
So that 検索対象として利用できる

**受け入れ基準**:
- [ ] 記事モデルの保存時に ElasticSearch へ自動的にインデックスが更新される
- [ ] インデックスにタイトル・本文・投稿日時が含まれる
- [ ] インデックス再構築用の Rake タスクが存在する（`rake elasticsearch:reindex` 等）

**技術的考慮事項**:
- `elasticsearch-model` gem（または同等のライブラリ）を使用する
- コールバックでインデックスを自動更新する

---

### ストーリー 4: 全文検索
**優先順位**: Must-have

As a 開発者
I want to キーワードで記事を全文検索できる
So that ElasticSearch の検索機能の動作を確認できる

**受け入れ基準**:
- [ ] キーワードを入力して検索リクエストを送ると、タイトルまたは本文にマッチする記事が返却される
- [ ] 検索結果にタイトル・本文の抜粋・投稿日時が含まれる
- [ ] キーワードが空の場合は全件または適切なメッセージを返す
- [ ] マッチしない場合は空のリストを返す

**技術的考慮事項**:
- ElasticSearch の `multi_match` クエリでタイトルと本文を対象に検索する
- 本文抜粋は ElasticSearch の highlight 機能またはアプリ側でトリミングする
