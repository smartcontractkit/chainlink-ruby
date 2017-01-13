class AssignmentSerializer < ActiveModel::Serializer

  attributes :adapterType, :adapterTypes, :endAt,
    :parameters, :startAt, :status, :xid

  has_many :snapshots


  def adapterType
    object.adapter_types.first
  end

  def adapterTypes
    object.adapter_types
  end

  def endAt
    object.end_at.to_i.to_s
  end

  def startAt
    object.start_at.to_i.to_s
  end

  def parameters
    object.adapter_assignments.first.parameters
  end

end
