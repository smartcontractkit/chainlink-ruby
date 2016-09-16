class AddNotificationIdToBitcoinAddresses < ActiveRecord::Migration
  def change
    add_column :bitcoin_addresses, :notification_id, :string
  end
end
