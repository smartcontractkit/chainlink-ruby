class AssignmentSerializer < ActiveModel::Serializer

  attributes :adapterType, :endAt,
    :parameters, :startAt, :status, :xid

  has_many :snapshots


  def adapterType
    object.adapter.type_name
  end

  def endAt
    object.end_at.to_i.to_s
  end

  def startAt
    object.start_at.to_i.to_s
  end

end
