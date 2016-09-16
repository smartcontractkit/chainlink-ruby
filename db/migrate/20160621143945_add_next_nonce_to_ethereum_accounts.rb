class AddNextNonceToEthereumAccounts < ActiveRecord::Migration
  def change
    add_column :ethereum_accounts, :nonce, :integer, default: 1
  end
end
