FactoryBot.define do
    factory :mask do
      name { "醫療口罩" }
      price { 50 }
      stock { 100 }
      pharmacy
    end
  end
  