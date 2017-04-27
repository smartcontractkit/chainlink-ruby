class CreateEthereumFormattedOracles < ActiveRecord::Migration
  def change
    create_table :ethereum_formatted_oracles do |t|
      t.string :address
      t.string :update_address
      t.integer :ethereum_account_id

      t.timestamps
    end
  end
end
