FactoryBot.define do
    factory :order_item do
      association :order
      association :mask
      price { 50 }
      quantity { 1 }
    end
  end
  