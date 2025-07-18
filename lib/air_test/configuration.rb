# Handles configuration for AirTest, including API tokens and environment variables.
# frozen_string_literal: true

module AirTest
  # Handles configuration for AirTest, including API tokens and environment variables.
  class Configuration
    attr_accessor :notion_token, :notion_database_id, :github_token, :repo

    def initialize
      @notion_token = ENV.fetch("NOTION_TOKEN", nil)
      @notion_database_id = ENV.fetch("NOTION_DATABASE_ID", nil)
      @github_token = ENV["GITHUB_BOT_TOKEN"] || ENV.fetch("GITHUB_TOKEN", nil)
      @repo = nil
    end
  end
end
