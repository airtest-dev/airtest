# frozen_string_literal: true

require_relative "lib/air_test/version"

Gem::Specification.new do |spec|
  spec.name = "air_test"
  spec.version = AirTest::VERSION
  spec.authors = ["julien bouland"]
  spec.email = ["bouland.julien@gmail.com"]

  spec.summary = "Generate specs and PR from Notion"
  spec.description = "Automate the generation of Turnip/RSpec specs from Notion tickets, create branches, " \
                     "commits, pushes, and GitHub Pull Requests. All with a single Rake command."
  spec.homepage = "https://github.com/airtest-dev/airtest"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/airtest-io/air_test/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # Rails dependency for engine and Rake task support
  spec.add_dependency "rails", ">= 6.0"

  # API dependencies
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "octokit", "~> 7.0"

  # CLI dependencies
  spec.add_dependency "tty-prompt", "~> 0.23"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
