# frozen_string_literal: true

module AirTest
  class Engine < ::Rails::Engine
    # This ensures that the Rake tasks are automatically loaded when the gem is included in a Rails app
    rake_tasks do
      import File.expand_path("../../tasks/air_test.rake", __FILE__)
    end
  end
end
