require "graphql"

require_relative "objects/user"

##
# This class is for simulating a database
class User
  def self.first
    nil
  end
end

module Types
  class Query < GraphQL::Schema::Object
    field(:current_user, Types::Objects::User, null: false) do
      argument(:user_name, String, required: false)
    end
    def current_user(**args)
      return User.first unless User.first.nil?

      {
        id: 1,
        name: "John Doe",
        name_from_variables: args[:user_name],
        name_from_context: context[:user_name],
        roles: %w[],
      }
    end
  end
end
