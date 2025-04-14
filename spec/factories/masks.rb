FactoryBot.define do
    factory :mask do
      price { 50 }
      stock { 100 }
      pharmacy
      mask_type
    end
  end
  