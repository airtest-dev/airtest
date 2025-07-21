# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Load AirTest Rake tasks for development
# load File.expand_path("lib/tasks/air_test.rake", __dir__)

task default: %i[spec rubocop]
