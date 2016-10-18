class AddDetailsToEthereumTransactions < ActiveRecord::Migration
  def change
    add_column :ethereum_transactions, :nonce, :integer
    add_column :ethereum_transactions, :to, :string
    add_column :ethereum_transactions, :data, :text
    add_column :ethereum_transactions, :value, :bigint
    add_column :ethereum_transactions, :gas_price, :bigint
    add_column :ethereum_transactions, :gas_limit, :integer
  end
end
