class AddEthereumTransactionIdToEthereumContracts < ActiveRecord::Migration
  def change
    add_column :ethereum_contracts, :genesis_transaction_id, :integer
  end
end
