class CreateAssignmentRequests < ActiveRecord::Migration

  def change
    create_table :assignment_requests do |t|
      t.integer :assignment_id
      t.string :body_hash
      t.text :body_json
      t.string :signature

      t.timestamps
    end
  end

end
