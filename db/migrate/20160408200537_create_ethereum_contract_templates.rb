class CreateEthereumContractTemplates < ActiveRecord::Migration
  def change
    create_table :ethereum_contract_templates do |t|
      t.text :code
      t.text :evm_hex
      t.text :json_abi
      t.text :solidity_abi
      t.text :function_signatures

      t.timestamps
    end
  end
end
