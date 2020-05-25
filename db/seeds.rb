User.destroy_all
Company.destroy_all

5.times do
  company = Company.create!(name: Faker::Company.name)
  5.times do
    company.users.create(email: "#{Faker::Name.first_name}@#{company.name}.com")
  end
end