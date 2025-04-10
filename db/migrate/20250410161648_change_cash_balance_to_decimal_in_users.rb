class ChangeCashBalanceToDecimalInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :cash_balance, :decimal, precision: 10, scale: 2
  end
end