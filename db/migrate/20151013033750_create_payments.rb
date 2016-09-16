class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float :amount, scale: 3
      t.integer :bitcoin_output_id
      t.integer :payment_expectation_id

      t.timestamps
    end
  end
end
