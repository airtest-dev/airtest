# frozen_string_literal: true

require_relative "ticket_parser"

module AirTest
  class JiraTicketParser
    include TicketParser
    def initialize(config = AirTest.configuration)
      # Add Jira-specific config here
    end

    def fetch_tickets(limit: 5)
      # TODO: Implement Jira API fetch logic
      []
    end

    def parse_ticket_content(page_id)
      # TODO: Implement Jira ticket parsing
      nil
    end

    def extract_ticket_title(ticket)
      # TODO: Map Jira fields to unified fields
      "No title"
    end

    def extract_ticket_id(ticket)
      "No ID"
    end

    def extract_ticket_url(ticket)
      ""
    end
  end
end 