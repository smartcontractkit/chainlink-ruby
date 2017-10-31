class AddCurrentToEthereumAccounts < ActiveRecord::Migration

  def change
    add_column :ethereum_accounts, :current, :boolean, default: true
  end

end
