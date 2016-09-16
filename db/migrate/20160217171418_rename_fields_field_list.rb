class RenameFieldsFieldList < ActiveRecord::Migration
  def change
    rename_column :custom_expectations, :fields, :field_list
  end
end
