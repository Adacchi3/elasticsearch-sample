class ArticlesController < ApplicationController
  def search
    @keyword = params[:q].to_s.strip
    result = Article.search_by_keyword(@keyword)
    @total_count = result[:total]
    @results = result[:articles]

    respond_to do |format|
      format.html
      format.json { render json: { articles: @results } }
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Elastic::Transport::Transport::Error => e
    Rails.logger.error "Elasticsearch search failed: #{e.class} - #{e.message}"
    respond_to do |format|
      format.html do
        @keyword = params[:q].to_s.strip
        @results = []
        @total_count = 0
        @error_message = "検索サービスが現在利用できません。しばらくしてからお試しください。"
        render :search, status: :service_unavailable
      end
      format.json { render json: { error: "Search service is currently unavailable" }, status: :service_unavailable }
    end
  end
end
