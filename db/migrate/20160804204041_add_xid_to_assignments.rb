class AddXidToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :xid, :string
  end
end
