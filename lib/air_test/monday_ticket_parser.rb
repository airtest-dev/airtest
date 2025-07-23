# frozen_string_literal: true

require_relative "ticket_parser"

module AirTest
  class MondayTicketParser
    include TicketParser
    def initialize(config = AirTest.configuration)
      # Add Monday-specific config here
    end

    def fetch_tickets(limit: 5)
      # TODO: Implement Monday API fetch logic
      []
    end

    def parse_ticket_content(page_id)
      # TODO: Implement Monday ticket parsing
      nil
    end

    def extract_ticket_title(ticket)
      # TODO: Map Monday fields to unified fields
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