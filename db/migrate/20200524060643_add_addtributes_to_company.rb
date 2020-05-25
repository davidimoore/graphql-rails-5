class AddAddtributesToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :postal_code, :string
  end
end
