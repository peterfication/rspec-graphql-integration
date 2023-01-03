module Types
  module Objects
    class User < GraphQL::Schema::Object
      field :id, ID, null: false
      field :name, String, null: false
      field :name_from_variables, String, null: true
    end
  end
end
