class User < ApplicationRecord
  has_secure_password

  belongs_to :company

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
