class CreateBitcoinOutputs < ActiveRecord::Migration
  def change
    create_table :bitcoin_outputs do |t|
      t.integer :bitcoin_address_id
      t.integer :bitcoin_transaction_id
      t.integer :tx_index
      t.integer :satoshis

      t.timestamps
    end
  end
end
