class CreatePurchaseRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pharmacy, null: false, foreign_key: true
      t.references :mask, null: false, foreign_key: true
      t.integer :quantity
      t.integer :total_price
      t.datetime :purchased_at

      t.timestamps
    end
  end
end
