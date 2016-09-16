class HandleLargeBitcoinNumbers < ActiveRecord::Migration
  def change
    change_column :bitcoin_outputs, :satoshis, :decimal, precision: 16, scale: 0
    change_column :bitcoin_outputs, :usd_cents, :decimal, precision: 24, scale: 8
  end
end
