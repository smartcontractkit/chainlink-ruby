class AddBlockcypherNotificationId < ActiveRecord::Migration
  def change
    add_column :bitcoin_addresses, :bcy_id, :string
    add_column :bitcoin_addresses, :bcy_auth_key, :string
  end
end
