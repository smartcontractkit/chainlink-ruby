class EthereumOracleWrite < ActiveRecord::Base

  belongs_to :oracle, class_name: 'EthereumOracle'
  has_one :assignment, through: :oracle

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

end
