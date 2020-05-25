require "rails_helper"

describe "companies query" do
  let(:query) do
    <<~QUERY
      query FindCompanies {
        companies {
          id
          motto
        
        	users {
            email
          }
        }
      }
    QUERY
  end

  def create_company(name:)
    company = create(:company, name: name)
    2.times do |num|
      company.users.create(email: "user-#{num}@#{company.name}.com")
    end
    company
  end

  it "returns a list of companies and their users" do
    company_one = create_company(name: "Company-1")
    company_two = create_company(name: "Company-2")

    headers = {
      "Authorization" => company_two.users.first.id
    }

    post "/graphql", params: { query: query }, headers: headers

    expect(JSON.parse(response.body)).
      to match(
           { "data" =>
               { "companies" =>
                   [
                     { "id" => "#{company_one.id}",
                       "motto" => "Company-1 does it best",
                       "users" => [
                         { "email" => "user-0@Company-1.com" },
                         { "email" => "user-1@Company-1.com" }
                       ]
                     },
                     { "id" => "#{company_two.id}",
                       "motto" => "Company-2 does it best",
                       "users" => [
                         { "email" => "user-0@Company-2.com" },
                         { "email" => "user-1@Company-2.com" }
                       ]
                     }
                   ]
               }
           }
         )
  end
end