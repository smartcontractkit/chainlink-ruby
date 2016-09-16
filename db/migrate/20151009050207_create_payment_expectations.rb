class CreatePaymentExpectations < ActiveRecord::Migration
  def change
    create_table :payment_expectations do |t|
      t.integer :bitcoin_address_id
      t.integer :cents

      t.timestamps
    end
  end
end
