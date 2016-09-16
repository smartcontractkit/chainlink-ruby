class RenameValidatorsToInputAdapters < ActiveRecord::Migration
  def change
    rename_table :validators, :input_adapters
  end
end
