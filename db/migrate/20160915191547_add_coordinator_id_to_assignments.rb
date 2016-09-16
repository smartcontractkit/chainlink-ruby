class AddCoordinatorIdToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :coordinator_id, :integer
  end
end
