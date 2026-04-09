require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /articles/search" do
    let(:empty_result) { { total: 0, articles: [] } }
    let(:search_result) do
      {
        total: 1,
        articles: [
          { id: 1, title: "Rails 入門", body_excerpt: "本文の抜粋", published_at: "2026年01月15日 10:00" }
        ]
      }
    end

    context "キーワードが空の場合" do
      before { allow(Article).to receive(:search_by_keyword).and_return(empty_result) }

      it "200 を返す" do
        get search_articles_path
        expect(response).to have_http_status(:ok)
      end

      it "JSON で空の articles 配列を返す" do
        get search_articles_path, params: { q: "" }, headers: { "Accept" => "application/json" }
        json = JSON.parse(response.body)
        expect(json["articles"]).to eq([])
      end
    end

    context "キーワードあり・マッチありの場合" do
      before { allow(Article).to receive(:search_by_keyword).with("Rails").and_return(search_result) }

      it "200 を返す" do
        get search_articles_path, params: { q: "Rails" }
        expect(response).to have_http_status(:ok)
      end

      it "JSON で articles を返す" do
        get search_articles_path, params: { q: "Rails" }, headers: { "Accept" => "application/json" }
        json = JSON.parse(response.body)
        expect(json["articles"].size).to eq(1)
        expect(json["articles"].first["title"]).to eq("Rails 入門")
      end
    end

    context "Elasticsearch 接続失敗の場合" do
      before do
        allow(Article).to receive(:search_by_keyword).and_raise(Faraday::ConnectionFailed.new("Connection refused"))
      end

      it "JSON リクエストで 503 を返す" do
        get search_articles_path, params: { q: "Rails" }, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end

      it "HTML リクエストで 503 を返す" do
        get search_articles_path, params: { q: "Rails" }
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
