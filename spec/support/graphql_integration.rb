require_relative "../../lib/rspec/graphql_integration"
require_relative "../example_schema/test_schema"
require_relative "../example_schema/test_schema_b"

RSpec.configure do |config|
  config.graphql_schema_class = TestSchema
  config.infer_graphql_spec_type_from_file_location!
end
