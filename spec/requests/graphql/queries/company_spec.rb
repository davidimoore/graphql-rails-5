require "rails_helper"

describe "company query" do
  let(:query) do
    <<~QUERY
      query FindCompany($id: ID!) {
        company(id: $id) {
          id
          motto
          userCount
        	users {
            email
          }
        }
      }
    QUERY
  end

  it "returns a company and their users" do

    company = create(:company, name: "Company-1")
    2.times do |num|
      company.users.create(email: "user-#{num}@#{company.name}.com")
    end

    headers = {
      "Authorization" => company.users.first.id
    }

    post "/graphql", params: { query: query, variables: { id: company.id } }, headers: headers

    expect(JSON.parse(response.body)).
      to eq(
           {
             "data" => {
               "company" =>
                 {
                   "id" => "#{company.id}",
                   "motto" => "Company-1 does it best",
                   "userCount" => 2,
                   "users" => [
                     { "email" => "user-0@Company-1.com" },
                     { "email" => "user-1@Company-1.com" }
                   ]
                 }
             }
           }
         )
  end
end