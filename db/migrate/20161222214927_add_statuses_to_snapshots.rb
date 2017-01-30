class AddStatusesToSnapshots < ActiveRecord::Migration
  def change
    add_column :assignment_snapshots, :progress, :string
    add_column :assignment_snapshots, :adapter_index, :integer
    add_column :adapter_snapshots, :progress, :string
  end
end
