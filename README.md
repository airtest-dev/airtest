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

## 🧩 Gem Structure

- `lib/air_test/configuration.rb`: centralized configuration
- `lib/air_test/notion_parser.rb`: Notion extraction and parsing
- `lib/air_test/spec_generator.rb`: spec and step file generation
- `lib/air_test/github_client.rb`: git and GitHub PR management
- `lib/air_test/runner.rb`: workflow orchestrator
- `lib/tasks/air_test.rake`: Rake task to launch the automation

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

## 📦 Publishing the Gem (optional)

To publish the gem on RubyGems:

```sh
gem build air_test.gemspec
gem push air_test-x.y.z.gem
```

---

## 👨‍💻 Author & License

- Author: [Airtest]
- License: MIT

---

**Need an integration example or install script?**  
Open an issue or contact me!

---
