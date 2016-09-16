class AssignmentSnapshotSerializer < ActiveModel::Serializer

  attributes :assignment_xid, :description, :description_url,
    :details, :status, :summary, :value, :xid

  def assignment_xid
    assignment.xid
  end


  private

  def assignment
    object.assignment
  end

end
