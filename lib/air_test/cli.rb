# frozen_string_literal: true

require 'yaml'
require 'tty-prompt'
require 'fileutils'

module AirTest
  class CLI
    def initialize
      @prompt = TTY::Prompt.new
    end

    def init(silent: false)
      puts "#{CYAN}🚀 Initializing AirTest for your Rails project...#{RESET}\n"

      if silent
        # Set default values for silent mode
        config = {
          tool: 'notion',
          auto_pr: 'no',
          dev_assignee: 'default_assignee',
          interactive_mode: 'no'
        }
      else
        # Interactive prompts
        config = prompt_for_configuration
      end

      # Create configuration files
      create_airtest_yml(config)
      create_initializer_file
      create_env_example_file(config[:tool])
      create_directories

      # Check environment variables
      check_environment_variables(config[:tool])

      puts "\n✨ All set! Next steps:"
      puts "  1. Fill in your config/initializers/air_test.rb"
      puts "  2. Add your tokens to .env or your environment"
      puts "  3. Run: bundle exec rake air_test:generate_specs_from_notion"
      puts "\nHappy testing! 🎉"
    end

    private

    def prompt_for_configuration
      tool = @prompt.select("Which ticketing tool do you use?", %w[notion jira monday], default: 'notion')
      auto_pr = @prompt.select("Enable auto PR creation by default?", %w[yes no], default: 'no')
      dev_assignee = @prompt.ask("Default dev assignee name?", default: 'default_assignee')
      interactive_mode = @prompt.select("Enable interactive mode by default?", %w[yes no], default: 'no')
      
      {
        tool: tool,
        auto_pr: auto_pr,
        dev_assignee: dev_assignee,
        interactive_mode: interactive_mode
      }
    end

    def create_airtest_yml(config)
      airtest_yml_path = '.airtest.yml'
      
      if File.exist?(airtest_yml_path)
        puts "#{YELLOW}⚠️  #{airtest_yml_path} already exists. Skipping.#{RESET}"
        return
      end

      yaml_content = {
        'tool' => config[:tool],
        'auto_pr' => config[:auto_pr],
        'dev_assignee' => config[:dev_assignee],
        'interactive_mode' => config[:interactive_mode],
        'notion' => {
          'token' => 'ENV["NOTION_TOKEN"]',
          'database_id' => 'ENV["NOTION_DATABASE_ID"]'
        },
        'jira' => {
          'token' => 'ENV["JIRA_TOKEN"]',
          'project_id' => 'ENV["JIRA_PROJECT_ID"]',
          'domain' => 'ENV["JIRA_DOMAIN"]',
          'email' => 'ENV["JIRA_EMAIL"]'
        },
        'monday' => {
          'token' => 'ENV["MONDAY_TOKEN"]',
          'board_id' => 'ENV["MONDAY_BOARD_ID"]',
          'domain' => 'ENV["MONDAY_DOMAIN"]'
        },
        'github' => {
          'token' => 'ENV["GITHUB_BOT_TOKEN"]',
          'repo' => 'your-org/your-repo'
        }
      }

      File.write(airtest_yml_path, yaml_content.to_yaml)
      puts "#{GREEN}✅ Created #{airtest_yml_path}#{RESET}"
    end

    def create_initializer_file
      initializer_path = "config/initializers/air_test.rb"
      
      if File.exist?(initializer_path)
        puts "#{YELLOW}⚠️  #{initializer_path} already exists. Skipping.#{RESET}"
        return
      end

      FileUtils.mkdir_p(File.dirname(initializer_path))
      File.write(initializer_path, <<~RUBY)
        AirTest.configure do |config|
          config.notion_token = ENV['NOTION_TOKEN']
          config.notion_database_id = ENV['NOTION_DATABASE_ID']
          config.github_token = ENV['GITHUB_BOT_TOKEN']
          config.repo = 'your-org/your-repo' # format: 'organization/repo_name'
        end
      RUBY
      puts "#{GREEN}✅ Created #{initializer_path}#{RESET}"
    end

    def create_env_example_file(tool)
      example_env = ".env.air_test.example"
      
      if File.exist?(example_env)
        puts "#{YELLOW}⚠️  #{example_env} already exists. Skipping.#{RESET}"
        return
      end

      env_content = case tool
      when 'notion'
        <<~ENV
          NOTION_TOKEN=your_notion_token
          NOTION_DATABASE_ID=your_notion_database_id
          GITHUB_BOT_TOKEN=your_github_token
        ENV
      when 'jira'
        <<~ENV
          JIRA_TOKEN=your_jira_token
          JIRA_PROJECT_ID=your_jira_project_id
          JIRA_DOMAIN=your_jira_domain
          JIRA_EMAIL=your_jira_email
          GITHUB_BOT_TOKEN=your_github_token
        ENV
      when 'monday'
        <<~ENV
          MONDAY_TOKEN=your_monday_token
          MONDAY_BOARD_ID=your_monday_board_id
          MONDAY_DOMAIN=your_monday_domain
          GITHUB_BOT_TOKEN=your_github_token
        ENV
      end

      File.write(example_env, env_content)
      puts "#{GREEN}✅ Created #{example_env}#{RESET}"
    end

    def create_directories
      ["spec/features", "spec/steps"].each do |dir|
        if Dir.exist?(dir)
          puts "#{YELLOW}⚠️  #{dir} already exists. Skipping.#{RESET}"
        else
          FileUtils.mkdir_p(dir)
          puts "#{GREEN}✅ Created #{dir}/#{RESET}"
        end
      end
    end

    def check_environment_variables(tool)
      puts "\n🔎 Checking environment variables..."
      missing = []
      
      case tool
      when 'notion'
        %w[NOTION_TOKEN NOTION_DATABASE_ID GITHUB_BOT_TOKEN].each do |var|
          if ENV[var].nil? || ENV[var].empty?
            puts "#{YELLOW}⚠️  #{var} is not set!#{RESET}"
            missing << var
          else
            puts "#{GREEN}✅ #{var} is set#{RESET}"
          end
        end
      when 'jira'
        %w[JIRA_TOKEN JIRA_PROJECT_ID JIRA_DOMAIN JIRA_EMAIL GITHUB_BOT_TOKEN].each do |var|
          if ENV[var].nil? || ENV[var].empty?
            puts "#{YELLOW}⚠️  #{var} is not set!#{RESET}"
            missing << var
          else
            puts "#{GREEN}✅ #{var} is set#{RESET}"
          end
        end
      when 'monday'
        %w[MONDAY_TOKEN MONDAY_BOARD_ID MONDAY_DOMAIN GITHUB_BOT_TOKEN].each do |var|
          if ENV[var].nil? || ENV[var].empty?
            puts "#{YELLOW}⚠️  #{var} is not set!#{RESET}"
            missing << var
          else
            puts "#{GREEN}✅ #{var} is set#{RESET}"
          end
        end
      end
    end

    # Color constants
    GREEN = "\e[32m"
    YELLOW = "\e[33m"
    RED = "\e[31m"
    CYAN = "\e[36m"
    RESET = "\e[0m"
  end
end 