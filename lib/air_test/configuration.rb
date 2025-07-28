# Handles configuration for AirTest, including API tokens and environment variables.
# frozen_string_literal: true

module AirTest
  # Handles configuration for AirTest, including API tokens and environment variables.
  class Configuration
    attr_accessor :tool, :notion, :jira, :monday, :github, :repo

    def initialize
      @tool = ENV.fetch("AIRTEST_TOOL", "notion")
      @notion = {
        token: ENV.fetch("NOTION_TOKEN", nil),
        database_id: ENV.fetch("NOTION_DATABASE_ID", nil)
      }
      @jira = {
        token: ENV.fetch("JIRA_TOKEN", nil),
        project_id: ENV.fetch("JIRA_PROJECT_ID", nil),
        domain: ENV.fetch("JIRA_DOMAIN", nil),
        email: ENV.fetch("JIRA_EMAIL", nil)
      }
      @monday = {
        token: ENV.fetch("MONDAY_TOKEN", nil),
        board_id: ENV.fetch("MONDAY_BOARD_ID", nil),
        domain: ENV.fetch("MONDAY_DOMAIN", nil)
      }
      @github = {
        token: ENV["GITHUB_BOT_TOKEN"] || ENV.fetch("GITHUB_TOKEN", nil)
      }
      @repo = ENV.fetch("REPO", nil)
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
