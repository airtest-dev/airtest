namespace :air_test do
  desc "Generate specs and PR from Notion"
  task generate_specs_from_notion: :environment do
    require 'air_test/runner'
    AirTest::Runner.new.run(limit: 5)
  end
end