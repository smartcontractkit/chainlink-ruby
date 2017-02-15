class CreateEthereumInt256Oracles < ActiveRecord::Migration

  def change
    create_table :ethereum_int256_oracles do |t|
      t.string   :address
      t.string   :update_address
      t.integer  :ethereum_account_id
      t.integer  :result_multiplier

      t.timestamps
    end
  end

end
