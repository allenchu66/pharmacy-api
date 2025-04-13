class User < ApplicationRecord
    has_many :orders
    validates :name, presence: true
    validates :phone_number, presence: true, uniqueness: true
    def as_json(options = {})
    super(options).merge(
      cash_balance: cash_balance.to_f
    )
  end
end
