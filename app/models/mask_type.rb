class MaskType < ApplicationRecord
    has_many :masks
    validates :name, presence: true
  end