class AddOracleTypeToEthereumOracleWrites < ActiveRecord::Migration

  def up
    add_column :ethereum_oracle_writes, :oracle_type, :string
    EthereumOracleWrite.update_all(oracle_type: 'EthereumOracle')
  end

  def down
    remove_column :ethereum_oracle_writes, :oracle_type, :string
  end

end
