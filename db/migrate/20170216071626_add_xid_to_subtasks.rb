class AddXidToSubtasks < ActiveRecord::Migration

  def up
    add_column :subtasks, :xid, :string

    Subtask.pluck(:id).each do |id|
      subtask = Subtask.find(id)
      subtask.update_attributes!({
        xid: "#{subtask.assignment.xid}=#{subtask.index}"
      })
    end
  end

  def down
    remove_column :subtasks, :xid, :string
  end

end
