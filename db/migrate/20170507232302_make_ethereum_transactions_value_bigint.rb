class MakeEthereumTransactionsValueBigint < ActiveRecord::Migration
  def change
    change_column :ethereum_transactions, :value, :bigint
  end
end
