class RenameAssignmentStatusRecordsToAssignmentSnapshots < ActiveRecord::Migration
  def change
    rename_table :assignment_status_records, :assignment_snapshots
  end
end
