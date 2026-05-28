class Address < ApplicationRecord
  belongs_to :user

  validates :state,   presence: true
  validates :city,    presence: true
  validates :country, presence: true
  validates :pincode, presence: true
end
