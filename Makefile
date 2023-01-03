format:
	rbprettier --write '**/*.{rb,json,yml,md}'

rubocop:
	rubocop

rubocop-fix:
	rubocop -a

test:
	bundle exec rspec

ci: format rubocop test
