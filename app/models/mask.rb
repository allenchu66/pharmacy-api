class Mask < ApplicationRecord
  belongs_to :pharmacy
  belongs_to :mask_type
  def as_json(options = {})
    super.merge(price: price.to_f)
  end
end
