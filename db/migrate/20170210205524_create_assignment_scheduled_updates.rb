class CreateAssignmentScheduledUpdates < ActiveRecord::Migration
  def change
    create_table :assignment_scheduled_updates do |t|
      t.integer :assignment_id
      t.datetime :run_at
      t.boolean :scheduled, default: false

      t.timestamps
    end
  end
end
