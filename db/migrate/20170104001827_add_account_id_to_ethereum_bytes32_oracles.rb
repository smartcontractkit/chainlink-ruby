class AddAccountIdToEthereumBytes32Oracles < ActiveRecord::Migration
  def change
    add_column :ethereum_bytes32_oracles, :ethereum_account_id, :integer
  end
end
