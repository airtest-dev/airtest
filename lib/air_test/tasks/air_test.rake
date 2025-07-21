# frozen_string_literal: true

# Ensure the main gem is loaded
require "air_test"
 puts ">>> Loading AirTest Rake tasks from #{__FILE__}"
namespace :air_test do
  desc "Generate specs and PR from Notion tickets"
  task :generate_specs_from_notion, [:limit] do |_task, args|
    require "air_test/runner"
    AirTest.configure {} unless AirTest.configuration
    config = AirTest.configuration

    missing = []
    missing << "NOTION_TOKEN" unless config.notion_token
    missing << "NOTION_DATABASE_ID" unless config.notion_database_id
    missing << "GITHUB_TOKEN" unless config.github_token
    missing << "REPO" unless config.repo
    unless missing.empty?
      puts "❌ Missing required environment variables: #{missing.join(", ")}"
      exit 1
    end

    limit = (args[:limit] || 5).to_i
    puts "🚀 Starting AirTest with limit: #{limit}"
    
    begin
      runner = AirTest::Runner.new
      runner.run(limit: limit)
      puts "✅ AirTest completed successfully!"
    rescue StandardError => e
      puts "❌ AirTest failed: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      exit 1
    end
  end

  desc "Show AirTest configuration"
  task :config do
    require "air_test/configuration"
    AirTest.configure {} unless AirTest.configuration

    config = AirTest.configuration
    puts "🔧 AirTest Configuration:"
    puts "  Notion Token: #{config.notion_token ? "Set" : "Not set"}"
    puts "  Notion Database ID: #{config.notion_database_id || "Not set"}"
    puts "  GitHub Token: #{config.github_token ? "Set" : "Not set"}"
    puts "  Repository: #{config.repo || "Not set"}"
  end
end
