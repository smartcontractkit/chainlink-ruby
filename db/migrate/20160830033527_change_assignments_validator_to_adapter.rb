class ChangeAssignmentsValidatorToAdapter < ActiveRecord::Migration

  def up
    rename_column :assignments, :validator_id, :adapter_id
    add_column :assignments, :adapter_type, :string
    Assignment.update_all(adapter_type: 'InputAdapter')
  end

  def down
    remove_column :assignments, :adapter_type, :string
    rename_column :assignments, :adapter_id, :validator_id
  end

end
