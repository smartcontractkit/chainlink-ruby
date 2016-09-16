class RemoveJsonSchemaFromValidators < ActiveRecord::Migration

  def change
    remove_column :validators, :json_schema, :text
    remove_column :validators, :type, :text
    add_column :validators, :assignment_type_id, :integer
  end

end
