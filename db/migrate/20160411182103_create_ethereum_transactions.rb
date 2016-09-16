class CreateEthereumTransactions < ActiveRecord::Migration
  def change
    create_table :ethereum_transactions do |t|
      t.string :txid
      t.integer :account_id
      t.integer :confirmations, default: 0

      t.timestamps
    end
  end
end
