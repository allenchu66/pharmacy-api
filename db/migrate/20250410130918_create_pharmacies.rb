class CreatePharmacies < ActiveRecord::Migration[7.1]
  def change
    create_table :pharmacies do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.string :open_time
      t.string :close_time
      t.integer :cash_balance

      t.timestamps
    end
  end
end
