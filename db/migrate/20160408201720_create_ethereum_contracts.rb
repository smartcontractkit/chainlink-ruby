class CreateEthereumContracts < ActiveRecord::Migration
  def change
    create_table :ethereum_contracts do |t|
      t.string :address
      t.integer :template_id
      t.integer :account_id

      t.timestamps
    end
  end
end
