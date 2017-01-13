class MakeSingularAssignmentAdapterPlural < ActiveRecord::Migration

  def up
    Assignment.where('adapter_id != null').pluck(:id) do |id|
      assignment = Assignment.find(id)
      assignment.adapter_assignments.create!({
        adapter_id: assignment.adapter_id,
        adapter_type: assignment.adapter_type,
        index: 0,
        adapter_params_json: assignment.json_parameters,
      })
      assignment.update_attributes!(adapter: nil)
    end

    remove_column :assignments, :adapter_id, :integer
    remove_column :assignments, :adapter_type, :string
    remove_column :assignments, :json_parameters, :text
  end

  def down
    add_column :assignments, :json_parameters, :text
    add_column :assignments, :adapter_type, :string
    add_column :assignments, :adapter_id, :integer

    AdapterAssignment.where(index: 0).pluck(:id).each do |id|
      adapter_assignment = AdapterAssignment.find(id)
      assignment = adapter_assignment.assignment
      assignment.update_attributes!({
        adapter_id: adapter_assignment.adapter_id,
        adapter_type: adapter_assignment.adapter_type,
        json_parameters: adapter_assignment.adapter_params_json,
      })
    end
  end

end
