require_relative "types/query_b"

class TestSchemaB < GraphQL::Schema
  query Types::QueryB
end
