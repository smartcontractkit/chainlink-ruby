class AddInitializedToSubtasks < ActiveRecord::Migration

  def up
    add_column :subtasks, :ready, :boolean
    Subtask.update_all(ready: true)
  end

  def down
    remove_column :subtasks, :ready, :boolean
  end

end
