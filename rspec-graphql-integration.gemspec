lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/graphql_integration/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-graphql-integration'
  spec.version       = RSpec::GraphqlIntegration::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Peter Gundel']
  spec.email         = ['gundel.peter@gmail.com']
  spec.summary       = 'An RSpec plugin to simplify integration tests for GraphQL'
  spec.homepage      = 'https://github.com/peterfication/rspec-graphql-integration'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'graphql', '>= 1.0.0'
  spec.add_dependency 'rspec', '>= 3.0.0'
end
