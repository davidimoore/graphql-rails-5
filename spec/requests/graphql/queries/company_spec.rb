require "rails_helper"

describe "company query" do
  let(:query) do
    <<~QUERY
      query FindCompany($id: ID!) {
        company(id: $id) {
          id
          motto
          users {
            totalCount
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id 
                email
              }
            }
          }
        }
      }
    QUERY
  end

  let!(:number_of_users) { 10 }
  let!(:company) { create(:company, name: "Company-1") }

  let!(:users) do
    number_of_users.times.map { |n| company.users.create(email: "user-#{n}@#{company.name}.com") }
  end

  let!(:headers) do
    {
      "Authorization" => company.users.first.id
    }
  end

  before do
    post "/graphql", params: { query: query, variables: { id: company.id } }, headers: headers
  end

  subject { JSON.parse(response.body).dig("data") }

  it "returns data about the company" do
    company_data = subject.fetch("company")

    expect(company_data.fetch("id")).to eq company.id.to_s
    expect(company_data.fetch("motto")).to eq "Company-1 does it best"
  end

  it "returns data about the users connection" do
    users_connection_data = subject.dig("company", "users")

    expect(users_connection_data.dig("pageInfo")).
      to eq({
              "hasNextPage" => true,
              "hasPreviousPage" => false,
              "startCursor" => "MQ",
              "endCursor" => "Mg"
            })

    expect(users_connection_data.dig("totalCount")).to eq(number_of_users)
  end

  it "returns data about the users edges" do
    users_from_db = User.all
    users_edges_data = subject.dig("company", "users", "edges")
    first_user = users_edges_data[0]
    second_user = users_edges_data[1]

    expect(first_user).
      to eq(
           {
             "cursor" => "MQ",
             "node" => {
               "id" => "#{users_from_db[0].id}",
               "email" => "#{users_from_db[0].email}"
             }
           }
         )

    expect(second_user).
      to eq(
           {
             "cursor" => "Mg",
             "node" => {
               "id" => "#{users_from_db[1].id}",
               "email" => "#{users_from_db[1].email}"
             }
           }
         )

  end
end