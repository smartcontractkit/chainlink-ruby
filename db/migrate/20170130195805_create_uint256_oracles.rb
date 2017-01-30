class CreateUint256Oracles < ActiveRecord::Migration
  def change
    create_table :ethereum_uint256_oracles do |t|
      t.string   :address
      t.string   :update_address
      t.integer  :ethereum_account_id

      t.timestamps
    end
  end
end
