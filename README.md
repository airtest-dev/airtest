# air_test

Automate the generation of Turnip/RSpec specs from Notion tickets, create branches, commits, pushes, and GitHub Pull Requests—all with a single Rake command.

## 🚀 Features

- Fetches Notion tickets (Gherkin format)
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

## ⚙️ Configuration

Create an initializer in your Rails project:  
`config/initializers/air_test.rb`

```ruby
AirTest.configure do |config|
  config.notion_token = ENV['NOTION_TOKEN']
  config.notion_database_id = ENV['NOTION_DATABASE_ID']
  config.github_token = ENV['GITHUB_BOT_TOKEN'] # or GITHUB_TOKEN
  config.repo = 'your-org/your-repo' # format: 'organization/repo_name'
end
```

Make sure your environment variables are set (in `.env`, your shell, or your CI/CD).

---

## 📝 Creating Notion Tickets with Gherkin Format

To ensure that your Notion tickets are compatible with the air_test automation, follow these guidelines when creating your tickets:

### 1. Create a New Page in Notion

- Start by creating a new page in your Notion workspace for each ticket.

### 2. Use the Gherkin Syntax

- Each ticket should follow the Gherkin syntax, which includes the following keywords:
  - **Feature**: A high-level description of the feature being implemented.
  - **Scenario**: A specific situation or case that describes how the feature should behave.
  - **Given**: The initial context or state before the scenario starts.
  - **When**: The action that triggers the scenario.
  - **Then**: The expected outcome or result of the action.

### 3. Example Structure

Here’s an example of how to structure a ticket in Notion:

Feature: User Login
Scenario: Successful login with valid credentials
Given the user is on the login page
When the user enters valid credentials
Then the user should be redirected to the dashboard
Scenario: Unsuccessful login with invalid credentials
Given the user is on the login page
When the user enters invalid credentials
Then an error message should be displayed

### 4. Additional Tips

- Ensure that each ticket is clearly titled and contains all necessary scenarios.
- Use bullet points or toggle lists in Notion to organize multiple scenarios under a single feature.
- Make sure to keep the Gherkin syntax consistent across all tickets for better parsing.

By following these guidelines, you can create Notion tickets that are ready to be parsed by the air_test automation tool.

---

## 🛠 Usage

Run the automated workflow from your Rails project terminal:

```sh
bundle exec rake air_test:generate_specs_from_notion
```

- This will:
  - Fetch Notion tickets
  - Generate Turnip/RSpec specs and step files
  - Create a branch, commit, push
  - Open a Pull Request on GitHub with a rich template

---

## 📋 Requirements

- A Notion API token with access to your database
- A GitHub token with push and PR creation rights
- A configured remote git repository (`git remote -v`)
- The folders `spec/features` and `spec/steps` (created automatically if needed)

---

## 📝 Example .env

```
NOTION_TOKEN=secret_xxx
NOTION_DATABASE_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
GITHUB_BOT_TOKEN=ghp_xxx
```

---

## 🆘 Troubleshooting

- **Notion or GitHub authentication error**: check your tokens.
- **PR not created**: make sure the branch contains commits different from `main`.
- **Permission issues**: ensure the GitHub bot has access to the repo.

---

## 👨‍💻 Author & License

- Author: [Airtest]
- License: MIT

---

**Need an integration example or install script?**  
Open an issue or contact me!

---
