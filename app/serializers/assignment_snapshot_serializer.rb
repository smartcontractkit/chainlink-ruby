class AssignmentSnapshotSerializer < ActiveModel::Serializer

  attributes :assignmentXID, :description, :descriptionURL,
    :details, :status, :summary, :value, :xid

  def assignmentXID
    assignment.xid
  end

  def descriptionURL
    object.description_url
  end


  private

  def assignment
    object.assignment
  end

end
