module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: true
  end
end
