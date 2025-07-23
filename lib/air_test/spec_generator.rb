# Generates RSpec and Turnip spec files from parsed Notion ticket data for AirTest.
# frozen_string_literal: true

require "fileutils"

module AirTest
  # Generates RSpec and Turnip spec files from parsed Notion ticket data for AirTest.
  class SpecGenerator
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def generate_spec_from_parsed_data(ticket_id, parsed_data, output_dir: "spec/features")
      feature_slug = parsed_data[:feature].downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "").slice(0, 50)
      filename = "#{feature_slug}_fdr#{ticket_id}.rb"
      filepath = File.join(output_dir, filename)
      FileUtils.mkdir_p(output_dir)
      File.open(filepath, "w") do |f|
        f.puts "# language: turnip"
        f.puts "# frozen_string_literal: true\n"
        f.puts "feature '#{parsed_data[:feature]}' do"
        parsed_data[:scenarios].each do |scenario|
          f.puts "  scenario '#{scenario[:title]}' do"
          scenario[:steps].each do |step|
            f.puts "    pending '#{step}'"
          end
          f.puts "  end"
          f.puts ""
        end
        f.puts "end"
      end
      filepath
    end

    def generate_step_definitions_for_spec(spec_filepath, output_dir: "spec/steps")
      step_texts = []
      File.readlines(spec_filepath).each do |line|
        step_texts << ::Regexp.last_match(1).strip if line =~ /pending ['\"](.*)['\"]/
      end
      return if step_texts.empty?

      spec_filename = File.basename(spec_filepath, ".rb")
      step_file = File.join(output_dir, "#{spec_filename}_steps.rb")
      FileUtils.mkdir_p(output_dir)
      File.open(step_file, "w") do |f|
        f.puts "# Auto-generated step definitions for #{spec_filename.gsub("-", " ")}"
        step_texts.uniq.each do |step|
          f.puts "\nstep '#{step}' do"
          f.puts "  pending 'Implement: #{step.gsub("'", "\\'")}'"
          f.puts "end"
        end
      end
      step_file
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
