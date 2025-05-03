class RemoveOvernightFromPharmacyOpeningHours < ActiveRecord::Migration[7.1]
  def change
    remove_column :pharmacy_opening_hours, :overnight, :boolean
  end
end
