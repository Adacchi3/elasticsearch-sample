namespace :elasticsearch do
  desc "Reindex all articles into Elasticsearch"
  task reindex: :environment do
    puts "Creating index..."
    Article.__elasticsearch__.create_index!(force: true)

    puts "Importing articles..."
    result = Article.__elasticsearch__.import

    puts "Done. #{Article.count} articles imported (#{result} failed)."
  end
end
