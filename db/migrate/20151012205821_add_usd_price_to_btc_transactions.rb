class AddUsdPriceToBtcTransactions < ActiveRecord::Migration
  def change
    add_column :bitcoin_transactions, :usd_price, :integer
  end
end
