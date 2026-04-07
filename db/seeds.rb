# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

articles = [
  {
    title: "Rubyにおけるブロックとプロックの違い",
    body: "Rubyではブロック、Proc、ラムダという3種類のクロージャが存在します。ブロックはメソッドに渡せる匿名関数で、do...endまたは{}で記述します。Procはブロックをオブジェクト化したもので、Proc.newまたはprocで生成できます。ラムダはProcの一種ですが、引数チェックとreturnの挙動が異なります。",
    published_at: Time.zone.parse("2026-01-10 10:00:00")
  },
  {
    title: "Ruby on RailsでのActive Recordの使い方",
    body: "Active RecordはRailsのORMです。モデルクラスはApplicationRecordを継承し、データベースのテーブルに対応します。基本的なCRUD操作はfind、create、update、destroyで行います。バリデーションはvalidatesメソッドで定義でき、presence、length、uniquenessなど多くのバリデータが用意されています。",
    published_at: Time.zone.parse("2026-01-15 09:00:00")
  },
  {
    title: "ElasticSearchの全文検索入門",
    body: "ElasticSearchは分散型の全文検索エンジンです。JSONドキュメントをインデックスに保存し、高速な検索が可能です。multi_matchクエリを使用するとtitleやbodyなど複数フィールドを横断して検索できます。日本語検索にはkuromojiアナライザーの導入が推奨されます。",
    published_at: Time.zone.parse("2026-01-20 14:00:00")
  },
  {
    title: "Dockerを使った開発環境構築",
    body: "Dockerを使うと開発環境をコンテナ化して再現性を高められます。docker-compose.ymlにRails、MySQL、ElasticSearchなどの各サービスを定義し、docker compose upで一括起動できます。depends_onとhealthcheckを組み合わせることで、依存サービスが準備完了してからアプリが起動するよう制御できます。",
    published_at: Time.zone.parse("2026-01-25 11:00:00")
  },
  {
    title: "イタリア料理の基本：パスタの茹で方",
    body: "本格的なパスタを作るには、たっぷりのお湯に塩を加えることが重要です。塩の量は水1リットルに対して10グラムが目安です。パスタはアルデンテに仕上げるため、パッケージの表示時間より1〜2分早めに引き上げます。ソースと絡める際に少量の茹で汁を加えると、乳化してなめらかな仕上がりになります。",
    published_at: Time.zone.parse("2026-02-01 12:00:00")
  },
  {
    title: "京都の紅葉スポットおすすめ5選",
    body: "京都の秋は世界中から観光客が訪れます。嵐山の竹林と紅葉のコントラストは絶景で、渡月橋からの眺めも見事です。南禅寺の水路閣と紅葉の組み合わせは写真映えします。清水寺の舞台からは市内を一望できる紅葉の眺望が楽しめます。永観堂は「紅葉の永観堂」として知られ、ライトアップも人気です。",
    published_at: Time.zone.parse("2026-02-10 10:30:00")
  },
  {
    title: "サッカーのパスワークを磨くトレーニング",
    body: "サッカーにおけるパスワークの向上には反復練習が欠かせません。三角形を意識したポジショニングでサポートの質が上がります。ワンタッチパスの練習では、ボールを受ける前に次のプレーを予測することが重要です。圧力下での正確なパスは、狭いエリアでのリターンパス練習で鍛えられます。",
    published_at: Time.zone.parse("2026-02-15 16:00:00")
  },
  {
    title: "TypeScriptで型安全なAPIクライアントを作る",
    body: "TypeScriptを使うとAPIレスポンスに型を付けられます。interfaceまたはtypeでレスポンス型を定義し、fetchやaxiosの返り値に適用します。ジェネリクスを活用することで汎用的なAPIクライアントクラスを実装できます。zodなどのバリデーションライブラリと組み合わせると実行時の型安全性も確保できます。",
    published_at: Time.zone.parse("2026-02-20 13:00:00")
  },
  {
    title: "自家製パンの焼き方：初心者向けガイド",
    body: "自家製パンの基本は材料の計量と発酵管理です。強力粉、水、塩、イーストの配合が重要で、水温は季節によって調整します。一次発酵は生地が約2倍になるまで行い、パンチで余分なガスを抜きます。二次発酵後は高温のオーブンで短時間で焼き上げることでクラストがパリッと仕上がります。",
    published_at: Time.zone.parse("2026-03-01 08:00:00")
  },
  {
    title: "PostgreSQLとMySQLの違いを比較する",
    body: "PostgreSQLとMySQLはどちらも人気のオープンソースRDBMSですが、特徴が異なります。PostgreSQLはSQLへの準拠度が高く、JSONBや配列型など高度なデータ型をサポートします。MySQLはシンプルで高速な読み取りが得意で、Webアプリケーションで広く採用されています。トランザクションの扱いや全文検索機能にも差異があります。",
    published_at: Time.zone.parse("2026-03-10 15:00:00")
  }
]

created_count = 0
articles.each do |attrs|
  Article.find_or_create_by!(title: attrs[:title]) do |article|
    article.body = attrs[:body]
    article.published_at = attrs[:published_at]
    created_count += 1
  end
end

puts "Seeded #{articles.size} articles (#{created_count} created, #{articles.size - created_count} skipped)."

# TODO: Unit 003 完了後にElasticSearchへのインデックス処理を追加
# Article.import force: true
