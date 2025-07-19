# frozen_string_literal: true

namespace :air_test do
  desc "Generate specs and PR from Notion tickets"
  task :generate_specs_from_notion, [:limit] => :environment do |_task, args|
    require "air_test/runner"

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
  task config: :environment do
    require "air_test/configuration"

    config = AirTest.configuration
    puts "🔧 AirTest Configuration:"
    puts "  Notion Token: #{config.notion_token ? "Set" : "Not set"}"
    puts "  Notion Database ID: #{config.notion_database_id || "Not set"}"
    puts "  GitHub Token: #{config.github_token ? "Set" : "Not set"}"
    puts "  Repository: #{config.repo || "Not set"}"
  end
end
