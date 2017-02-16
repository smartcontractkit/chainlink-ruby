class AddRequestedToAdapterSnapshots < ActiveRecord::Migration

  def change
    add_column :adapter_snapshots, :requested, :boolean, default: false
  end

end
