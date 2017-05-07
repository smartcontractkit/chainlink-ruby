class AddAmountPaidToEthereumOracleWrites < ActiveRecord::Migration

  def change
    add_column :ethereum_oracle_writes, :amount_paid, :integer, default: 0
  end

end
