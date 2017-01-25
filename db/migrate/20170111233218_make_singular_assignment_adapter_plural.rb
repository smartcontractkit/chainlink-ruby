class MakeSingularAssignmentAdapterPlural < ActiveRecord::Migration

  def up
    Assignment.where('adapter_id IS NOT null').pluck(:id).each do |id|
      assignment = Assignment.find(id)

      time = "'#{Time.now.to_s(:db)}'"
      columns = ["adapter_id", "adapter_type", "assignment_id", "index", "adapter_params_json", "created_at", "updated_at"]
      values = [assignment.adapter_id, "'#{assignment.adapter_type}'", assignment.id, 0, "'#{assignment.json_parameters}'", time, time]
      sql = "INSERT INTO adapter_assignments (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
      ActiveRecord::Base.connection.execute(sql)
    end

    remove_column :assignments, :adapter_id, :integer
    remove_column :assignments, :adapter_type, :string
    remove_column :assignments, :json_parameters, :text
  end

end
