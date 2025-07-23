# frozen_string_literal: true

# Runs the main automation workflow for AirTest, orchestrating Notion parsing and GitHub actions.
# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/BlockLength
module AirTest
  # Runs the main automation workflow for AirTest, orchestrating Notion parsing and GitHub actions.
  class Runner
    def initialize(config = AirTest.configuration)
      @notion = NotionParser.new(config)
      @spec = SpecGenerator.new
      @github = GithubClient.new(config)
    end

    def run(limit: 5)
      tickets = @notion.fetch_tickets(limit: limit)
      puts "🔍 Found #{tickets.length} tickets"
      tickets.each do |ticket|
        ticket_id = @notion.extract_ticket_id(ticket)
        title = @notion.extract_ticket_title(ticket)
        url = @notion.extract_ticket_url(ticket)
        puts "\n📋 Processing: FDR#{ticket_id} - #{title}"
        parsed_data = @notion.parse_ticket_content(ticket["id"])
        unless parsed_data && parsed_data[:feature] && !parsed_data[:feature].empty?
          puts "⚠️  Skipping ticket FDR#{ticket_id} due to missing or empty feature."
          next
        end

        branch = "air_test/#{ticket_id}-#{title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")}"
        spec_path = @spec.generate_spec_from_parsed_data(ticket_id, parsed_data)
        step_path = @spec.generate_step_definitions_for_spec(spec_path)
        files_to_commit = [spec_path]
        files_to_commit << step_path if step_path
        has_changes = @github.commit_and_push_branch(branch, files_to_commit,
                                                     "Add specs for Notion ticket #{ticket_id}")
        if has_changes
          pr_title = title
          scenarios_md = parsed_data[:scenarios].map.with_index(1) do |sc, _i|
            steps = sc[:steps]&.map { |step| "      - #{step}" }&.join("\n")
            "  - [ ] #{sc[:title]}\n#{steps}"
          end.join("\n")
          pr_body = <<~MD
              - **Story Notion :** #{url}
              - **Feature** : #{parsed_data[:feature]}
              - **Scénarios** :
            #{scenarios_md}
          MD
          pr = @github.create_pull_request(branch, pr_title, pr_body)
          puts "✅ Pull Request créée : #{pr.html_url}" if pr
        else
          puts "⚠️  Aucun changement détecté, PR non créée."
        end
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/BlockLength
