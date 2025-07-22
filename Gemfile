source "https://rubygems.org"

gemspec

gem "rake"
gem "rspec"

platforms :mri do
  gem "byebug"
  gem "irb"
  gem "prettier"
  gem "pry"
  gem "pry-byebug"
  gem "reline"
  gem "rubocop"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "simplecov"
  gem "solargraph"
end

platforms :jruby do
  # Needed for JRuby, see https://github.com/jruby/jruby/issues/6581
  gem "racc"
end
