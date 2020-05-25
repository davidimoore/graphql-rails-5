# frozen_string_literal: true

describe "UpdateUser mutation" do
  let(:query) do
    <<~GRAPHQL
      mutation UpdateUser($oldEmail: String!, $newEmail: String!) {
        updateUser(
          input: 
            { 
              oldEmail: $oldEmail,
              newEmail: $newEmail
            }
        ) {
          success
        }
      }
    GRAPHQL
  end

  let(:company) { create(:company) }
  let(:old_email) {"old_email@me.com"}
  let!(:user) { create(:user, email: old_email, company: company) }
  let(:headers) { { "Authorization" => user.id } }
  let(:new_email) { "new_email@me.com" }

  subject do
    post("/graphql",
         params:
           { query: query,
             variables: { oldEmail: "old_email@me.com", newEmail: "new_email@me.com" }
           },
         headers: headers
    )
  end

  it "creates a GameMembership record" do
    expect { subject }.to change { user.reload.email }.from(old_email).to(new_email)
  end
end
