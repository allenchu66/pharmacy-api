class RemoveOpenTimeAndCloseTimeFromPharmacies < ActiveRecord::Migration[7.1]
  def change
    remove_column :pharmacies, :open_time, :string
    remove_column :pharmacies, :close_time, :string
  end
end
