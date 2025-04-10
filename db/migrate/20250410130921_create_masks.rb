class CreateMasks < ActiveRecord::Migration[7.1]
  def change
    create_table :masks do |t|
      t.string :name
      t.integer :price
      t.integer :stock
      t.references :pharmacy, null: false, foreign_key: true

      t.timestamps
    end
  end
end
