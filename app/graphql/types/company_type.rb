module Types
  class CompanyType < Types::BaseObject
    field :id, ID, null: false
    field :motto, String, null: true
    field :name, String, null: true
    field :postal_code, Integer, null: true
    field :users, Types::UserConnectionType, max_page_size: 2, null: true

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
