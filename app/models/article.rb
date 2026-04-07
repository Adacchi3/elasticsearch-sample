class Article < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validates :published_at, presence: true
end
