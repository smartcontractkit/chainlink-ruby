class AssignmentRequestSerializer < ActiveModel::Serializer

  attributes :assignmentHash, :signature, :xid

  def assignmentHash
    object.body_hash
  end

  def xid
    assignment.xid
  end


  private

  def assignment
    object.assignment
  end

end
