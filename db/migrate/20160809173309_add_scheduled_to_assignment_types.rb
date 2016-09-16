class AddScheduledToAssignmentTypes < ActiveRecord::Migration
  def change
    add_column :assignment_types, :unscheduled, :boolean, default: false
  end
end
