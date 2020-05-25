# frozen_string_literal: true

module Mutations
  class UpdateUserMutation < BaseMutation
    graphql_name "UpdateUser"

    null false

    argument :new_email, String, required: true
    argument :old_email, String, required: true

    field :success, Boolean, null: false

    def ready?(**_args)
      true
    end

    def resolve(old_email:, new_email:)
      user =  User.find_by!(email: old_email)

      return { success: false }  if user.nil?

      user.update(email: new_email)

      { success: user.errors.any? }
    end
  end
end
