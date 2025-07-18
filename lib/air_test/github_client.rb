# frozen_string_literal: true
require 'octokit'

module AirTest
  class GithubClient
    def initialize(config = AirTest.configuration)
      @github_token = config.github_token
      @repo = config.repo || detect_repo_from_git
      @client = Octokit::Client.new(access_token: @github_token) if @github_token
    end

    def commit_and_push_branch(branch, files, commit_message)
      if branch_exists?(branch)
        system("git checkout #{branch}")
      else
        system("git checkout -b #{branch}")
      end
      files.each { |f| system("git add -f #{f}") }
      has_changes = !system("git diff --cached --quiet")
      if has_changes
        system("git commit -m '#{commit_message}'")
      end
      system("git push origin #{branch}")
      has_changes
    end

    def create_pull_request(branch, pr_title, pr_body, assignees: ['Notion'])
      return unless @client && @repo
      @client.create_pull_request(
        @repo,
        'main',
        branch,
        pr_title,
        pr_body,
        { assignees: assignees }
      )
    rescue Octokit::UnprocessableEntity => e
      warn "❌ Erreur lors de la création de la PR : #{e.message}"
      nil
    end

    private

    def branch_exists?(branch)
      system("git show-ref --verify --quiet refs/heads/#{branch}")
    end

    def detect_repo_from_git
      remote_url = `git config --get remote.origin.url`.strip
      remote_url.split(/[:\/]/).last(2).join('/').gsub(/\.git$/, '')
    end
  end
end 