class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.text :parameters
      t.integer :validator_id

      t.timestamps
    end
  end
end
