class Article < ApplicationRecord
  include Elasticsearch::Model

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validates :published_at, presence: true

  index_name "articles"

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :title, type: :text, analyzer: "kuromoji"
      indexes :body,  type: :text, analyzer: "kuromoji"
      indexes :published_at, type: :date
    end
  end

  after_commit on: [ :create, :update ] do
    __elasticsearch__.index_document
  rescue StandardError => e
    Rails.logger.error "Elasticsearch index_document failed: #{e.message}"
  end

  after_commit on: :destroy do
    __elasticsearch__.delete_document
  rescue StandardError => e
    Rails.logger.error "Elasticsearch delete_document failed: #{e.message}"
  end

  def as_indexed_json(_options = {})
    as_json(only: %i[title body published_at])
  end

  class << self
    def search_by_keyword(keyword)
      keyword = keyword.to_s.strip
      return { total: 0, articles: [] } if keyword.empty?

      response = search(multi_match_query(keyword))
      total = response.response["hits"]["total"]["value"]
      articles = response.results.map { |hit| build_search_result(hit._source) }
      { total: total, articles: articles }
    end

    private

    def multi_match_query(keyword)
      {
        query: {
          multi_match: {
            query: keyword,
            fields: [ "title", "body" ]
          }
        }
      }
    end

    def build_search_result(source)
      {
        id: source.id,
        title: source.title,
        body_excerpt: truncate_body(source.body.to_s),
        published_at: format_published_at(source.published_at)
      }
    end

    def truncate_body(body)
      return "" if body.empty?
      body.length > 200 ? "#{body[0, 197]}..." : body
    end

    def format_published_at(value)
      return "不明" if value.blank?
      Time.parse(value.to_s).strftime("%Y年%m月%d日 %H:%M")
    rescue ArgumentError
      "不明"
    end
  end
end
