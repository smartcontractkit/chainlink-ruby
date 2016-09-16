class AddEthereumFunctionAddresses < ActiveRecord::Migration

  def change
    add_column :ethereum_contract_templates, :getter_hash, :string
    add_column :ethereum_contract_templates, :setter_hash, :string
    remove_column :ethereum_contract_templates, :function_signatures, :string
  end

end
