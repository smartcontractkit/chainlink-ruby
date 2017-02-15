class CreateEthereumLogEvents < ActiveRecord::Migration
  def change
    create_table :ethereum_events do |t|
      t.string :address
      t.string :block_hash
      t.integer :block_number
      t.text    :data
      t.integer :log_index
      t.integer :log_subscription_id
      t.string :transaction_hash
      t.integer :transaction_index
    end
  end
end
