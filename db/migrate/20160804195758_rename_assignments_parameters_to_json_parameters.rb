class RenameAssignmentsParametersToJsonParameters < ActiveRecord::Migration
  def change
    rename_column :assignments, :parameters, :json_parameters
  end
end
