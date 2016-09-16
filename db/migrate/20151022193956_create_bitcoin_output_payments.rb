class CreateBitcoinOutputPayments < ActiveRecord::Migration
  def change
    create_table :bitcoin_output_payments do |t|
      t.integer :bitcoin_output_id
      t.integer :payment_id

      t.timestamps
    end
    remove_column :payments, :bitcoin_output_id, :integer
    add_column :payments, :bitcoin_transaction_id, :integer
  end
end
