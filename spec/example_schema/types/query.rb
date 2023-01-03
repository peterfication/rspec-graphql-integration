require "graphql"

require_relative "./objects/user"

module Types
  class Query < GraphQL::Schema::Object
    field(:current_user, Types::Objects::User, null: false) do
      argument(:user_name, String, required: false)
    end
    def current_user(**args)
      { id: 1, name: "John Doe", name_from_variables: args[:user_name] }
    end
  end
end
