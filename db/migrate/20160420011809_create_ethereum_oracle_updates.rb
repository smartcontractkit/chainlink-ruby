class CreateEthereumOracleUpdates < ActiveRecord::Migration
  def change
    create_table :ethereum_oracle_updates do |t|
      t.integer :oracle_id
      t.string :txid
      t.text :value

      t.timestamps
    end
  end
end
