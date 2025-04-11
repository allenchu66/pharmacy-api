class ChangePriceTypeInMasks < ActiveRecord::Migration[7.1]
  def change
    change_column :masks, :price, :decimal
  end
end