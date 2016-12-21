class CreateAdapterAssignments < ActiveRecord::Migration
  def change
    create_table :adapter_assignments do |t|
      t.string :adapter_type
      t.integer :adapter_id
      t.integer :assignment_id
      t.integer :index
      t.text :adapter_params_json

      t.timestamps
    end
  end
end
