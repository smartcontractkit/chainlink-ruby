class AddStartAtAndEndAtToAssignmentSchedules < ActiveRecord::Migration

  def up
    add_column :assignment_schedules, :start_at, :datetime
    add_column :assignment_schedules, :end_at, :datetime
    AssignmentSchedule.all.pluck(:id) do |id|
      schedule = AssignmentSchedule.find(id)
      assignment = schedule.assignment
      schedule.update_attributes({
        start_at: assignment.start_at,
        end_at: assignment.end_at,
      })
    end
  end

  def down
    remove_column :assignment_schedules, :start_at, :datetime
    remove_column :assignment_schedules, :end_at, :datetime
  end

end
