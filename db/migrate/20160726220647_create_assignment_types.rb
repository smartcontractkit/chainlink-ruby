class CreateAssignmentTypes < ActiveRecord::Migration
  def change
    create_table :assignment_types do |t|
      t.string :name
      t.string :description
      t.text :json_schema

      t.timestamps
    end
  end
end
