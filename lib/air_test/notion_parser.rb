# Parses Notion tickets and extracts relevant information for spec generation in AirTest.
# rubocop:disable Metrics/ClassLength
# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module AirTest
  # Parses Notion tickets and extracts relevant information for spec generation in AirTest.
  class NotionParser
    def initialize(config = AirTest.configuration)
      @database_id = config.notion_database_id
      @notion_token = config.notion_token
      @base_url = "https://api.notion.com/v1"
    end

    def fetch_tickets(limit: 5)
      uri = URI("#{@base_url}/databases/#{@database_id}/query")
      response = make_api_request(uri, { page_size: 100 })
      return [] unless response.code == "200"

      data = JSON.parse(response.body)
      data["results"].first(limit)
    end

    def parse_ticket_content(page_id)
      blocks = get_page_content(page_id)
      return nil unless blocks

      parse_content(blocks)
    end

    def extract_ticket_title(ticket)
      ticket.dig("properties", "Projects", "title", 0, "plain_text") || "No title"
    end

    def extract_ticket_id(ticket)
      ticket.dig("properties", "ID", "unique_id", "number") || "No ID"
    end

    def extract_ticket_url(ticket)
      ticket["url"] || "https://www.notion.so/#{ticket["id"].gsub("-", "")}"
    end

    private

    def get_page_content(page_id)
      uri = URI("#{@base_url}/blocks/#{page_id}/children")
      response = make_api_request(uri, nil, "GET")
      return nil unless response.code == "200"

      data = JSON.parse(response.body)
      data["results"]
    end

    # rubocop:disable Metrics/MethodLength
    def make_api_request(uri, request_body = nil, method = "POST")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      if method == "GET"
        request = Net::HTTP::Get.new(uri)
      else
        request = Net::HTTP::Post.new(uri)
        request.body = request_body.to_json if request_body
      end
      request["Authorization"] = "Bearer #{@notion_token}"
      request["Notion-Version"] = "2022-06-28"
      request["Content-Type"] = "application/json"
      http.request(request)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/BlockLength
    def parse_content(blocks)
      parsed_data = {
        feature: "",
        scenarios: [],
        meta: { tags: [], priority: "", estimate: nil, assignee: "" }
      }
      current_scenario = nil
      in_feature_block = false
      in_scenario_block = false
      blocks.each do |block|
        case block["type"]
        when "heading_1", "heading_2", "heading_3"
          heading_text = extract_text(block[block["type"]]["rich_text"])
          if heading_text.downcase.include?("feature")
            in_feature_block = true
            in_scenario_block = false
            parsed_data[:feature] = heading_text
          elsif heading_text.downcase.include?("scenario")
            in_scenario_block = true
            in_feature_block = false
            current_scenario = { title: heading_text, steps: [] }
            parsed_data[:scenarios] << current_scenario
          else
            in_feature_block = false
            in_scenario_block = false
          end
        when "paragraph"
          text = extract_text(block["paragraph"]["rich_text"])
          next if text.empty?

          if in_feature_block
            parsed_data[:feature] += "\n#{text}"
          elsif in_scenario_block && current_scenario
            current_scenario[:steps] << text
          end
        when "bulleted_list_item", "numbered_list_item"
          text = extract_text(block[block["type"]]["rich_text"])
          next if text.empty?

          if in_feature_block
            parsed_data[:feature] += "\n• #{text}"
          elsif in_scenario_block && current_scenario
            current_scenario[:steps] << text
          end
        when "callout"
          text = extract_text(block["callout"]["rich_text"])
          next if text.empty?

          if text.downcase.include?("tag")
            tags = extract_tags(text)
            parsed_data[:meta][:tags].concat(tags)
          elsif text.downcase.include?("priority")
            parsed_data[:meta][:priority] = extract_priority(text)
          elsif text.downcase.include?("estimate")
            parsed_data[:meta][:estimate] = extract_estimate(text)
          elsif text.downcase.include?("assignee")
            parsed_data[:meta][:assignee] = extract_assignee(text)
          end
        end
      end
      parsed_data[:feature] = parsed_data[:feature].strip
      parsed_data[:meta][:tags] = parsed_data[:meta][:tags].uniq
      parsed_data
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/BlockLength

    def extract_text(rich_text_array)
      return "" unless rich_text_array

      rich_text_array.map { |text| text["plain_text"] }.join(" ")
    end

    def extract_tags(text)
      if text =~ /tags?:\s*(.+)/i
        tags_text = ::Regexp.last_match(1).strip
        tags_text.split(/[,\s]+/).map(&:strip).reject(&:empty?)
      else
        []
      end
    end

    def extract_priority(text)
      if text =~ /priority:\s*(.+)/i
        ::Regexp.last_match(1).strip
      else
        ""
      end
    end

    def extract_estimate(text)
      return unless text =~ /estimate:\s*(\d+)/i

      ::Regexp.last_match(1).to_i
    end

    def extract_assignee(text)
      if text =~ /assignee:\s*(.+)/i
        ::Regexp.last_match(1).strip
      else
        ""
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
