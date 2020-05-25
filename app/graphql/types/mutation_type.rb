module Types
  class MutationType < Types::BaseObject
    field :update_company, mutation: Mutations::UpdateCompanyMutation
    field :update_user, mutation: Mutations::UpdateUserMutation
  end
end
