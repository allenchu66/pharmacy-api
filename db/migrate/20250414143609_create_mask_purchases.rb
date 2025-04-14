class CreateMaskPurchases < ActiveRecord::Migration[7.0]
  def change
    create_table :mask_purchases do |t|
      t.references :pharmacy, null: false, foreign_key: true
      t.references :mask, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
