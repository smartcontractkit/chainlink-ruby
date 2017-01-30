class RenameAdapterAssignmentsToSubtasks < ActiveRecord::Migration
  def change
    rename_table :adapter_assignments, :subtasks
    rename_column :adapter_snapshots, :adapter_assignment_id, :subtask_id
  end
end
