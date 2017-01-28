class AddStatusToAdapterSnapshots < ActiveRecord::Migration

  def change
    add_column :adapter_snapshots, :status, :string
  end

end
