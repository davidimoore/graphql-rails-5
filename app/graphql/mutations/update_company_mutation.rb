# frozen_string_literal: true

module Mutations
  class UpdateCompanyMutation < BaseMutation
    graphql_name "UpdateCompany"

    null false

    argument :attributes, Types::CompanyAttributesInputType, required: true

    field :success, Boolean, null: false

    def ready?(**_args)
      # validate here to continue the mutation
      # example current_company
      true
    end

    def resolve(attributes:)
      company.then do |c|
        return { success: false } if c.nil?

        c.update(attributes.arguments.keyword_arguments)

        { success: !c.errors.any? }
      end
    end

    def company
      RecordLoader.for(Company).load(@context[:current_company].id)
    end
  end
end
