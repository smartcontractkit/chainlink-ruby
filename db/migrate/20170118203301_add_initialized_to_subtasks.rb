class AddInitializedToSubtasks < ActiveRecord::Migration
  def change
    add_column :subtasks, :ready, :boolean
  end
end
