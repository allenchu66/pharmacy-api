class RemoveNameFromMasks < ActiveRecord::Migration[7.1]
  def change
    remove_column :masks, :name, :string
  end
end
