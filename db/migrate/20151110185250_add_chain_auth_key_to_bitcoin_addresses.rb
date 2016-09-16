class AddChainAuthKeyToBitcoinAddresses < ActiveRecord::Migration
  def change
    add_column :bitcoin_addresses, :chain_auth_key, :string
  end
end
