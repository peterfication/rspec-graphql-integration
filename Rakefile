require "graphql/rake_task"
require "rake"

GraphQL::RakeTask.new(
  idl_outfile: "graphql/test-schema.graphql",
  json_outfile: "graphql/test-schema.json",
  load_schema: lambda { |_task|
    require_relative "spec/example_schema/test_schema"
    TestSchema
  },
)
GraphQL::RakeTask.new(
  idl_outfile: "graphql/test-schema-b.graphql",
  json_outfile: "graphql/test-schema-b.json",
  load_schema: lambda { |_task|
    require_relative "spec/example_schema/test_schema_b"
    TestSchemaB
  },
)

namespace :graphql do
  namespace :schema do
    desc "Dump the test GraphQL schema to a file"
    task :dump do
      Rake::Task["graphql:schema:dump"].invoke
    end
  end
end
