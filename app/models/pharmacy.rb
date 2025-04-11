class Pharmacy < ApplicationRecord
  has_many :pharmacy_opening_hours, dependent: :destroy
  has_many :masks, dependent: :destroy
end