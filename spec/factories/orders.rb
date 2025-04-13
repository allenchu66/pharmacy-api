FactoryBot.define do
    factory :order do
      association :user
      association :pharmacy
      total_price { 100 }
      created_at { Time.now }
      updated_at { Time.now }
    end
  end