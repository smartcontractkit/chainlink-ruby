class FleshOutSnapshots < ActiveRecord::Migration
  def change
    rename_column :assignment_snapshots, :supporting_info, :details_json
    add_column :assignment_snapshots, :summary, :text
    add_column :assignment_snapshots, :description, :text
    add_column :assignment_snapshots, :description_url, :text
  end
end
