class CreatePharmacyOpeningHours < ActiveRecord::Migration[7.1]
  def change
    create_table :pharmacy_opening_hours do |t|
      t.references :pharmacy, null: false, foreign_key: true
      t.integer :day_of_week
      t.string :open_time
      t.string :close_time
      t.boolean :overnight

      t.timestamps
    end
  end
end
