class AddStartAndEndAtToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :start_at, :datetime
    add_column :assignments, :end_at, :datetime
  end
end
