class RemoveMaskAndQuantityFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_reference :orders, :mask, null: false, foreign_key: true
    remove_column :orders, :quantity, :integer
  end
end
