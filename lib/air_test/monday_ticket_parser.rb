# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require_relative 'ticket_parser'

module AirTest
  class MondayTicketParser
    include TicketParser
    def initialize(config = AirTest.configuration)
      @api_token = config.monday[:token]
      @board_id = config.monday[:board_id]
      @domain = config.monday[:domain]
      @base_url = 'https://api.monday.com/v2'
    end

    def fetch_tickets(limit: 5)
      # First, get all items from the board
      query = <<~GRAPHQL
        query {
          boards(ids: "#{@board_id}") {
            items_page {
              items {
                id
                name
                column_values {
                  id
                  text
                  value
                }
              }
            }
          }
        }
      GRAPHQL

      response = make_graphql_request(query)
      return [] unless response['data']

      items = response.dig('data', 'boards', 0, 'items_page', 'items') || []

      # Filter for items with "Not Started" status
      not_started_items = items.select do |item|
        status_column = item['column_values'].find { |cv| cv['id'] == 'project_status' }
        status_column && status_column['text'] == 'Not Started'
      end

      not_started_items.first(limit)
    end

    def parse_ticket_content(item_id)
      # For Monday, we'll use the item name as feature and create a simple scenario
      # In the future, you could add a description column to Monday and parse it like Notion
      {
        feature: "Feature: #{extract_ticket_title({ 'id' => item_id, 'name' => 'Loading...' })}",
        scenarios: [
          {
            title: 'Scenario',
            steps: ['Implement the feature']
          }
        ],
        meta: { tags: [], priority: '', estimate: nil, assignee: '' }
      }
    end

    def extract_ticket_title(ticket)
      ticket['name'] || 'No title'
    end

    def extract_ticket_id(ticket)
      ticket['id'] || 'No ID'
    end

    def extract_ticket_url(ticket)
      "https://#{@domain}/boards/#{@board_id}/pulses/#{ticket['id']}"
    end

    private

    def make_graphql_request(query)
      uri = URI(@base_url)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = @api_token
      request['Content-Type'] = 'application/json'
      request.body = { query: query }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(request)
      
      return {} unless response.code == '200'
      
      JSON.parse(response.body)
    rescue JSON::ParserError
      {}
    end
  end
end 