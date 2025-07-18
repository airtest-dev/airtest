# frozen_string_literal: true

require_relative "air_test/version"
require_relative "air_test_automation/configuration"
require_relative "air_test_automation/notion_parser"
require_relative "air_test_automation/spec_generator"
require_relative "air_test_automation/github_client"
require_relative "air_test_automation/rake_tasks"

module AirTest
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
