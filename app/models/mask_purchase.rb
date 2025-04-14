class MaskPurchase < ApplicationRecord
    belongs_to :pharmacy
    belongs_to :mask
  
    validates :quantity, numericality: { greater_than: 0 }
    validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
    validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  end
  