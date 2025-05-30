class ChangeOpenCloseTimeToTimeInPharmacyOpeningHours < ActiveRecord::Migration[6.1]
  def up
    change_column :pharmacy_opening_hours, :open_time, :time, using: 'open_time::time'
    change_column :pharmacy_opening_hours, :close_time, :time, using: 'close_time::time'
  end

  def down
    change_column :pharmacy_opening_hours, :open_time, :datetime, using: 'open_time::timestamp'
    change_column :pharmacy_opening_hours, :close_time, :datetime, using: 'close_time::timestamp'
  end
end