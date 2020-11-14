# frozen_string_literal: true
# https://github.com/howtographql/graphql-ruby/blob/master/app/graphql/types/auth_provider_credentials_input.rb

module Types
  class AuthProviderCredentialsInput < BaseInputObject
    graphql_name 'AUTH_PROVIDER_CREDENTIALS'

    argument :email, String, required: true
    argument :password, String, required: true
  end
end