#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# Your credentials with correct email
email = "bouland.julien@gmail.com"
api_key = "ATATT3xFfGF0H5a0-ZcFh-ZVXAwe-r00b-FDkDsy1ZjxWJz4FVLgmwT_fN5qnQWsHHQKG5-cWwjkWRmMAaOYbpUjz2RYMwJSOVST8rIOWINY3GggDy73l-xd-_IrNXmEmxQg3nH2jnrWrcwFqzJKcbzOXrTvVWGEUv753J-OYvlLrWXA0yegYc4=0247F6BE"
domain = "https://boulandjulien.atlassian.net"

puts "🔍 Testing Jira with correct email: #{email}"

# Test 1: Check authentication
puts "\n1️⃣ Testing authentication..."
uri = URI("#{domain}/rest/api/3/myself")
request = Net::HTTP::Get.new(uri)
request.basic_auth(email, api_key)
request["Accept"] = "application/json"

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
response = http.request(request)

if response.code == "200"
  user_data = JSON.parse(response.body)
  puts "✅ Authentication successful!"
  puts "   User: #{user_data["displayName"]} (#{user_data["emailAddress"]})"
  puts "   Account ID: #{user_data["accountId"]}"
else
  puts "❌ Authentication failed: #{response.code}"
  puts "   Response: #{response.body}"
  exit 1
end

# Test 2: Get accessible projects
puts "\n2️⃣ Getting accessible projects..."
uri = URI("#{domain}/rest/api/3/project")
request = Net::HTTP::Get.new(uri)
request.basic_auth(email, api_key)
request["Accept"] = "application/json"

response = http.request(request)

if response.code == "200"
  projects = JSON.parse(response.body)
  puts "✅ Found #{projects.length} accessible projects:"
  projects.each do |project|
    puts "   - Key: #{project["key"]}, Name: #{project["name"]}, ID: #{project["id"]}"
  end
else
  puts "❌ Failed to get projects: #{response.code}"
  puts "   Response: #{response.body}"
end

# Test 3: Try to get project details for SCRUM
puts "\n3️⃣ Testing SCRUM project access..."
uri = URI("#{domain}/rest/api/3/project/SCRUM")
request = Net::HTTP::Get.new(uri)
request.basic_auth(email, api_key)
request["Accept"] = "application/json"

response = http.request(request)

if response.code == "200"
  project_data = JSON.parse(response.body)
  puts "✅ SCRUM project found!"
  puts "   Key: #{project_data["key"]}"
  puts "   Name: #{project_data["name"]}"
  puts "   ID: #{project_data["id"]}"
else
  puts "❌ SCRUM project not found: #{response.code}"
  puts "   Response: #{response.body}"
end

# Test 4: Try to get issues from any available project
if projects&.any?
  test_project = projects.first
  puts "\n4️⃣ Testing issues from #{test_project["key"]} project..."

  jql = "project = #{test_project["key"]} ORDER BY created DESC"
  uri = URI("#{domain}/rest/api/3/search?jql=#{URI.encode_www_form_component(jql)}&maxResults=5")
  request = Net::HTTP::Get.new(uri)
  request.basic_auth(email, api_key)
  request["Accept"] = "application/json"

  response = http.request(request)

  if response.code == "200"
    data = JSON.parse(response.body)
    issues = data["issues"] || []
    puts "✅ Found #{issues.length} issues in #{test_project["key"]}:"
    issues.each do |issue|
      status = issue.dig("fields", "status", "name") || "Unknown"
      puts "   - #{issue["key"]}: #{issue.dig("fields", "summary")} (Status: #{status})"
    end
  else
    puts "❌ Failed to get issues: #{response.code}"
    puts "   Response: #{response.body}"
  end
end

puts "\n🎉 Jira test completed!"
