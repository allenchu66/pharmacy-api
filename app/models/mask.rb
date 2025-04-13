class Mask < ApplicationRecord
  belongs_to :pharmacy
  def as_json(options = {})
    super.merge(price: price.to_f)
  end
end
