# Handles configuration for AirTest, including API tokens and environment variables.
# frozen_string_literal: true

module AirTest
  # Handles configuration for AirTest, including API tokens and environment variables.
  class Configuration
    attr_accessor :tool, :notion, :jira, :monday, :github, :repo

    def initialize
      @tool = ENV.fetch("AIRTEST_TOOL", "notion")
      @notion = {
        token: ENV["NOTION_TOKEN"],
        database_id: ENV["NOTION_DATABASE_ID"]
      }
      @jira = {
        token: ENV["JIRA_TOKEN"],
        project_id: ENV["JIRA_PROJECT_ID"],
        domain: ENV["JIRA_DOMAIN"],
        email: ENV["JIRA_EMAIL"]
      }
      @monday = {
        token: ENV["MONDAY_TOKEN"],
        board_id: ENV["MONDAY_BOARD_ID"],
        domain: ENV["MONDAY_DOMAIN"]
      }
      @github = {
        token: ENV["GITHUB_BOT_TOKEN"] || ENV["GITHUB_TOKEN"]
      }
      @repo = ENV["REPO"]
    end

    def validate!
      case tool.to_s.downcase
      when "notion"
        raise "Missing NOTION_TOKEN" unless notion[:token]
        raise "Missing NOTION_DATABASE_ID" unless notion[:database_id]
      when "jira"
        raise "Missing JIRA_TOKEN" unless jira[:token]
        raise "Missing JIRA_PROJECT_ID" unless jira[:project_id]
        raise "Missing JIRA_DOMAIN" unless jira[:domain]
        raise "Missing JIRA_EMAIL" unless jira[:email]
      when "monday"
        raise "Missing MONDAY_TOKEN" unless monday[:token]
        raise "Missing MONDAY_BOARD_ID" unless monday[:board_id]
        raise "Missing MONDAY_DOMAIN" unless monday[:domain]
      end
    end
  end
end
