class FixEthereumNumberPrecision < ActiveRecord::Migration
  def change
    change_column :ethereum_formatted_oracles, :payment_amount, :decimal, precision: 36, scale: 0, default: 0
    change_column :ethereum_transactions, :value, :decimal, precision: 36, scale: 0
    change_column :ethereum_oracle_writes, :amount_paid, :decimal, precision: 36, scale: 0
  end
end
