require "graphql"

require_relative "./objects/user"

module Types
  class Query < GraphQL::Schema::Object
    field(:current_user, Types::Objects::User, null: false)
    def current_user
      { id: 1, name: "John Doe" }
    end
  end
end
