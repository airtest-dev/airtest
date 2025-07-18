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
