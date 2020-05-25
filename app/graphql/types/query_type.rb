module Types
  class QueryType < Types::BaseObject
    field :companies, [CompanyType], null: false, description: "A collection of companies"
    field :company, CompanyType, null: true, description: "A company" do
      argument :id, ID, required: true
    end

    def company(id:)
      RecordLoader.for(Company).load(id)
    end

    def companies
      Company.all
    end
  end
end
