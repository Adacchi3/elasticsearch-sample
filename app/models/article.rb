class Article < ApplicationRecord
  include Elasticsearch::Model

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validates :published_at, presence: true

  index_name "articles"

  settings do
    mappings dynamic: false do
      indexes :title, type: :text
      indexes :body, type: :text
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
end
