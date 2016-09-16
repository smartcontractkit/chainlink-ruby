class RemoveChainAuthKeyFromBitcoinAddresses < ActiveRecord::Migration
  def change
    remove_column :bitcoin_addresses, :chain_auth_key, :string
    remove_column :bitcoin_addresses, :chain_id, :string
  end
end
