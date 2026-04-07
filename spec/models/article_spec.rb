require "rails_helper"

RSpec.describe Article, type: :model do
  describe "バリデーション" do
    let(:valid_attributes) do
      {
        title: "テスト記事タイトル",
        body: "テスト記事の本文です。",
        published_at: Time.zone.now
      }
    end

    it "title、body、published_at がすべて揃っていれば有効" do
      article = Article.new(valid_attributes)
      expect(article).to be_valid
    end

    it "title が空の場合は無効" do
      article = Article.new(valid_attributes.merge(title: ""))
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it "title が nil の場合は無効" do
      article = Article.new(valid_attributes.merge(title: nil))
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it "title が 255 文字以内であれば有効" do
      article = Article.new(valid_attributes.merge(title: "a" * 255))
      expect(article).to be_valid
    end

    it "title が 256 文字以上の場合は無効" do
      article = Article.new(valid_attributes.merge(title: "a" * 256))
      expect(article).not_to be_valid
      expect(article.errors[:title]).to be_present
    end

    it "body が空の場合は無効" do
      article = Article.new(valid_attributes.merge(body: ""))
      expect(article).not_to be_valid
      expect(article.errors[:body]).to include("can't be blank")
    end

    it "body が nil の場合は無効" do
      article = Article.new(valid_attributes.merge(body: nil))
      expect(article).not_to be_valid
      expect(article.errors[:body]).to include("can't be blank")
    end

    it "published_at が nil の場合は無効" do
      article = Article.new(valid_attributes.merge(published_at: nil))
      expect(article).not_to be_valid
      expect(article.errors[:published_at]).to include("can't be blank")
    end
  end

  describe "属性" do
    it "title、body、published_at の属性を持つ" do
      article = Article.new
      expect(article).to respond_to(:title)
      expect(article).to respond_to(:body)
      expect(article).to respond_to(:published_at)
    end
  end
end
