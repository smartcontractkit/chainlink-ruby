class AddConstructionGasToEthereumContractTemplates < ActiveRecord::Migration
  def change
    add_column :ethereum_contract_templates, :construction_gas, :integer
  end
end
