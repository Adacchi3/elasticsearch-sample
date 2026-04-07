# ドメインモデル: シードデータ作成（Article）

## 概要
開発環境での全文検索動作確認に使用するサンプル記事データを管理するドメインモデル。`Article` エンティティが記事の属性（タイトル・本文・投稿日時）を保持し、シードスクリプトで冪等に生成される。

**重要**: このドメインモデル設計では**コードは書かず**、構造と責務の定義のみを行います。実装はImplementation Phase（コード生成ステップ）で行います。

## エンティティ（Entity）

### Article（記事）
- **ID**: Integer（Rails デフォルトの auto-increment）
- **属性**:
  - `title`: String（255文字以内） - 記事タイトル。検索対象フィールド
  - `body`: Text - 記事本文。検索対象フィールド
  - `published_at`: Datetime - 記事の投稿日時。検索結果の表示・ソートに使用
  - `created_at`: Datetime（Rails 自動管理） - レコード作成日時
  - `updated_at`: Datetime（Rails 自動管理） - レコード更新日時
- **バリデーション**:
  - `title`: 必須（presence: true）
  - `body`: 必須（presence: true）
  - `published_at`: 必須（presence: true）
- **振る舞い**:
  - 特になし（本 Unit では CRUD 操作を提供しない）

## 値オブジェクト（Value Object）

なし（シンプルな属性のみで構成されるため）

## 集約（Aggregate）

### Article 集約
- **集約ルート**: Article
- **含まれる要素**: Article エンティティのみ
- **境界**: 1記事 = 1集約（他エンティティとの関連なし）
- **不変条件**: title・body・published_at はすべて必須

## ドメインサービス

なし（シードデータ生成はインフラ層の責務であり、ドメインサービスとして定義しない）

## リポジトリインターフェース

### ArticleRepository
- **対象集約**: Article
- **操作**:
  - `find_by_identifier(title)` - タイトルを識別子として検索（冪等生成の基準）
  - `save(article)` - 永続化
  - `find_all` - 全件取得（ElasticSearch インデックス再構築時に使用）

**注**: 具体的な実装方法（Active Record の `find_or_create_by!` 等）は論理設計で定義する。

## ユビキタス言語

- **Article（記事）**: タイトル・本文・投稿日時を持つ検索対象コンテンツの単位
- **seed（シード）**: 開発・テスト環境向けの初期サンプルデータ投入処理
- **冪等性**: 同一の seed スクリプトを複数回実行しても、データが重複しない性質

## 不明点と質問（設計中に記録）

特になし（Unit 定義から属性・責務が明確に定まったため）
