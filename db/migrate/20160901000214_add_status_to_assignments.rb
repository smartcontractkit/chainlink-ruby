class AddStatusToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :status, :string
  end
end
