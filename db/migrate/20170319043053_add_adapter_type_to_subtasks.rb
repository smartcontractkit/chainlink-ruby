class AddAdapterTypeToSubtasks < ActiveRecord::Migration

  def change
    add_column :subtasks, :task_type, :string
  end

end
