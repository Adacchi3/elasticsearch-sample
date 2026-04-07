# Unit: ElasticSearch インデックス登録

## 概要
Article モデルと ElasticSearch を連携し、記事の保存時に自動でインデックスが更新される仕組みを実装する。

## 含まれるユーザーストーリー
- ストーリー 3: 記事のインデックス登録

## 責務
- `elasticsearch-model` / `elasticsearch-rails` gem の導入・設定
- `Article` モデルへの ElasticSearch インデックス設定（マッピング定義）
- 記事保存時の自動インデックス更新（コールバック）
- インデックス再構築用 Rake タスクの作成（`rake elasticsearch:reindex`）

## 境界
- 検索クエリの実装は Unit 004 が担当
- Article モデル・マイグレーション自体は Unit 002 が担当

## 依存関係

### 依存する Unit
- Unit 001: Docker Compose 開発環境構築（ElasticSearch が起動していること）
- Unit 002: シードデータ作成（Article モデルが存在すること）

### 外部依存
- `elasticsearch-model` gem
- `elasticsearch-rails` gem
- ElasticSearch 8.x

## 非機能要件（NFR）
- **パフォーマンス**: 特になし（サンプル規模）
- **セキュリティ**: 特になし
- **スケーラビリティ**: 特になし
- **可用性**: ElasticSearch 未起動時のエラーを適切に処理する

## 技術的考慮事項
- インデックスのマッピングでタイトル・本文を `text` 型、投稿日時を `date` 型で定義する
- ElasticSearch 8.x の認証設定（xpack.security）に対応する

## 関連Issue
- なし

## 実装優先度
High

## 見積もり
0.5日

---
## 実装状態

- **状態**: 完了
- **開始日**: 2026-04-07
- **完了日**: 2026-04-07
- **担当**: Claude
