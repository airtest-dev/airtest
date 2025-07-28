# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require_relative "ticket_parser"

module AirTest
  class JiraTicketParser
    include TicketParser
    def initialize(config = AirTest.configuration)
      @domain = config.jira[:domain]
      @api_key = config.jira[:token]
      @project_key = config.jira[:project_id]
      @email = config.jira[:email]
    end

    def fetch_tickets(limit: 5)
      # Try different status names (English and French)
      statuses = ["To Do", "À faire", "Open", "New"]
      all_issues = []

      statuses.each do |status|
        jql = "project = #{@project_key} AND status = '#{status}' ORDER BY created DESC"
        uri = URI("#{@domain}/rest/api/3/search?jql=#{URI.encode_www_form_component(jql)}&maxResults=#{limit}")
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(@email, @api_key)
        request["Accept"] = "application/json"
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)

        next unless response.code == "200"

        data = JSON.parse(response.body)
        issues = data["issues"] || []
        all_issues.concat(issues)
        puts "Found #{issues.length} issues with status '#{status}'" if issues.any?
      end

      all_issues.first(limit)
    end

    def parse_ticket_content(issue_id)
      # Fetch issue details (description, etc.)
      uri = URI("#{@domain}/rest/api/3/issue/#{issue_id}")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@email, @api_key)
      request["Accept"] = "application/json"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(request)
      return nil unless response.code == "200"

      issue = JSON.parse(response.body)
      # Example: parse description as feature, steps, etc. (customize as needed)
      {
        feature: issue.dig("fields", "summary") || "",
        scenarios: [
          {
            title: "Scenario",
            steps: [issue.dig("fields", "description", "content")&.map do |c|
              c["content"]&.map do |t|
                t["text"]
              end&.join(" ")
            end&.join(" ") || ""]
          }
        ],
        meta: { tags: [], priority: "", estimate: nil,
                assignee: issue.dig("fields", "assignee", "displayName") || "" }
      }
    end

    def extract_ticket_title(ticket)
      ticket.dig("fields", "summary") || "No title"
    end

    def extract_ticket_id(ticket)
      ticket["key"] || "No ID"
    end

    def extract_ticket_url(ticket)
      "#{@domain}/browse/#{ticket["key"]}"
    end
  end
end
