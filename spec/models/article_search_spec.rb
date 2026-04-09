require "rails_helper"

RSpec.describe Article, type: :model do
  describe ".search_by_keyword" do
    context "キーワードが空の場合" do
      it "total: 0, articles: [] を返す" do
        result = Article.search_by_keyword("")
        expect(result).to eq({ total: 0, articles: [] })
      end

      it "nil でも total: 0, articles: [] を返す" do
        result = Article.search_by_keyword(nil)
        expect(result).to eq({ total: 0, articles: [] })
      end

      it "空白のみでも total: 0, articles: [] を返す（Elasticsearch に問い合わせない）" do
        expect(Article).not_to receive(:search)
        result = Article.search_by_keyword("   ")
        expect(result).to eq({ total: 0, articles: [] })
      end
    end

    context "キーワードあり・マッチなしの場合" do
      let(:mock_response) do
        instance_double(
          Elasticsearch::Model::Response::Response,
          results: [],
          response: { "hits" => { "total" => { "value" => 0 } } }
        )
      end

      before { allow(Article).to receive(:search).and_return(mock_response) }

      it "total: 0, articles: [] を返す" do
        result = Article.search_by_keyword("該当なしキーワード")
        expect(result).to eq({ total: 0, articles: [] })
      end
    end

    context "キーワードあり・マッチありの場合" do
      let(:long_body) { "Ruby on Rails の使い方を解説します。" * 10 }
      let(:mock_source) do
        double("source",
          id: 1,
          title: "Rails 入門",
          body: long_body,
          published_at: "2026-01-15T10:00:00.000Z"
        )
      end
      let(:mock_hit) { double("hit", _source: mock_source) }
      let(:mock_response) do
        instance_double(
          Elasticsearch::Model::Response::Response,
          results: [ mock_hit ],
          response: { "hits" => { "total" => { "value" => 1 } } }
        )
      end

      before { allow(Article).to receive(:search).and_return(mock_response) }

      it "total と articles を返す" do
        result = Article.search_by_keyword("Rails")
        expect(result[:total]).to eq(1)
        expect(result[:articles].size).to eq(1)
      end

      it "articles に id, title, body_excerpt, published_at が含まれる" do
        result = Article.search_by_keyword("Rails")
        article = result[:articles].first
        expect(article).to include(:id, :title, :body_excerpt, :published_at)
      end

      it "body_excerpt が最大200文字にトリミングされる" do
        result = Article.search_by_keyword("Rails")
        expect(result[:articles].first[:body_excerpt].length).to be <= 200
      end

      it "published_at がフォーマット済み文字列で返る" do
        result = Article.search_by_keyword("Rails")
        expect(result[:articles].first[:published_at]).to eq("2026年01月15日 10:00")
      end

      it "multi_match クエリで title と body を検索する" do
        expect(Article).to receive(:search).with(
          hash_including(
            query: hash_including(
              multi_match: hash_including(fields: [ "title", "body" ])
            )
          )
        ).and_return(mock_response)
        Article.search_by_keyword("Rails")
      end
    end

    context "published_at が不正な値の場合" do
      let(:mock_source) { double("source", id: 2, title: "記事", body: "本文", published_at: "invalid-date") }
      let(:mock_hit) { double("hit", _source: mock_source) }
      let(:mock_response) do
        instance_double(
          Elasticsearch::Model::Response::Response,
          results: [ mock_hit ],
          response: { "hits" => { "total" => { "value" => 1 } } }
        )
      end

      before { allow(Article).to receive(:search).and_return(mock_response) }

      it "published_at が '不明' になる" do
        result = Article.search_by_keyword("記事")
        expect(result[:articles].first[:published_at]).to eq("不明")
      end
    end
  end
end
