class EthereumOracleWrite < ActiveRecord::Base

  belongs_to :oracle, polymorphic: true

  validates :oracle, presence: true
  validates :txid, presence: true

  def term
    oracle.related_term
  end

  def success?
    txid.present?
  end

  def snapshot_decorator
    AssignmentSnapshot::EthereumOracleWriteDecorator.new self
  end

  def assignment
    oracle.assignment
  end

end
