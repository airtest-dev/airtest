# frozen_string_literal: true

require 'yaml'
require 'tty-prompt'
require 'fileutils'
require_relative '../air_test'

module AirTest
  class CLI
    def initialize
      @prompt = TTY::Prompt.new
      load_env_files
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

    def generate(args)
      puts "#{CYAN}🔍 Generating specs from tickets...#{RESET}\n"
      
      # Parse arguments
      options = parse_generate_options(args)
      
      # Load configuration
      config = load_configuration
      
      # Validate configuration
      validate_configuration(config)
      
      # Initialize AirTest configuration
      initialize_airtest_config(config)
      
      # Fetch tickets based on tool
      tickets = fetch_tickets(config, options)
      
      if tickets.empty?
        puts "#{YELLOW}⚠️  No tickets found matching your criteria.#{RESET}"
        return
      end
      
      # Handle interactive selection or search results
      selected_tickets = select_tickets(tickets, options)
      
      if selected_tickets.empty?
        puts "#{YELLOW}⚠️  No tickets selected.#{RESET}"
        return
      end
      
      # Process selected tickets
      process_tickets(selected_tickets, config, options)
    end

    def create_pr(args)
      puts "#{CYAN}🚀 Creating Pull Request...#{RESET}\n"
      # TODO: Implement create_pr functionality
      puts "#{YELLOW}⚠️  create-pr command not yet implemented.#{RESET}"
    end

    private

    def parse_generate_options(args)
      options = {
        interactive: false,
        search: nil,
        dry_run: false,
        no_pr: false
      }
      
      args.each_with_index do |arg, index|
        case arg
        when '--interactive'
          options[:interactive] = true
        when '--search'
          options[:search] = args[index + 1] if args[index + 1]
        when '--dry-run'
          options[:dry_run] = true
        when '--no-pr'
          options[:no_pr] = true
        end
      end
      
      options
    end

    def load_configuration
      unless File.exist?('.airtest.yml')
        puts "#{RED}❌ Configuration file .airtest.yml not found.#{RESET}"
        puts "Run 'air_test init' first to set up configuration."
        exit 1
      end
      
      YAML.load_file('.airtest.yml')
    end

    def validate_configuration(config)
      tool = config['tool']
      puts "#{GREEN}✅ Using #{tool.capitalize} as ticketing tool#{RESET}"
      
      # Check required environment variables
      missing_vars = []
      case tool
      when 'notion'
        %w[NOTION_TOKEN NOTION_DATABASE_ID].each do |var|
          missing_vars << var if ENV[var].nil? || ENV[var].empty?
        end
      when 'jira'
        %w[JIRA_TOKEN JIRA_PROJECT_ID JIRA_DOMAIN JIRA_EMAIL].each do |var|
          missing_vars << var if ENV[var].nil? || ENV[var].empty?
        end
      when 'monday'
        %w[MONDAY_TOKEN MONDAY_BOARD_ID MONDAY_DOMAIN].each do |var|
          missing_vars << var if ENV[var].nil? || ENV[var].empty?
        end
      end
      
      # Always check for GitHub token
      missing_vars << 'GITHUB_BOT_TOKEN' if ENV['GITHUB_BOT_TOKEN'].nil? || ENV['GITHUB_BOT_TOKEN'].empty?
      
      if missing_vars.any?
        puts "#{RED}❌ Missing required environment variables: #{missing_vars.join(', ')}#{RESET}"
        puts "Please set these variables in your .env file or environment."
        exit 1
      end
    end

    def initialize_airtest_config(config)
      # Initialize AirTest configuration with values from config file
      AirTest.configure do |airtest_config|
        case config['tool']
        when 'notion'
          airtest_config.notion[:token] = config['notion']['token']
          airtest_config.notion[:database_id] = config['notion']['database_id']
        when 'jira'
          airtest_config.jira[:token] = config['jira']['token']
          airtest_config.jira[:project_id] = config['jira']['project_id']
          airtest_config.jira[:domain] = config['jira']['domain']
          airtest_config.jira[:email] = config['jira']['email']
        when 'monday'
          airtest_config.monday[:token] = config['monday']['token']
          airtest_config.monday[:board_id] = config['monday']['board_id']
          airtest_config.monday[:domain] = config['monday']['domain']
        end
        
        airtest_config.github[:token] = config['github']['token']
        airtest_config.repo = config['github']['repo']
        airtest_config.tool = config['tool']
      end
    end

    def fetch_tickets(config, options)
      tool = config['tool']
      puts "#{CYAN}📋 Fetching tickets from #{tool.capitalize}...#{RESET}"
      
      # Use the existing Runner to fetch tickets
      runner = AirTest::Runner.new
      parser = runner.instance_variable_get(:@parser)
      
      # Fetch all tickets (we'll filter them later)
      all_tickets = parser.fetch_tickets(limit: 100)
      
      # Filter by search if specified
      if options[:search]
        all_tickets = all_tickets.select { |ticket| 
          title = parser.extract_ticket_title(ticket)
          title.downcase.include?(options[:search].downcase)
        }
      end
      
      # Filter by status (only "Ready" or "Not started" tickets)
      all_tickets.select { |ticket| 
        # This depends on the parser implementation
        # For now, we'll assume all tickets are ready
        true
      }
    end

    def select_tickets(tickets, options)
      if options[:interactive]
        select_tickets_interactive(tickets)
      else
        # In non-interactive mode, process all tickets
        tickets
      end
    end

    def select_tickets_interactive(tickets)
      puts "\n#{CYAN}Found #{tickets.length} ready tickets:#{RESET}"
      tickets.each_with_index do |ticket, index|
        parser = AirTest::Runner.new.instance_variable_get(:@parser)
        title = parser.extract_ticket_title(ticket)
        ticket_id = parser.extract_ticket_id(ticket)
        puts "[#{index + 1}] #{title} (ID: #{ticket_id})"
      end
      
      puts "\nEnter numbers (comma-separated) to select tickets, or 'all' for all tickets:"
      
      begin
        selection = @prompt.ask("Selection") do |q|
          q.default "all"
          q.required true
        end
        
        if selection.nil? || selection.strip.empty?
          puts "#{YELLOW}⚠️  No selection made, processing all tickets#{RESET}"
          return tickets
        end
        
        if selection.downcase.strip == "all"
          puts "#{GREEN}✅ Selected all #{tickets.length} tickets#{RESET}"
          return tickets
        end
        
        selected_indices = selection.split(',').map(&:strip).map(&:to_i)
        selected_tickets = selected_indices.map { |i| tickets[i - 1] }.compact
        
        if selected_tickets.empty?
          puts "#{YELLOW}⚠️  Invalid selection, processing all tickets#{RESET}"
          return tickets
        end
        
        puts "#{GREEN}✅ Selected #{selected_tickets.length} tickets#{RESET}"
        selected_tickets
        
      rescue => e
        puts "#{YELLOW}⚠️  Error with interactive selection: #{e.message}#{RESET}"
        puts "#{YELLOW}⚠️  Processing all tickets instead#{RESET}"
        return tickets
      end
    end

    def process_tickets(tickets, config, options)
      puts "\n#{CYAN}🔄 Processing #{tickets.length} tickets...#{RESET}"
      
      # Initialize the runner
      runner = AirTest::Runner.new
      parser = runner.instance_variable_get(:@parser)
      
      tickets.each do |ticket|
        ticket_id = parser.extract_ticket_id(ticket)
        title = parser.extract_ticket_title(ticket)
        url = parser.extract_ticket_url(ticket)
        
        puts "\n#{YELLOW}📝 Processing: #{title} (ID: #{ticket_id})#{RESET}"
        
        if options[:dry_run]
          preview_ticket_processing(ticket, config, parser)
        else
          process_single_ticket(ticket, config, options, runner, parser)
        end
      end
      
      puts "\n#{GREEN}✅ Processing complete!#{RESET}"
    end

    def preview_ticket_processing(ticket, config, parser)
      ticket_id = parser.extract_ticket_id(ticket)
      title = parser.extract_ticket_title(ticket)
      url = parser.extract_ticket_url(ticket)
      
      puts "  📋 Ticket ID: #{ticket_id}"
      puts "  📝 Title: #{title}"
      puts "  🔗 URL: #{url}"
      puts "  🔧 Tool: #{config['tool'].capitalize}"
      puts "  👤 Dev Assignee: #{config['dev_assignee']}"
      puts "  🌿 Branch: air_test/#{ticket_id}-#{title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')}"
      puts "  📄 Files to create:"
      puts "    - spec/features/[feature_slug]_fdr#{ticket_id}.rb"
      puts "    - spec/steps/[feature_slug]_fdr#{ticket_id}_steps.rb"
      puts "  🔗 PR Title: #{title}"
    end

    def process_single_ticket(ticket, config, options, runner, parser)
      ticket_id = parser.extract_ticket_id(ticket)
      title = parser.extract_ticket_title(ticket)
      url = parser.extract_ticket_url(ticket)
      
      # Parse ticket content
      parsed_data = parser.parse_ticket_content(ticket["id"])
      
      unless parsed_data && parsed_data[:feature] && !parsed_data[:feature].empty?
        puts "  ⚠️  Skipping ticket #{ticket_id} due to missing or empty feature."
        return
      end
      
      # Generate spec files
      spec_generator = runner.instance_variable_get(:@spec)
      spec_path = spec_generator.generate_spec_from_parsed_data(ticket_id, parsed_data)
      step_path = spec_generator.generate_step_definitions_for_spec(spec_path)
      
      puts "  ✅ Generated spec files for #{title}"
      
      # Handle Git operations and PR creation
      unless options[:no_pr]
        files_to_commit = [spec_path]
        files_to_commit << step_path if step_path
        
        github_client = runner.instance_variable_get(:@github)
        branch = "air_test/#{ticket_id}-#{title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')}"
        
        has_changes = github_client.commit_and_push_branch(branch, files_to_commit, "Add specs for #{config['tool'].capitalize} ticket #{ticket_id}")
        
        if has_changes
          # Create PR
          scenarios_md = parsed_data[:scenarios].map.with_index(1) do |sc, _i|
            steps = sc[:steps]&.map { |step| "      - #{step}" }&.join("\n")
            "  - [ ] #{sc[:title]}\n#{steps}"
          end.join("\n")
          
          pr_body = <<~MD
            - **Story #{config['tool'].capitalize} :** #{url}
            - **Feature** : #{parsed_data[:feature]}
            - **Scénarios** :
          #{scenarios_md}
            - **Want to help us improve airtest?**
            Leave feedback [here](http://bit.ly/4o5rinU)
            or [join the community](https://discord.gg/ggnBvhtw7E)
          MD
          
          pr = github_client.create_pull_request(branch, title, pr_body)
          if pr
            puts "  🔗 Created PR: #{pr.html_url}"
          else
            puts "  ⚠️  Failed to create PR"
          end
        else
          puts "  ⚠️  No changes detected, PR not created."
        end
      else
        puts "  ⚠️  PR creation disabled (--no-pr flag)"
      end
    end

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
          'token' => ENV['NOTION_TOKEN'] || 'your_notion_token',
          'database_id' => ENV['NOTION_DATABASE_ID'] || 'your_notion_database_id'
        },
        'jira' => {
          'token' => ENV['JIRA_TOKEN'] || 'your_jira_token',
          'project_id' => ENV['JIRA_PROJECT_ID'] || 'your_jira_project_id',
          'domain' => ENV['JIRA_DOMAIN'] || 'your_jira_domain',
          'email' => ENV['JIRA_EMAIL'] || 'your_jira_email'
        },
        'monday' => {
          'token' => ENV['MONDAY_TOKEN'] || 'your_monday_token',
          'board_id' => ENV['MONDAY_BOARD_ID'] || 'your_monday_board_id',
          'domain' => ENV['MONDAY_DOMAIN'] || 'your_monday_domain'
        },
        'github' => {
          'token' => ENV['GITHUB_BOT_TOKEN'] || 'your_github_token',
          'repo' => ENV['REPO'] || 'your-org/your-repo'
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

    private

    def load_env_files
      # Try to load .env files in order of preference
      env_files = ['.env.airtest', '.env']
      
      env_files.each do |env_file|
        if File.exist?(env_file)
          load_env_file(env_file)
          puts "#{GREEN}✅ Loaded environment variables from #{env_file}#{RESET}" if ENV['AIRTEST_DEBUG']
          break
        end
      end
    end

    def load_env_file(file_path)
      File.readlines(file_path).each do |line|
        line.strip!
        next if line.empty? || line.start_with?('#')
        
        if line.include?('=')
          key, value = line.split('=', 2)
          ENV[key.strip] = value.strip.gsub(/^["']|["']$/, '') # Remove quotes
        end
      end
    rescue => e
      puts "#{YELLOW}⚠️  Warning: Could not load #{file_path}: #{e.message}#{RESET}" if ENV['AIRTEST_DEBUG']
    end

    # Color constants
    GREEN = "\e[32m"
    YELLOW = "\e[33m"
    RED = "\e[31m"
    CYAN = "\e[36m"
    RESET = "\e[0m"
  end
end 