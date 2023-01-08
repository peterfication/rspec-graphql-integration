lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/graphql_integration/version"

Gem::Specification.new do |spec|
  spec.name                  = "rspec-graphql-integration"
  spec.version               = RSpec::GraphqlIntegration::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.authors               = ["Peter Gundel"]
  spec.email                 = ["gundel.peter@gmail.com"]
  spec.summary               = "An RSpec plugin to simplify integration tests for GraphQL"
  spec.homepage              = "https://github.com/peterfication/rspec-graphql-integration"
  spec.license               = "MIT"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
  }

  spec.files                 = `git ls-files -- lib/*`.split("\n")
  spec.require_paths         = ["lib"]

  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "graphql", ">= 1.0.0"
  spec.add_dependency "rspec-core", ">= 3.0.0"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "prettier"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "solargraph"
end
