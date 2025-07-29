AirTest.configure do |config|
  config.notion_token = ENV['NOTION_TOKEN']
  config.notion_database_id = ENV['NOTION_DATABASE_ID']
  config.github_token = ENV['GITHUB_BOT_TOKEN']
  config.repo = 'your-org/your-repo' # format: 'organization/repo_name'
end
