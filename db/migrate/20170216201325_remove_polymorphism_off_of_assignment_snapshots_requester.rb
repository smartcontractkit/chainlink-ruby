class RemovePolymorphismOffOfAssignmentSnapshotsRequester < ActiveRecord::Migration

  def change
    remove_column :assignment_snapshots, :requester_type, :string
  end

end
