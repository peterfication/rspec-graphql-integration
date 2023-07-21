require "graphql"

require_relative "objects/user"

module Types
  class QueryB < GraphQL::Schema::Object
    field(:other_user, Types::Objects::User, null: false)
    def other_user
      { id: 1, name: "John Doe" }
    end
  end
end
