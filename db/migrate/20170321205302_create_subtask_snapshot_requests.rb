class CreateSubtaskSnapshotRequests < ActiveRecord::Migration
  def change
    create_table :subtask_snapshot_requests do |t|
      t.integer :subtask_id
      t.text :data_json

      t.timestamps
    end
  end
end
