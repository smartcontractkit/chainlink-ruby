class CreateAssignmentSchedules < ActiveRecord::Migration
  def change
    create_table :assignment_schedules do |t|
      t.integer :assignment_id
      t.string :minute
      t.string :hour
      t.string :day_of_month
      t.string :month_of_year
      t.string :day_of_week

      t.timestamps
    end
  end
end
