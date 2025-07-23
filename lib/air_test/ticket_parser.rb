# frozen_string_literal: true

module AirTest
  # Interface for ticket parsers (Notion, Jira, Monday, etc.)
  module TicketParser
    def fetch_tickets(limit: 5)
      raise NotImplementedError
    end

    def parse_ticket_content(page_id)
      raise NotImplementedError
    end

    def extract_ticket_title(ticket)
      raise NotImplementedError
    end

    def extract_ticket_id(ticket)
      raise NotImplementedError
    end

    def extract_ticket_url(ticket)
      raise NotImplementedError
    end
  end
end 