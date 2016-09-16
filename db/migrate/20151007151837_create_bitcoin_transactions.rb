class CreateBitcoinTransactions < ActiveRecord::Migration
  def change
    create_table :bitcoin_transactions do |t|
      t.string :txid
      t.integer :confirmations

      t.timestamps
    end
  end
end
