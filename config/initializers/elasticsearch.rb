Elasticsearch::Client.new(
  url: ENV.fetch("ELASTICSEARCH_URL") { "http://localhost:9200" },
  log: Rails.env.development?
).tap do |client|
  Elasticsearch::Model.client = client
end
