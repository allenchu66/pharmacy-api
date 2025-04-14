class AddUnitPriceToMasks < ActiveRecord::Migration[7.0]
  def change
    add_column :masks, :unit_price, :decimal, precision: 10, scale: 2, null: true
  end
end
