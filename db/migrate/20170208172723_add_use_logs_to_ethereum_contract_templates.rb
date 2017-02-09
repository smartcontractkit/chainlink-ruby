class AddUseLogsToEthereumContractTemplates < ActiveRecord::Migration

  def change
    add_column :ethereum_contract_templates, :use_logs, :boolean, default: false
  end

end
