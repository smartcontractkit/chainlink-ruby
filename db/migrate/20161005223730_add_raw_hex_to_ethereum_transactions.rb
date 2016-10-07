class AddRawHexToEthereumTransactions < ActiveRecord::Migration
  def change
    add_column :ethereum_transactions, :raw_hex, :text
  end
end
