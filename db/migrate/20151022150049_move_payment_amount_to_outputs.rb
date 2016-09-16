class MovePaymentAmountToOutputs < ActiveRecord::Migration
  def change
    add_column :bitcoin_outputs, :usd_cents, :float
    remove_column :payments, :amount, :float
  end
end
