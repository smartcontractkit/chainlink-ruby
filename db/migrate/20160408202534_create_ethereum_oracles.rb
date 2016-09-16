class CreateEthereumOracles < ActiveRecord::Migration
  def change
    create_table :ethereum_oracles do |t|
      t.text :endpoint
      t.text :field_list
      t.integer :ethereum_contract_id

      t.timestamps
    end
  end
end
