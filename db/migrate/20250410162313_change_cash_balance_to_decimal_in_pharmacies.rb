class ChangeCashBalanceToDecimalInPharmacies < ActiveRecord::Migration[7.1]
  def change
    change_column :pharmacies, :cash_balance, :decimal, precision: 10, scale: 2
  end
end
