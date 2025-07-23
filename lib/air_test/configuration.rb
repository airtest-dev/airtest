# Handles configuration for AirTest, including API tokens and environment variables.
# frozen_string_literal: true

module AirTest
  # Handles configuration for AirTest, including API tokens and environment variables.
  class Configuration
    attr_accessor :notion_token, :notion_database_id, :jira_token, :jira_project_id, :monday_token, :monday_board_id, :github_token, :repo, :tool

    def initialize
      @tool = ENV.fetch("AIRTEST_TOOL", "notion")
      @notion_token = ENV.fetch("NOTION_TOKEN", nil)
      @notion_database_id = ENV.fetch("NOTION_DATABASE_ID", nil)
      @jira_token = ENV.fetch("JIRA_TOKEN", nil)
      @jira_project_id = ENV.fetch("JIRA_PROJECT_ID", nil)
      @monday_token = ENV.fetch("MONDAY_TOKEN", nil)
      @monday_board_id = ENV.fetch("MONDAY_BOARD_ID", nil)
      @github_token = ENV["GITHUB_BOT_TOKEN"] || ENV.fetch("GITHUB_TOKEN", nil)
      @repo = ENV.fetch("REPO", nil)
    end
  end
end
