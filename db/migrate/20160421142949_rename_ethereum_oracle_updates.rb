class RenameEthereumOracleUpdates < ActiveRecord::Migration
  def change
    rename_table :ethereum_oracle_updates, :ethereum_oracle_writes
  end
end
