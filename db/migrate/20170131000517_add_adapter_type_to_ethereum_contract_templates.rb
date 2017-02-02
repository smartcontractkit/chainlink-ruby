class AddAdapterTypeToEthereumContractTemplates < ActiveRecord::Migration

  def up
    add_column :ethereum_contract_templates, :adapter_name, :string
    EthereumContractTemplate.update_all(adapter_name: 'ethereumBytes32JSON')
  end

  def down
    remove_column :ethereum_contract_templates, :adapter_name, :string
  end

end
