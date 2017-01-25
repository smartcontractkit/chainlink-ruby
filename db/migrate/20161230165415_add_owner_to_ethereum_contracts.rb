class AddOwnerToEthereumContracts < ActiveRecord::Migration

  def up
    add_column :ethereum_contracts, :owner_id, :integer
    add_column :ethereum_contracts, :owner_type, :string

    EthereumOracle.pluck(:id).each do |id|
      oracle = EthereumOracle.find(id)
      if contract = EthereumContract.find_by(id: oracle.ethereum_contract_id)
        contract.update_attributes! owner_id: oracle.id, owner_type: 'EthereumOracle'
      end
    end

    remove_column :ethereum_oracles, :ethereum_contract_id, :integer
  end

end
