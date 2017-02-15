class AddResultMultiplierToEthereumUint256Oracles < ActiveRecord::Migration

  def up
    add_column :ethereum_uint256_oracles, :result_multiplier, :integer
    Ethereum::Uint256Oracle.update_all result_multiplier: 1
  end

  def down
    remove_column :ethereum_uint256_oracles, :result_multiplier, :integer
  end

end
