class Types::CompanyAttributesInputType < Types::BaseInputObject
  argument :name, String, "Company name", required: false
  argument :postal_code, String, "Company postal code", required: false
end