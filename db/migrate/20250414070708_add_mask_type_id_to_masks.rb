class AddMaskTypeIdToMasks < ActiveRecord::Migration[7.1]
  def change
    add_column :masks, :mask_type_id, :integer
    add_index :masks, :mask_type_id
  end
end
