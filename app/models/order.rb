class Order < ApplicationRecord
  belongs_to :user
  belongs_to :pharmacy
  has_many :order_items, dependent: :destroy
end
