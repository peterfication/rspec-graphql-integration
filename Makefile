spellcheck:
	cspell '**/*'

format:
	bundle exec rbprettier --write '**/*.{rb,json,yml,md}'

rubocop:
	bundle exec rubocop

rubocop-fix:
	bundle exec rubocop -a

typecheck:
	bundle exec solargraph typecheck

test:
	bundle exec rspec

ci: spellcheck format rubocop test
