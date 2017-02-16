class AddRequesterToAssignmentSnapshots < ActiveRecord::Migration

  def change
    add_column :assignment_snapshots, :requester_type, :string
    add_column :assignment_snapshots, :requester_id, :integer
  end

end
