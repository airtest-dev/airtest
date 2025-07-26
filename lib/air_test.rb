# frozen_string_literal: true

# Main namespace for the AirTest gem, which automates spec generation and GitHub integration.
module AirTest
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end

require_relative "air_test/version"
require_relative "air_test/configuration"
require_relative "air_test/ticket_parser"
require_relative "air_test/notion_ticket_parser"
require_relative "air_test/jira_ticket_parser"
require_relative "air_test/monday_ticket_parser"
require_relative "air_test/spec_generator"
require_relative "air_test/github_client"
require_relative "air_test/runner"

# Load Rails engine if Rails is available (for Rake task support)
require_relative "air_test/engine" if defined?(Rails)
