# frozen_string_literal: true

describe "UpdateCompany mutation" do
  let(:query) do
    <<~GRAPHQL
      mutation UpdateCompany($input: UpdateCompanyInput!) {
        updateCompany(input: $input) {
          success
        }
      }
    GRAPHQL
  end

  let(:old_name) {"old name"}
  let(:old_postal_code) {"10000"}
  let(:company) { create(:company, name: old_name, postal_code: old_postal_code) }
  let(:user) { create(:user, email: "user@me.com", company: company) }
  let(:new_name) { "new name" }
  let(:new_postal_code) { "12345" }
  let(:headers) { { "Authorization" => user.id } }

  subject do
    post(
      "/graphql",
      params: {
        query: query,
        variables: { input: { attributes: { name: new_name, postalCode: new_postal_code } } }
      },
      headers: headers
    )
  end

  it "updates the company name" do
    expect { subject }.
      to change { company.reload.name }.from(old_name).to(new_name).
      and change{company.reload.postal_code}.from(old_postal_code).to(new_postal_code)
  end
end
