# air_test

Automate the generation of Turnip/RSpec specs from Notion tickets, create branches, commits, pushes, and GitHub Pull Requests—all with a single command.

## 🚀 Features

- **Multi-platform support**: Works with Notion, Jira, and Monday.com
- **Interactive CLI**: Choose which tickets to process
- **Search and filtering**: Find tickets by keyword
- **Dry-run mode**: Preview changes before applying them
- **Flexible PR creation**: Generate specs with or without automatic PRs
- Fetches tickets (Gherkin format)
- Parses and extracts features/scenarios
- Generates Turnip/RSpec spec files and matching step definitions
- Creates a dedicated branch, commits, pushes
- Opens a Pull Request on GitHub with a rich, pre-filled template

---

## ⚡️ Installation

Add the gem to your `Gemfile`:

```ruby
gem 'air_test', path: '../path/to/air_test'
```
or, if you publish it on a git repo:
```ruby
gem 'air_test', git: 'https://github.com/your-org/air_test.git'
```

Then install dependencies:
```sh
bundle install
```

---

## 🛠 Quick Start

### 1. Initialize Configuration

Set up your project configuration interactively:

```sh
air_test init
```

This will:
- Ask which ticketing tool you use (Notion, Jira, or Monday)
- Configure your preferences (auto PR creation, dev assignee, etc.)
- Create `.airtest.yml` configuration file
- Create example environment file
- Set up necessary directories

For silent setup with defaults:
```sh
air_test init --silent
```

### 2. Set Environment Variables

Copy the example environment file and fill in your tokens:

```sh
cp .env.air_test.example .env
# Edit .env with your actual tokens
```

### 3. Generate Specs

#### Interactive Mode (Recommended)
```sh
air_test generate --interactive
```
Shows you a list of available tickets and lets you choose which ones to process.

#### Search and Filter
```sh
air_test generate --search "webhook"
```
Only processes tickets containing "webhook" in the title or content.

#### Preview Mode
```sh
air_test generate --dry-run
```
Shows what would be generated without creating files or PRs.

#### Disable PR Creation
```sh
air_test generate --no-pr
```
Generates spec files locally without creating Pull Requests.

---

## ⚙️ Configuration

### CLI Configuration (`.airtest.yml`)

The `air_test init` command creates a `.airtest.yml` file with your preferences:

```yaml
tool: notion                    # Your ticketing tool (notion/jira/monday)
auto_pr: 'yes'                  # Enable auto PR creation
dev_assignee: 'your-name'       # Default dev assignee
interactive_mode: 'yes'         # Enable interactive mode by default
status_filter: 'Not started'    # Status filter for tickets to fetch
notion:
  token: ENV["NOTION_TOKEN"]
  database_id: ENV["NOTION_DATABASE_ID"]
jira:
  token: ENV["JIRA_TOKEN"]
  project_id: ENV["JIRA_PROJECT_ID"]
  domain: ENV["JIRA_DOMAIN"]
  email: ENV["JIRA_EMAIL"]
monday:
  token: ENV["MONDAY_TOKEN"]
  board_id: ENV["MONDAY_BOARD_ID"]
  domain: ENV["MONDAY_DOMAIN"]
github:
  token: ENV["GITHUB_BOT_TOKEN"]
  repo: 'your-org/your-repo'
```

### Status Filtering

AirTest can filter tickets by their status to only process tickets in specific states:

- **Notion**: Filter by status like "Not started", "In progress", "Done", "attente de confirmation", etc.
- **Jira**: Filter by status like "To Do", "In Progress", "Done", etc.
- **Monday.com**: Filter by status like "Working on it", "Done", "Stuck", etc.

You can configure the status filter in three ways:

1. **During setup**: When running `air_test init`, you'll be prompted for the default status filter
2. **Environment variable**: Set `AIRTEST_STATUS_FILTER=your_status` in your `.env` file
3. **Configuration file**: Edit the `status_filter` field in `.airtest.yml`

### Rails Initializer (Optional)

For Rails projects, you can also create an initializer:  
`config/initializers/air_test.rb`

```ruby
AirTest.configure do |config|
  config.notion_token = ENV['NOTION_TOKEN']
  config.notion_database_id = ENV['NOTION_DATABASE_ID']
  config.github_token = ENV['GITHUB_BOT_TOKEN'] # or GITHUB_TOKEN
  config.repo = 'your-org/your-repo' # format: 'organization/repo_name'
end
```

---

## 📝 Creating Tickets with Gherkin Format

To ensure that your tickets are compatible with the air_test automation, follow these guidelines when creating your tickets:

### 1. Create a New Page/Ticket

- Start by creating a new page in your Notion workspace, Jira issue, or Monday.com item for each ticket.

### 2. Use the Gherkin Syntax

- Each ticket should follow the Gherkin syntax, which includes the following keywords:
  - **Feature**: A high-level description of the feature being implemented.
  - **Scenario**: A specific situation or case that describes how the feature should behave.
  - **Given**: The initial context or state before the scenario starts.
  - **When**: The action that triggers the scenario.
  - **Then**: The expected outcome or result of the action.

### 3. Example Structure

Here's an example of how to structure a ticket:

```
Feature: User Login
Scenario: Successful login with valid credentials
Given the user is on the login page
When the user enters valid credentials
Then the user should be redirected to the dashboard

Scenario: Unsuccessful login with invalid credentials
Given the user is on the login page
When the user enters invalid credentials
Then an error message should be displayed
```

### 4. Additional Tips

- Ensure that each ticket is clearly titled and contains all necessary scenarios.
- Use bullet points or toggle lists to organize multiple scenarios under a single feature.
- Make sure to keep the Gherkin syntax consistent across all tickets for better parsing.

---

## 🛠 CLI Commands

### `air_test init [--silent]`
Initialize AirTest configuration for your project.

**Options:**
- `--silent`: Use default values without prompts

**Examples:**
```sh
air_test init                    # Interactive setup
air_test init --silent          # Silent setup with defaults
```

### `air_test generate [options]`
Generate specs from tickets with advanced filtering and selection.

**Options:**
- `--interactive`: Interactive ticket selection
- `--search "keyword"`: Search tickets by keyword
- `--dry-run`: Preview changes without creating files
- `--no-pr`: Disable PR creation

**Examples:**
```sh
air_test generate                    # Process all ready tickets
air_test generate --interactive     # Choose tickets interactively
air_test generate --search "webhook" --dry-run
air_test generate --no-pr           # Generate files only, no PRs
```

### `air_test create-pr --ticket-id ID`
Create a Pull Request for a specific ticket (coming soon).

**Examples:**
```sh
air_test create-pr --ticket-id 123
```

### `air_test help`
Show help information and usage examples.

---

## 📋 Requirements

### Environment Variables

#### For Notion:
```
NOTION_TOKEN=secret_xxx
NOTION_DATABASE_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
GITHUB_BOT_TOKEN=ghp_xxx
AIRTEST_STATUS_FILTER=Not started  # Optional: Override status filter
```

#### For Jira:
```
JIRA_TOKEN=your_jira_token
JIRA_PROJECT_ID=your_project_id
JIRA_DOMAIN=your_domain.atlassian.net
JIRA_EMAIL=your_email@example.com
GITHUB_BOT_TOKEN=ghp_xxx
AIRTEST_STATUS_FILTER=To Do  # Optional: Override status filter
```

#### For Monday.com:
```
MONDAY_TOKEN=your_monday_token
MONDAY_BOARD_ID=your_board_id
MONDAY_DOMAIN=your_domain.monday.com
GITHUB_BOT_TOKEN=ghp_xxx
AIRTEST_STATUS_FILTER=Working on it  # Optional: Override status filter
```

### System Requirements

- A ticketing tool API token with access to your tickets
- A GitHub token with push and PR creation rights
- A configured remote git repository (`git remote -v`)
- The folders `spec/features` and `spec/steps` (created automatically if needed)

---

## 🆘 Troubleshooting

- **Configuration not found**: Run `air_test init` to set up configuration
- **Authentication error**: Check your API tokens in environment variables
- **No tickets found**: Verify your ticketing tool configuration and permissions, or check if your status filter matches existing ticket statuses
- **PR not created**: Make sure the branch contains commits different from `main`
- **Permission issues**: Ensure the GitHub bot has access to the repo

---

## 👨‍💻 Author & License

- Author: [Airtest]
- License: MIT

---

**Need an integration example or install script?**  
Open an issue or contact me!
