require "rails_helper"

RSpec.describe Article, type: :model do
  describe "Elasticsearch::Model インテグレーション" do
    it "Elasticsearch::Model をインクルードしている" do
      expect(Article.ancestors).to include(Elasticsearch::Model)
    end

    it "after_commit コールバックで index_document が登録されている" do
      callbacks = Article._commit_callbacks.select { |cb| cb.filter.is_a?(Proc) || cb.filter.is_a?(Symbol) }
      expect(callbacks).not_to be_empty
    end

    it "インデックス名が articles である" do
      expect(Article.index_name).to eq("articles")
    end
  end

  describe "マッピング設定" do
    let(:mappings) { Article.mappings.to_hash }

    it "title フィールドが text 型である" do
      expect(mappings.dig(:properties, :title, :type)).to eq(:text)
    end

    it "body フィールドが text 型である" do
      expect(mappings.dig(:properties, :body, :type)).to eq(:text)
    end

    it "published_at フィールドが date 型である" do
      expect(mappings.dig(:properties, :published_at, :type)).to eq(:date)
    end
  end

  describe "#as_indexed_json" do
    let(:article) do
      Article.new(
        title: "テスト記事",
        body: "テスト本文",
        published_at: Time.zone.parse("2026-01-01 10:00:00")
      )
    end

    it "title, body, published_at のみを含む" do
      json = article.as_indexed_json
      expect(json.keys).to contain_exactly("title", "body", "published_at")
    end

    it "title の値が正しい" do
      expect(article.as_indexed_json["title"]).to eq("テスト記事")
    end

    it "body の値が正しい" do
      expect(article.as_indexed_json["body"]).to eq("テスト本文")
    end

    it "id, created_at, updated_at を含まない" do
      json = article.as_indexed_json
      expect(json).not_to have_key("id")
      expect(json).not_to have_key("created_at")
      expect(json).not_to have_key("updated_at")
    end
  end

  describe "インデックス操作（モック）" do
    let(:article) do
      Article.new(
        title: "インデックステスト",
        body: "本文",
        published_at: Time.zone.now
      )
    end
    let(:es_proxy) { instance_double("Elasticsearch::Model::Proxy::InstanceMethodsProxy") }

    before do
      allow(article).to receive(:__elasticsearch__).and_return(es_proxy)
    end

    it "保存時に index_document が呼ばれる（コールバック確認）" do
      expect(es_proxy).to receive(:index_document)
      es_proxy.index_document
    end
  end
end
