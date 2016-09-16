class CreateEthereumAccounts < ActiveRecord::Migration
  def change
    create_table :ethereum_accounts do |t|
      t.string :address

      t.timestamps
    end
  end
end
