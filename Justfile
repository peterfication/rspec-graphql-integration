# List available commands
default:
  just --list

# Run all checks from CI
ci: graphql-schema-dump spellcheck format rubocop test

# Run the spellchecker
spellcheck:
  cspell '**/*'

# Format files with Prettier
format:
  bundle exec rbprettier --write '**/*.{graphql,rb,json,yml,md}'

# Dump the GraphQL schema
graphql-schema-dump:
  rake graphql:schema:dump && bundle exec rbprettier --write '**/*.{graphql,rb,json,yml,md}'

# Lint the Ruby files with Rubocop
rubocop:
  bundle exec rubocop

# Lint and autofix the Ruby files with Rubocop
rubocop-fix:
  bundle exec rubocop -a

# Run the Ruby solargraph typechecker
typecheck:
  bundle exec solargraph typecheck

# Run the RSpec tests
test:
  bundle exec rspec
