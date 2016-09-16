class RenameGetterSetterHashColumns < ActiveRecord::Migration
  def change
    rename_column :ethereum_contract_templates, :getter_hash, :read_address
    rename_column :ethereum_contract_templates, :setter_hash, :write_address
  end
end
