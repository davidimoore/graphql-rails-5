module Types
  class CompanyType < Types::BaseObject
    field :id, ID, null: false
    field :motto, String, null: true
    field :name, String, null: true
    field :postal_code, Integer, null: true
    field :users, [Types::UserType], null: true
    field :user_count, Integer, null: false

    def user_count
      CountLoader.for(model: Company, association_name: :users).load(object.id)
    end

    def users
      ::AssociationLoader.
        for(model: Company, association_name: :users).
        load(object)
    end

    def motto
      "#{object.name} does it best"
    end
  end
end
