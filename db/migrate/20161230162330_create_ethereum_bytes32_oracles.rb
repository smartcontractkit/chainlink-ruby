class CreateEthereumBytes32Oracles < ActiveRecord::Migration
  def change
    create_table :ethereum_bytes32_oracles do |t|
      t.string :address
      t.string :update_address

      t.timestamps
    end
  end
end
