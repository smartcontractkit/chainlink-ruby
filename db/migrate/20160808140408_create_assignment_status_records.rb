class CreateAssignmentStatusRecords < ActiveRecord::Migration
  def change
    create_table :assignment_status_records do |t|
      t.string :xid
      t.text :value
      t.text :status
      t.text :supporting_info
      t.boolean :fulfilled, default: false
      t.integer :assignment_id

      t.timestamps
    end
  end
end
