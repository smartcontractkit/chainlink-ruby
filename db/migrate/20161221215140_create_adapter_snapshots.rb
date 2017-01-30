class CreateAdapterSnapshots < ActiveRecord::Migration
  def change
    create_table :adapter_snapshots do |t|
      t.integer :assignment_snapshot_id
      t.integer :adapter_assignment_id
      t.text :description
      t.text :description_url
      t.text :details_json
      t.boolean :fulfilled, default: false
      t.text :summary
      t.text :value

      t.timestamps
    end
  end
end
