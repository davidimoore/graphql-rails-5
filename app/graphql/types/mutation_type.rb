module Types
  class MutationType < Types::BaseObject
    field :update_company, mutation: Mutations::UpdateCompanyMutation
    field :create_user, mutation: Mutations::CreateUser
    field :update_user, mutation: Mutations::UpdateUserMutation
  end
end
