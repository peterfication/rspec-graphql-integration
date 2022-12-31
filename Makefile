format:
	rbprettier --write '**/*.{rb,json,yml,md}'

rubocop:
	rubocop

rubocop-fix:
	rubocop -a

check: format rubocop
