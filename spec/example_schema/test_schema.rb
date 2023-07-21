require_relative "types/query"

class TestSchema < GraphQL::Schema
  query Types::Query
end
