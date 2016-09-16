class SpecifyChainNotificationId < ActiveRecord::Migration
  def change
    rename_column :bitcoin_addresses, :notification_id, :chain_id
  end
end
