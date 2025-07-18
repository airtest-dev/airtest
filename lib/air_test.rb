# frozen_string_literal: true

require_relative "air_test/version"
require_relative "air_test/configuration"
require_relative "air_test/notion_parser"
require_relative "air_test/spec_generator"
require_relative "air_test/github_client"
require_relative "air_test/rake_tasks"

module AirTest
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
