class AddSkipInitialSnapshotToAssignments < ActiveRecord::Migration

  def change
    add_column :assignments, :skip_initial_snapshot, :boolean, default: false
  end

end
