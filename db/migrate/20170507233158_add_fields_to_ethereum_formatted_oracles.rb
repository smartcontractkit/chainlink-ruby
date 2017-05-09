class AddFieldsToEthereumFormattedOracles < ActiveRecord::Migration
  def change
    add_column :ethereum_formatted_oracles, :config_value, :text
    add_column :ethereum_formatted_oracles, :payment_amount, :bigint, default: 0
  end
end
