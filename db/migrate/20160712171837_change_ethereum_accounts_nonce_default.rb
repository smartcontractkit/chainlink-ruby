class ChangeEthereumAccountsNonceDefault < ActiveRecord::Migration
  def change
    change_column :ethereum_accounts, :nonce, :integer, default: 0
  end
end
