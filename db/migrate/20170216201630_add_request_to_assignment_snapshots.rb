class AddRequestToAssignmentSnapshots < ActiveRecord::Migration

  def change
    add_column :assignment_snapshots, :request_type, :string
    add_column :assignment_snapshots, :request_id, :integer
  end

end
