# frozen_string_literal: true

module AirTest
  class Configuration
    attr_accessor :notion_token, :notion_database_id, :github_token, :repo

    def initialize
      @notion_token = ENV['NOTION_TOKEN']
      @notion_database_id = ENV['NOTION_DATABASE_ID']
      @github_token = ENV['GITHUB_BOT_TOKEN'] || ENV['GITHUB_TOKEN']
      @repo = nil
    end
  end
end 